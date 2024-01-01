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

MaybeTile : [Some Tile, Empty]
SparseMaze : List (List MaybeTile)

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

insertTile : SparseMaze, Position, Tile -> SparseMaze
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

drawLoop : Maze -> Result SparseMaze _
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

countEnclosed : (List MaybeTile) -> Nat
countEnclosed = \row ->
    State : {
        enclosed : [Outside, Inside],
        horizontal : [NotHorizontal, Horizontal Tile],
        count: Nat
    }
    init : State
    init = { enclosed: Outside, horizontal: NotHorizontal, count: 0 }

    unwrap : MaybeTile -> Tile
    unwrap = \tile ->
        when tile is
            Some t -> t
            Empty -> crash "impossible"

    countUp : State -> State
    countUp = \state -> { state & count: state.count + 1 }

    toggle = \enclosed ->
        when enclosed is
            Inside -> Outside
            Outside -> Inside

    toggleVertical : State -> State
    toggleVertical = \state -> { state & enclosed: toggle state.enclosed }

    openHorizontal : State, Tile -> State
    openHorizontal = \state, tile ->
        when tile is
            NorthEast | SouthEast ->
                { state & horizontal: Horizontal tile }

            _ -> crash "impossible"

    closeHorizontal : State, Tile -> State
    closeHorizontal = \state, tile ->
        enclosed =
            when (state.horizontal, tile) is
                (Horizontal NorthEast, SouthWest)
                | (Horizontal SouthEast, NorthWest) ->
                    toggle state.enclosed

                (Horizontal NorthEast, NorthWest)
                | (Horizontal SouthEast, SouthWest) ->
                    state.enclosed

                _ -> crash "impossible"

        { state & enclosed, horizontal: NotHorizontal }

    step : State, MaybeTile -> State
    step = \state, tile ->
        when (state.horizontal, tile) is
            (NotHorizontal, Empty) ->
                when state.enclosed is
                    Inside -> state |> countUp
                    Outside -> state

            (NotHorizontal, Some NorthSouth) ->
                state |> toggleVertical

            (NotHorizontal, Some NorthEast)
            | (NotHorizontal, Some SouthEast) ->
                state |> openHorizontal (unwrap tile)

            (Horizontal _, Some EastWest) ->
                state

            (Horizontal _, Some NorthWest)
            | (Horizontal _, Some SouthWest) ->
                state |> closeHorizontal (unwrap tile)

            (Horizontal _, Empty)
            | (Horizontal _, Some NorthSouth)
            | (Horizontal _, Some NorthEast)
            | (Horizontal _, Some SouthEast)
            | (NotHorizontal, Some EastWest)
            | (NotHorizontal, Some NorthWest)
            | (NotHorizontal, Some SouthWest) ->
                crash "impossible dead end"

            (_, Some Ground) | (_, Some Start) ->
                crash "impossible loop tile"

    row |> List.walk init step |> .count

solve : Maze -> Result Nat _
solve = \maze ->
    loop <- drawLoop maze |> Result.try
    loop |> List.map countEnclosed |> List.sum |> Ok
