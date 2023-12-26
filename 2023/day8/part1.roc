app "day8-part1"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
        common: "../common/main.roc"
    }
    imports [
        pf.Stdin, pf.Stdout, pf.Task,
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

    nextStep = \steps, location ->
        if location == "ZZZ" then
            steps
        else
            nextStep (steps + 1) (nextLocation steps location)

    nextStep 0 "AAA"
