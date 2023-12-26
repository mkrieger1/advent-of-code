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
                Ok i -> i

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
