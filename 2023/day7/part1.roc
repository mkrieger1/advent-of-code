app "day7-part1"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
        common: "../common/main.roc"
    }
    imports [
        pf.Stdout, pf.Stdin, pf.Task,
        common.Io.{ walkLines },
        common.Parse.{ numOrCrash, splitSpaces }
    ]
    provides [main] to pf

# see https://github.com/roc-lang/roc/issues/5477
unused = Stdin.line

main =
    hands <- parseHands |> Task.await

    solve hands
    |> Num.toStr
    |> Stdout.line

parseHands =
    walkLines [] \hands, line ->
        hand = parseHand line
        hands |> List.append hand

parseHand = \line ->
    when splitSpaces line is
        [x, y] ->
            cards = Str.toUtf8 x
            bid = numOrCrash y "Expected a number"
            { cards, bid }
        _ -> crash "Expected \"cards bid\""

handType = \cards ->
    counts =
        cards
        |> List.walk (Dict.empty {}) \countState, card ->
            countState |> Dict.update card \existing ->
                when existing is
                    Missing -> Present 1
                    Present count -> Present (count + 1)

    when counts |> Dict.values |> List.sortDesc is
        [5] -> FiveOfAKind
        [4, 1] -> FourOfAKind
        [3, 2] -> FullHouse
        [3, 1, 1] -> ThreeOfAKind
        [2, 2, 1] -> TwoPair
        [2, 1, 1, 1] -> OnePair
        [1, 1, 1, 1, 1] -> HighCard
        _ -> crash "Unexpected cards"

typeScore = \cards ->
    types = [
        HighCard,
        OnePair,
        TwoPair,
        ThreeOfAKind,
        FullHouse,
        FourOfAKind,
        FiveOfAKind
    ]
    types
    |> List.findFirstIndex \type -> type == (handType cards)
    |> Result.withDefault (List.len types)

cardScore = \card ->
    labels = "23456789TJQKA" |> Str.toUtf8
    labels
    |> List.findFirstIndex \label -> label == card
    |> Result.withDefault (List.len labels)

cardsCmp = \first, second ->
    when (first, second) is
        ([a, .. as rest1], [b, .. as rest2]) ->
            when (cardScore a) |> Num.compare (cardScore b) is
                EQ -> cardsCmp rest1 rest2
                cmp -> cmp
        _ -> crash "Unexpected cards"

handCmp = \first, second ->
    when (typeScore first.cards) |> Num.compare (typeScore second.cards) is
        EQ -> cardsCmp first.cards second.cards
        cmp -> cmp

solve = \hands ->
    hands
    |> List.sortWith handCmp
    |> List.mapWithIndex \hand, i -> hand.bid * (i + 1)
    |> List.sum
