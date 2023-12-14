app "day4-part1"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
        common: "../common/main.roc"
    }
    imports [
        pf.Stdout, pf.Stdin, pf.Task,
        common.Io.{ printSumLines },
        common.Parse.{ parseNumsSpaces }
    ]
    provides [main] to pf

# see https://github.com/roc-lang/roc/issues/5477
unused = U Stdout.line Stdin.line Task.ok

main =
    printSumLines lineValue

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

parseHave = \s ->
    when Str.split s ": " is
        [_x, y] -> parseNumsSpaces y
        _ -> crash "\"numbers you have\" is not like \"x: y\""

parseWinning = \s ->
    parseNumsSpaces s
    |> Set.fromList
