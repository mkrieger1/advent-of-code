app "day11-part1"
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
        galaxies <- parseGalaxies |> Task.await
        result <- solve galaxies |> Task.fromResult |> Task.await
        result |> Num.toStr |> Stdout.line

    handleErr = \err ->
        msg =
            when err is
                InvalidInput -> "Expected only '.' and '#' in input"
        msg |> Stderr.line

    run |> Task.onErr handleErr

Position : { row : Nat, col : Nat }

parseGalaxies : Task (List Position) _
parseGalaxies =
    walkLinesTry { galaxies: [], row: 0 } \{ galaxies, row }, line ->
        columnsWithGalaxy <- parseLine line |> Result.try
        galaxiesInRow = columnsWithGalaxy |> List.map \col -> { row, col }
        Ok {
            galaxies: galaxies |> List.concat galaxiesInRow,
            row: row + 1,
        }
    |> Task.map .galaxies

parseLine : Str -> Result (List Nat) _
parseLine = \line ->
    line
    |> Str.toUtf8
    |> List.walkWithIndex [] \state, c, i ->
        when c is
            '.' -> state
            '#' -> state |> List.append (Ok i)
            _ -> state |> List.append (Err InvalidInput)
    |> List.mapTry \x -> x

solve = \galaxies ->
    Ok 0
