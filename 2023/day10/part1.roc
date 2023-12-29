app "day9-part1"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
        common: "../common/main.roc",
    }
    imports [
        pf.Stdin, pf.Stdout, pf.Stderr, pf.Task.{ Task },
        common.Io.{ walkLinesTry },
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
                NotConnected -> "Start tile is not connected"
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

findStartInRow : MazeRow -> [NotFound, Found Index]
findStartInRow = \row ->
    index = row |> List.findFirstIndex \tile -> tile == Start
    when index is
        Ok col -> Found col
        Err NotFound -> NotFound

findStart : Maze -> Result Position [NoStart]
findStart = \maze ->
    maze
    |> List.walkWithIndexUntil (Err NoStart) \state, row, index ->
        when findStartInRow row is
            Found col -> Ok { row: index, col } |> Break
            NotFound -> state |> Continue

getTile : Maze, Position -> Result Tile [OutOfBounds]
getTile = \maze, { row, col } ->
    mazeRow <- maze |> List.get row |> Result.try
    mazeRow |> List.get col

move : Maze, Position, Direction -> Result MoveState [OutOfBounds]
move = \maze, { row, col }, dir ->
    pos =
        when dir is
            Up -> { row: row - 1, col }
            Down -> { row: row + 1, col }
            Left -> { row, col: col - 1 }
            Right -> { row, col: col + 1 }

    tile <- maze |> getTile pos |> Result.try
    Ok { tile, pos, inDir: dir }

initialDirection : Maze, Position -> Result Direction [NotConnected]
initialDirection = \maze, start ->
    isConnected = \dir, tile ->
        when (dir, tile) is
            (Up, SouthEast) | (Up, SouthWest) | (Up, NorthSouth)
            | (Down, NorthEast) | (Down, NorthWest) | (Down, NorthSouth)
            | (Left, NorthEast) | (Left, SouthEast) | (Left, EastWest)
            | (Right, NorthWest) | (Right, SouthWest) | (Right, EastWest)
              -> Bool.true
            _ -> Bool.false

    [Up, Down, Left, Right]
    |> List.walkUntil
        (Err NotConnected)
        \state, dir ->
            when maze |> move start dir is
                Ok { tile } if isConnected dir tile -> Ok dir |> Break
                _ -> state |> Continue

nextDirection : Direction, Tile -> Result Direction [DeadEnd]
nextDirection = \in, tile ->
    expect tile != Start
    when (in, tile) is
        (Left, NorthEast) | (Right, NorthWest) | (Up, NorthSouth) -> Ok Up
        (Left, SouthEast) | (Right, SouthWest) | (Down, NorthSouth) -> Ok Down
        (Up, SouthWest) | (Down, NorthWest) | (Left, EastWest) -> Ok Left
        (Up, SouthEast) | (Down, NorthEast) | (Right, EastWest) -> Ok Right
        _ -> Err DeadEnd

solve : Maze -> Result Nat _
solve = \maze ->
    start <- maze |> findStart |> Result.try
    dir <- maze |> initialDirection start |> Result.try
    init <- maze |> move start dir |> Result.try

    step : MoveState, Nat -> Result Nat _
    step = \{ tile, pos, inDir }, count ->
        if tile == Start then
            expect pos == start  # assume there is only one start
            Ok count
        else
            outDir <- nextDirection inDir tile |> Result.try
            next <- maze |> move pos outDir |> Result.try
            step next (count + 1)

    loopLength <- step init 1 |> Result.try
    Ok (loopLength // 2)
