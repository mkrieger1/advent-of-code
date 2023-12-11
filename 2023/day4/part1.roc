app "day4-part1"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
    }
    imports [pf.Stdout, pf.Stdin, pf.Task]
    provides [main] to pf

main =
    printSumLines lineValue

printSumLines = \evaluate ->
    sum <- sumLines evaluate |> Task.await
    Num.toStr sum |> Stdout.line

sumLines = \evaluate ->
    walkLines 0 \acc, line -> acc + (line |> evaluate |> Num.toNat)

walkLines = \init, accumulate ->
    Task.loop init \acc ->
        read <- Task.await Stdin.line
        result =
            when read is
                Input line -> accumulate acc line |> Step
                End -> acc |> Done
        Task.ok result

lineValue = \line ->
    card = parseLine line
    card.have
    |> List.keepIf \number ->
        card.winning |> Set.contains number
    |> List.len
    |> \n ->
        if n == 0 then
            0
        else
            2 |> Num.powInt (n - 1)

parseLine = \line ->
    when Str.split line " | " is
        [x, y] -> {
            have: parseHave x,
            winning: parseWinning y
        }
        _ -> crash "Input line is not like \"x | y\""

numOrCrash = \s, help ->
    when Str.toNat s is
        Ok num -> num
        _ -> crash help

splitSpaces = \s ->
    Str.split s " "
    |> List.keepIf \part -> Str.trim part != ""

parseNumsSpaces = \s ->
    splitSpaces s
    |> List.map \n -> numOrCrash n "invalid number: \(n)"

parseHave = \s ->
    when Str.split s ": " is
        [_x, y] -> parseNumsSpaces y
        _ -> crash "\"numbers you have\" is not like \"x: y\""

parseWinning = \s ->
    parseNumsSpaces s
    |> Set.fromList
