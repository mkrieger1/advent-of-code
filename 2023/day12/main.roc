app "day12-part1"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
        common: "../common/main.roc",
    }
    imports [
        pf.Stdin, pf.Stdout, pf.Stderr, pf.Task.{ Task },
        common.Io.{ walkLinesTry },
    ]
    provides [main] to pf

unused = Stdin.line

main =
    run =
        records <- parseRecords |> Task.await
        result1 <- records |> solve Part1 |> Task.fromResult |> Task.await
        result2 <- records |> solve Part2 |> Task.fromResult |> Task.await
        Stdout.line
            """
            Part 1: \(Num.toStr result1)
            Part 2: \(Num.toStr result2)
            """

    handleErr = \err ->
        msg =
            when err is
                InvalidInput s -> "Invalid input: \(s)"
                InvalidNumStr -> "Invalid input: expected a number"
        msg |> Stderr.line

    run |> Task.onErr handleErr

Condition : [Operational, Damaged, Unknown]
Records : { conditions : List Condition, groups : List Nat }

parseRecords : Task (List Records) _
parseRecords =
    walkLinesTry [] \collected, line ->
        records <- parseLine line |> Result.try
        collected |> List.append records |> Ok

parseLine : Str -> Result Records _
parseLine = \line ->
    when line |> Str.split " " is
        [x, y] ->
            conditions <- parseConditions x |> Result.try
            groups <- parseGroups y |> Result.try
            Ok { conditions, groups }

        _ -> Err (InvalidInput "Expected a line like \"x y\"")

parseConditions = \s ->
    s |> Str.toUtf8 |> List.mapTry \c ->
        when c is
            '.' -> Ok Operational
            '#' -> Ok Damaged
            '?' -> Ok Unknown
            _ -> Err (InvalidInput "Expected only '.#?'")

parseGroups = \s ->
    s |> Str.split "," |> List.mapTry Str.toNat

unfoldRecords = \records ->
    conditions =
        records.conditions
        |> List.repeat 5 |> List.intersperse [Unknown] |> List.join

    groups =
        records.groups
        |> List.repeat 5 |> List.join

    { conditions, groups }

dropPrefix = \list, elem ->
    when list is
        [first, .. as rest] if first == elem -> rest |> dropPrefix elem
        _ -> list

dropOperational = \conditions ->
    conditions |> dropPrefix Operational

prefixLength = \list, elem ->
    when list is
        [first, .. as rest] if first == elem ->
            1 + (rest |> prefixLength elem)

        _ -> 0

matchFirstDamaged :
    List Condition, Nat -> [NoMatch, Match (List Condition), ChoiceNeeded]
matchFirstDamaged = \conditions, expectedLength ->
    expect conditions |> prefixLength Operational == 0

    numDamaged = conditions |> prefixLength Damaged
    next = conditions |> List.get numDamaged

    when (numDamaged |> Num.compare expectedLength, next) is
        (GT, _) -> NoMatch

        (EQ, Ok Unknown) -> ChoiceNeeded
        (EQ, Ok Operational)
        | (EQ, Err OutOfBounds) ->
            conditions
            |> List.dropFirst (numDamaged + 1)
            |> dropOperational
            |> Match

        (EQ, Ok Damaged) -> crash "impossible"
        (EQ, _) -> crash "https://github.com/roc-lang/roc/issues/5530"

        (LT, Ok Unknown) -> ChoiceNeeded
        (LT, _) -> NoMatch

makeChoice :
    List Condition -> Result (Condition -> List Condition) [NoChoicesLeft]
makeChoice = \conditions ->
    i <-
        conditions
        |> List.findFirstIndex (\c -> c == Unknown)
        |> Result.mapErr \e -> when e is NotFound -> NoChoicesLeft
        |> Result.try
    choose = \condition ->
        conditions
        |> List.set i condition
        |> dropOperational
    Ok choose

arrangements = \{ conditions, groups } ->
    when (makeChoice conditions, groups) is
        (_, []) ->
            if conditions |> List.any \c -> c == Damaged then
                0
            else
                1

        (Err NoChoicesLeft, [first, .. as rest]) ->
            when conditions |> matchFirstDamaged first is
                NoMatch -> 0
                Match remaining ->
                    arrangements { conditions: remaining, groups: rest }

                ChoiceNeeded -> crash "impossible"

        (Ok choose, [first, .. as rest]) ->
            [Operational, Damaged]
            |> List.map \condition ->
                choice = choose condition
                when choice |> matchFirstDamaged first is
                    NoMatch -> 0
                    Match remaining ->
                        arrangements { conditions: remaining, groups: rest }

                    ChoiceNeeded ->
                        arrangements { conditions: choice, groups }
            |> List.sum

        _ -> crash "https://github.com/roc-lang/roc/issues/5530"

solve = \records, part ->
    unfold =
        when part is
            Part1 -> \x -> x
            Part2 -> unfoldRecords

    records
    |> List.map unfold
    |> List.map \{ conditions, groups } ->
        { conditions: dropOperational conditions, groups }
    |> List.map arrangements
    |> List.sum
    |> Ok
