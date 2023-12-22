app "day6-part2"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
        common: "../common/main.roc"
    }
    imports [
        pf.Stdout, pf.Stdin, pf.Task,
        common.Parse.{ numOrCrash }
    ]
    provides [main] to pf

main =
    races <- parseRace |> Task.await

    solve races
    |> Num.toStr
    |> Stdout.line

parseRace =
    firstLine <- Stdin.line |> Task.await
    secondLine <- Stdin.line |> Task.await

    when (firstLine, secondLine) is
        (Input first, Input second) ->
            Task.ok {
                time: parseLine first "Time",
                record: parseLine second "Distance"
            }
        _ -> crash "Expected two lines"

parseLine = \line, key ->
    when line |> Str.split ":" is
        [x, y] if x == key ->
            y |> Str.replaceEach " " "" |> numOrCrash "Expected a number"
        _ -> crash "Expected \"\(key): ...\""

solve = \{ time, record } ->
    distance = \holdTime ->
        speed = holdTime
        (time - holdTime) * speed

    List.range { start: After 0, end: Before time }
    |> List.map distance
    |> List.keepIf \d -> d > record
    |> List.len
