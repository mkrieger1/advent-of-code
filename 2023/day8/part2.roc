app "day8-part2"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
        common: "../common/main.roc"
    }
    imports [
        pf.Stdout, pf.Stdin, pf.Task,
        common.Io.{ walkLines },
    ]
    provides [main] to pf

main =
    maps <- parseMaps |> Task.await

    navigate maps
    |> Num.toStr
    |> Stdout.line

parseMaps =
    instructionsLine <- Stdin.line |> Task.await
    instructions =
        when instructionsLine is
            Input s -> s |> Str.toUtf8
            End -> crash "Expected at least one line"

    emptyLine <- Stdin.line |> Task.await
    expect emptyLine == Input ""

    network <- parseNetwork |> Task.await

    Task.ok { instructions, network }

parseNetwork =
    walkLines (Dict.empty {}) \nodes, line ->
        { source, left, right } = parseNode line
        nodes |> Dict.insert source { left, right }

parseNode = \line ->
    unwrap = \result, msg ->
        when result is
            Err _ -> crash msg
            Ok x -> x

    stripParens = \s ->
        s
        |> Str.splitFirst "(" |> unwrap "Expected \"(...\""
        |> .after
        |> Str.splitFirst ")" |> unwrap "Expected \"...)\""
        |> .before

    splitComma = \s ->
        when s |> Str.split ", " is
            [x, y] -> { left: x, right: y }
            _ -> crash "Expected \"x, y\""

    parseDest = \s ->
        s
        |> stripParens
        |> splitComma

    when line |> Str.split " = " is
        [source, dest] ->
            { left, right } = parseDest dest
            { source, left, right }
        _ -> crash "Expected \"source dest\""

navigate = \map ->
    endsWith = \label, letter ->
        when label |> Str.toUtf8 is
            [_, _, c] if c == letter -> Bool.true
            _ -> Bool.false

    startLocations =
        Dict.keys map.network
        |> List.keepIf \label -> label |> endsWith 'A'

    isEnd = \locations ->
        locations
        |> List.all \label -> label |> endsWith 'Z'

    nextLocation = \steps, location ->
        index = steps % (map.instructions |> List.len)

        instruction =
            when map.instructions |> List.get index is
                Err OutOfBounds -> crash "Should not happen"
                Ok 'L' -> Left
                Ok 'R' -> Right
                Ok _ -> crash "Invalid instruction"

        choices =
            when map.network |> Dict.get location is
                Err KeyNotFound -> crash "Location not in map"
                Ok c -> c

        when instruction is
            Left -> choices.left
            Right -> choices.right

    nextStep = \steps, locations ->
        if isEnd locations then
            steps
        else
            nextLocations =
                locations
                |> List.map \location ->
                    nextLocation steps location
            nextStep (steps + 1) nextLocations

    nextStep 0 startLocations
