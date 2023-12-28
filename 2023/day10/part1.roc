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
        msg |> Stderr.line

    run |> Task.onErr handleErr

Index : Nat
Position : { row : Index, col : Index }
Tile : [
    NorthSouth, EastWest, NorthEast, NorthWest, SouthWest, SouthEast,
    Ground, Start,
]
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

solve : Maze -> Result Nat _
solve = \maze ->
    Ok 0
