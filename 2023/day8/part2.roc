app "day8-part2"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
        common: "../common/main.roc"
    }
    imports [
        pf.Stdout, pf.Stdin, pf.Task,
        Parse.{ parseMaps }
    ]
    provides [main] to pf

unused = Stdin.line

main =
    maps <- parseMaps |> Task.await

    navigate maps
    |> Num.toStr
    |> Stdout.line

endsWith = \label, letter ->
    when label |> Str.toUtf8 is
        [_, _, c] if c == letter -> Bool.true
        _ -> Bool.false

isStart = \label -> label |> endsWith 'A'

isEnd = \label -> label |> endsWith 'Z'

navigateNextEnd = \ghost, map ->
    numInstructions = List.len map.instructions

    nextLocation = \{ steps, location } ->
        index = steps % numInstructions

        instruction =
            when map.instructions |> List.get index is
                Err OutOfBounds -> crash "Should not happen"
                Ok i -> i

        choices =
            when map.network |> Dict.get location is
                Err KeyNotFound -> crash "Location not in map"
                Ok c -> c

        when instruction is
            Left -> choices.left
            Right -> choices.right

    doSteps = \current ->
        next = {
            steps: current.steps + 1,
            location: nextLocation current
        }
        if isEnd next.location then
            next
        else
            doSteps next

    doSteps ghost

navigate = \map ->
    ghosts =
        Dict.keys map.network
        |> List.keepIf isStart
        |> List.map \location -> { steps: 0, location }
        |> List.map \ghost -> ghost |> navigateNextEnd map

    n = List.len map.instructions

    # This works under the assumption that the path of each ghost loops back
    # from the first xxZ location to the starting position, and that the length
    # of the loop is a multiple of the number of instructions, and that this
    # multiple is a prime number. So we don't even need to do a full LCM
    # calculation.
    ghosts
        |> List.map \ghost -> ghost.steps // n
        |> List.product
        |> \x -> x * n
