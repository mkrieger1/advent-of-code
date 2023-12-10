app "day3-part1"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
    }
    imports [pf.Stdout, pf.Stdin, pf.Task]
    provides [main] to pf

walkLines = \init, accumulate ->
    Task.loop init \acc ->
        read <- Task.await Stdin.line
        result =
            when read is
                Input line -> accumulate acc line |> Step
                End -> acc |> Done
        Task.ok result

main =
    schematic <- parseSchematic |> Task.await

    schematic
    |> partNumbers
    |> List.sum
    |> Num.toStr
    |> Stdout.line

parseSchematic =
    walkLines [] \schematic, line ->
        schematic
        |> List.append (parseLine line)

parseLine = \line -> {
    numbers: parseNumbers line,
    symbols: parseSymbols line
}

isDigit = \char ->
    '0' <= char && char <= '9'

parseNumbers = \line ->
    asDigit = \char ->
        if isDigit char then
            Digit char
        else
            NotDigit

    toNum = \digits ->
        when digits is
            [] -> 0
            [.. as rest, d] ->
                n = d - '0' |> Num.toNat
                10 * toNum rest + n

    nextState = \{current, found}, digit, i ->
        when (digit, current) is
            (Digit d, Outside) -> {
                current: Inside {
                    digits: [d],
                    begin: i
                },
                found
            }
            (Digit d, Inside {digits, begin}) -> {
                current: Inside {
                    digits: List.append digits d,
                    begin
                },
                found
            }
            (NotDigit, Inside {digits, begin}) -> {
                current: Outside,
                found: List.append found {
                    value: toNum digits,
                    begin: begin,
                    end: i - 1
                }
            }
            _ -> {current, found}

    line
    |> Str.toUtf8
    |> List.map asDigit
    |> List.append NotDigit
    |> List.walkWithIndex {current: Outside, found: []} nextState
    |> .found

expect parseNumbers "" == []
expect parseNumbers "123" == [{value: 123, begin: 0, end: 2}]
expect parseNumbers ".123" == [{value: 123, begin: 1, end: 3}]
expect parseNumbers "123..." == [{value: 123, begin: 0, end: 2}]
expect parseNumbers "123.456." == [
    {value: 123, begin: 0, end: 2},
    {value: 456, begin: 4, end: 6}
]

parseSymbols = \line ->
    Str.toUtf8 line
    |> List.walkWithIndex [] \indices, char, i ->
        when char is
            c if isDigit c -> indices
            '.' -> indices
            _ -> List.append indices i

partNumbers = \schematic ->
    partNumbersOfRow = \{numbers}, i ->
        symbols =
            List.range {
                start: At (i |> Num.subSaturated 1),
                end: At (i + 1)
            }
            |> List.map \j ->
                when List.get schematic j is
                    Ok row -> row.symbols
                    Err OutOfBounds -> []
            |> List.join

        numbers
        |> List.keepIf \{begin, end} ->
            List.any symbols \pos -> (
                pos >= begin |> Num.subSaturated 1
                && pos <= end + 1
            )
        |> List.map .value

    schematic
    |> List.mapWithIndex partNumbersOfRow
    |> List.join
