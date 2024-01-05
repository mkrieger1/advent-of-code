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
                NoGalaxies -> "Input contained no galaxies"
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

missingCoords = \coords ->
    maxCoord <-
        coords
        |> List.max
        |> Result.mapErr \e -> when e is ListWasEmpty -> NoGalaxies
        |> Result.try

    allCoords =
        List.range { start: At 0, end: At maxCoord }
        |> Set.fromList

    coords
    |> List.walk allCoords \remaining, i -> remaining |> Set.remove i
    |> Set.toList
    |> List.sortAsc
    |> Ok

# assuming missing is sorted in ascending order
numMissingSmallerThan = \missing, target ->
    missing
    |> List.walkUntil 0 \count, elem ->
        if elem < target then
            count + 1 |> Continue
        else
            count |> Break

expandUniverse = \galaxies ->
    emptyRows <- galaxies |> List.map .row |> missingCoords |> Result.try
    emptyColumns <- galaxies |> List.map .col |> missingCoords |> Result.try

    galaxies
    |> List.map \{ row, col } ->
        rowExpansion = emptyRows |> numMissingSmallerThan row
        colExpansion = emptyColumns |> numMissingSmallerThan col
        { row: row + rowExpansion, col: col + colExpansion }
    |> Ok

allPairs = \items ->
    makePairs = \pairs, remaining ->
        when remaining is
            [] ->
                pairs
            [first, .. as rest] ->
                newPairs = rest |> List.map \other -> (first, other)
                makePairs (pairs |> List.concat newPairs) rest

    makePairs [] items

distance1d = \first, second ->
    (small, large) =
        if first <= second then
            (first, second)
        else
            (second, first)

    large - small

distance = \( first, second ) ->
    rowDistance = distance1d first.row second.row
    colDistance = distance1d first.col second.col
    rowDistance + colDistance

solve = \galaxies ->
    expandedGalaxies <- expandUniverse galaxies |> Result.try
    expandedGalaxies
    |> allPairs
    |> List.map distance
    |> List.sum
    |> Ok
