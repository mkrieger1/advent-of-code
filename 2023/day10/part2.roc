app "day10-part2"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
        common: "../common/main.roc",
    }
    imports [
        pf.Stdin, pf.Stdout, pf.Stderr, pf.Task.{ Task },
        common.Io.{ walkLinesTry },
        common.Loop,
    ]
    provides [main] to pf

unused = Stdin.line

main =
    run =
        maze <- parseMaze |> Task.await
        result <- solve maze |> Task.fromResult |> Task.await
        result |> Num.toStr |> Stdout.line

    handleErr = \err ->
        msg =
            when err is
                InvalidTile c -> "Found invalid tile: \(Num.toStr c)"
                NoStart -> "Maze contains no start tile"
                InvalidStart -> "Start tile is not connected to 2 neighbors"
                OutOfBounds -> "Moved past the borders of the maze"
                DeadEnd -> "Reached a dead end in the maze"
        msg |> Stderr.line

    run |> Task.onErr handleErr

Index : Nat
Position : { row : Index, col : Index }
Direction : [Up, Down, Left, Right]
Tile : [
    NorthSouth, EastWest, NorthEast, NorthWest, SouthWest, SouthEast,
    Ground, Start,
]
MoveState : { tile : Tile, pos : Position, inDir : Direction }
MazeRow : List Tile
Maze : List MazeRow

MazeLoopTile : [Some Tile, Empty]
MazeLoopRow : List MazeLoopTile
MazeLoop : List MazeLoopRow

parseMaze : Task Maze _
parseMaze =
    walkLinesTry [] \maze, line ->
        row <- parseRow line |> Result.try
        maze |> List.append row |> Ok

parseRow : Str -> Result MazeRow _
parseRow = \line ->
    line
    |> Str.toUtf8
    |> List.mapTry parseTile

parseTile : U8 -> Result Tile _
parseTile = \c ->
    when c is
        '|' -> Ok NorthSouth
        '-' -> Ok EastWest
        'L' -> Ok NorthEast
        'J' -> Ok NorthWest
        '7' -> Ok SouthWest
        'F' -> Ok SouthEast
        '.' -> Ok Ground
        'S' -> Ok Start
        _ -> Err (InvalidTile c)

findStart : Maze -> Result Position [NoStart]
findStart = \maze ->
    maze
    |> List.walkWithIndexUntil (Err NoStart) \state, row, rowIndex ->
        when row |> List.findFirstIndex \tile -> tile == Start is
            Ok col -> Ok { row: rowIndex, col } |> Break
            Err NotFound -> state |> Continue

getTile : Maze, Position -> Result Tile [OutOfBounds]
getTile = \maze, { row, col } ->
    mazeRow <- maze |> List.get row |> Result.try
    mazeRow |> List.get col

ensureSize : List a, Index, a -> List a
ensureSize = \list, i, fillValue ->
    length = List.len list
    needed = i + 1
    if length >= needed then
        list
    else
        missing = needed - length
        expect missing >= 1
        fill = fillValue |> List.repeat missing
        list |> List.concat fill

insertTile : MazeLoop, Position, Tile -> MazeLoop
insertTile = \loop, pos, tile ->
    newLoop = loop |> ensureSize pos.row []
    row =
        when newLoop |> List.get pos.row is
            Err OutOfBounds -> crash "impossible"
            Ok r -> r

    newRow =
        row
        |> ensureSize pos.col Empty
        |> List.set pos.col (Some tile)

    newLoop |> List.set pos.row newRow

move : Maze, Position, Direction -> Result MoveState [OutOfBounds]
move = \maze, { row, col }, dir ->
    inc = \x -> x |> Num.addChecked 1
    dec = \x -> x |> Num.subChecked 1

    posChecked =
        when dir is
            Up -> dec row |> Result.try \r -> Ok { row: r, col }
            Down -> inc row |> Result.try \r -> Ok { row: r, col }
            Left -> dec col |> Result.try \c -> Ok { row, col: c }
            Right -> inc col |> Result.try \c -> Ok { row, col: c }

    pos <-
        posChecked
        |> Result.mapErr \e -> when e is Overflow -> OutOfBounds
        |> Result.try

    tile <- maze |> getTile pos |> Result.try
    Ok { tile, pos, inDir: dir }

revealStart :
    Maze, Position -> Result { dir : Direction, tile : Tile } [InvalidStart]
revealStart = \maze, start ->
    isConnected = \dir, tile ->
        when (dir, tile) is
            (Up, SouthEast) | (Up, SouthWest) | (Up, NorthSouth)
            | (Down, NorthEast) | (Down, NorthWest) | (Down, NorthSouth)
            | (Left, NorthEast) | (Left, SouthEast) | (Left, EastWest)
            | (Right, NorthWest) | (Right, SouthWest) | (Right, EastWest)
              -> Bool.true
            _ -> Bool.false

    dirs =
        [Up, Down, Left, Right]
        |> List.keepIf \dir ->
            when maze |> move start dir is
                Ok { tile } if isConnected dir tile -> Bool.true
                _ -> Bool.false

    startTile = \dir, otherDir ->
        when (dir, otherDir) is
            (Up, Down) -> NorthSouth
            (Up, Left) -> NorthWest
            (Up, Right) -> NorthEast
            (Down, Left) -> SouthWest
            (Down, Right) -> SouthEast
            (Left, Right) -> EastWest
            _ -> crash "impossible"

    when dirs is
        [dir, otherDir] -> { dir, tile: startTile dir otherDir } |> Ok
        _ -> InvalidStart |> Err

nextDirection : Direction, Tile -> Result Direction [DeadEnd]
nextDirection = \in, tile ->
    expect tile != Start
    when (in, tile) is
        (Left, NorthEast) | (Right, NorthWest) | (Up, NorthSouth) -> Ok Up
        (Left, SouthEast) | (Right, SouthWest) | (Down, NorthSouth) -> Ok Down
        (Up, SouthWest) | (Down, NorthWest) | (Left, EastWest) -> Ok Left
        (Up, SouthEast) | (Down, NorthEast) | (Right, EastWest) -> Ok Right
        _ -> Err DeadEnd

drawLoop : Maze -> Result MazeLoop _
drawLoop = \maze ->
    start <- maze |> findStart |> Result.try
    { dir, tile: startTile } <- maze |> revealStart start |> Result.try
    init <- maze |> move start dir |> Result.try

    step = \{ state: { tile, pos, inDir }, draw } ->
        if tile == Start then
            expect pos == start  # assume there is only one start
            draw |> insertTile pos startTile |> Break |> Ok
        else
            outDir <- nextDirection inDir tile |> Result.try
            state <- maze |> move pos outDir |> Result.try
            { state, draw: draw |> insertTile pos tile } |> Continue |> Ok

    # do not confuse "Loop.loop" for iteration with "loop" in the maze
    Loop.loop { state: init, draw: [] } step

countEnclosedTiles : MazeLoop -> Result Nat _
countEnclosedTiles = \loop ->
    rowCounts <- loop |> List.mapTry countEnclosedTilesInRow |> Result.try
    rowCounts |> List.sum |> Ok

countEnclosedTilesInRow : MazeLoopRow -> Result Nat _
countEnclosedTilesInRow = \row ->
    toggle = \enclosed ->
        when enclosed is
            Inside -> Outside
            Outside -> Inside

    toggleHorizontalPair = \enclosed, { begin, end } ->
        when (begin, end) is
            (NorthEast, SouthWest) | (SouthEast, NorthWest) -> toggle enclosed
            (NorthEast, NorthWest) | (SouthEast, SouthWest) -> enclosed
            _ -> crash "impossible"

    init = { enclosed: Outside, horizontal: NotHorizontal, count: 0 }

    step = \state, loopTile ->
        when loopTile is
            Empty ->
                when state.horizontal is
                    NotHorizontal ->
                        when state.enclosed is
                            Inside -> Ok { state & count: state.count + 1 }
                            Outside -> Ok state
                    OpenHorizontal _ -> Err DeadEnd
            Some t ->
                when t is
                    NorthSouth ->
                        when state.horizontal is
                            NotHorizontal -> Ok {
                                state &
                                enclosed: toggle state.enclosed
                            }
                            OpenHorizontal _ -> Err DeadEnd
                    EastWest ->
                        when state.horizontal is
                            NotHorizontal -> Err DeadEnd
                            OpenHorizontal _ -> Ok state
                    NorthEast | SouthEast ->
                        when state.horizontal is
                            NotHorizontal ->
                                Ok { state & horizontal: OpenHorizontal t }
                            OpenHorizontal _ -> Err DeadEnd
                    NorthWest | SouthWest ->
                        when state.horizontal is
                            NotHorizontal -> Err DeadEnd
                            OpenHorizontal begin -> Ok {
                                state &
                                enclosed:
                                    state.enclosed
                                    |> toggleHorizontalPair { begin, end: t },
                                horizontal: NotHorizontal
                            }
                    Ground | Start -> crash "impossible"

    result <- row |> List.walkTry init step |> Result.try
    Ok result.count

solve : Maze -> Result Nat _
solve = \maze ->
    loop <- drawLoop maze |> Result.try
    loop |> countEnclosedTiles
