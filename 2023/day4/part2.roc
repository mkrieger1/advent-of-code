app "day4-part2"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
        common: "../common/main.roc"
    }
    imports [
        pf.Stdout, pf.Stdin, pf.Task,
        common.Io.{ walkLines },
        common.Parse.{ numOrCrash, splitSpaces, parseNumsSpaces }
    ]
    provides [main] to pf

# see https://github.com/roc-lang/roc/issues/5477
unused = Stdin.line

main =
    pile <- parsePile |> Task.await

    pile
    |> pileValue
    |> Num.toStr
    |> Stdout.line

# pile contains number of instances of card i at index i
parsePile =
    walkLines (Dict.empty {}) \pile, line ->
        card = parseLine line
        pile
        |> addOriginal card
        |> addCopies card

pileValue = \pile ->
    pile |> Dict.values |> List.sum

addToPile = \pile, card, amount ->
    current = pile |> Dict.get card |> Result.withDefault 0
    pile |> Dict.insert card (current + amount)

addOriginal = \pile, card ->
    pile |> addToPile card.number 1

addCopies = \pile, card ->
    n = card.number

    wins =
        card.have
        |> List.keepIf \number ->
            card.winning |> Set.contains number
        |> List.len

    winCards = List.range { start: At (n + 1), end: Length wins, step: 1 }

    instances =
        when pile |> Dict.get n is
            Ok i -> i
            Err KeyNotFound -> crash "we just added it"

    winCards
    |> List.walk pile \p, i ->
        p |> addToPile i instances

parseLine = \line ->
    when Str.split line " | " is
        [x, y] ->
            { number, have } = parseNumberHave x
            { number, have, winning: parseWinning y }

        _ -> crash "Input line is not like \"x | y\""

parseNumberHave = \s ->
    when Str.split s ": " is
        [x, y] -> {
            number: parseNumber x,
            have: parseNumsSpaces y
        }
        _ -> crash "\"numbers you have\" is not like \"x: y\""

parseNumber = \s ->
    when splitSpaces s is
        ["Card", x] -> numOrCrash x "invalid number: \(x)"
        _ -> crash "card is not like \"Card: x\""

parseWinning = \s ->
    parseNumsSpaces s
    |> Set.fromList
