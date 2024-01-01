interface Day10
    exposes [
        Direction, Maze, Position, Tile,
        findStart, move, nextDirection, parseMaze,
    ]
    imports [
        pf.Task.{ Task },
        common.Io.{ walkLinesTry },
    ]

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

move : Maze, Position, Direction -> Result MoveState [OutOfBounds]
move = \maze, { row, col }, dir ->
    inc = \x -> x + 1
    dec = \x -> x |> Num.subChecked 1 |> Result.mapErr \_ -> OutOfBounds

    posChecked =
        when dir is
            Up -> dec row |> Result.try \r -> Ok { row: r, col }
            Down -> inc row |> \r -> Ok { row: r, col }
            Left -> dec col |> Result.try \c -> Ok { row, col: c }
            Right -> inc col |> \c -> Ok { row, col: c }

    pos <- posChecked |> Result.try
    tile <- maze |> getTile pos |> Result.try
    Ok { tile, pos, inDir: dir }

nextDirection : Direction, Tile -> Result Direction [DeadEnd]
nextDirection = \in, tile ->
    expect tile != Start
    when (in, tile) is
        (Left, NorthEast) | (Right, NorthWest) | (Up, NorthSouth) -> Ok Up
        (Left, SouthEast) | (Right, SouthWest) | (Down, NorthSouth) -> Ok Down
        (Up, SouthWest) | (Down, NorthWest) | (Left, EastWest) -> Ok Left
        (Up, SouthEast) | (Down, NorthEast) | (Right, EastWest) -> Ok Right
        _ -> Err DeadEnd
