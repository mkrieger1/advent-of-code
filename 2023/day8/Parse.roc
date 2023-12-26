interface Parse
    exposes [parseMaps]
    imports [
        common.Io.{ walkLines },
        pf.Stdin, pf.Task,
    ]

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
