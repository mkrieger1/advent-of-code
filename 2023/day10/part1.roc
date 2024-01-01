app "day10-part1"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
        common: "../common/main.roc",
    }
    imports [
        pf.Stdin, pf.Stdout, pf.Stderr, pf.Task.{ Task },
        common.Loop.{ loop },
        Day10.{
            Direction, Maze, Position,
            findStart, move, nextDirection, parseMaze,
        }
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

solve : Maze -> Result Nat _
solve = \maze ->
    start <- maze |> findStart |> Result.try
    dir <- maze |> initialDirection start |> Result.try
    init <- maze |> move start dir |> Result.try

    step = \{ state: { tile, pos, inDir }, count } ->
        if tile == Start then
            expect pos == start  # assume there is only one start
            Break count |> Ok
        else
            outDir <- nextDirection inDir tile |> Result.try
            state <- maze |> move pos outDir |> Result.try
            Continue { state, count: count + 1 } |> Ok

    loopLength <- loop { state: init, count: 1 } step |> Result.try
    Ok (loopLength // 2)
