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
        springs <- parseSprings |> Task.await
        result <- solve springs |> Task.fromResult |> Task.await
        result |> Num.toStr |> Stdout.line

    handleErr = \err ->
        msg =
            when err is
                InvalidInput s -> "Invalid input: \(s)"
                InvalidNumStr -> "Invalid input: expected a number"
        msg |> Stderr.line

    run |> Task.onErr handleErr

Condition : [Operational, Damaged, Unknown]
Springs : { conditions : List Condition, groups : List Nat }

parseSprings : Task (List Springs) _
parseSprings =
    walkLinesTry [] \collectedSprings, line ->
        springs <- parseLine line |> Result.try
        collectedSprings |> List.append springs |> Ok

parseLine : Str -> Result Springs _
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

dropPrefix = \list, elem ->
    when list is
        [first, .. as rest] if first == elem -> rest |> dropPrefix elem
        _ -> list

prefixLength = \list, elem ->
    when list is
        [first, .. as rest] if first == elem ->
            1 + (rest |> prefixLength elem)

        _ -> 0

matchFirstDamaged :
    List Condition, Nat -> [NoMatch, Match (List Condition), ChoiceNeeded]
matchFirstDamaged = \conditions, expectedLength ->
    opDropped = conditions |> dropPrefix Operational
    numDamaged = opDropped |> prefixLength Damaged
    next = opDropped |> List.get numDamaged

    when (numDamaged |> Num.compare expectedLength, next) is
        (GT, _) -> NoMatch

        (EQ, Ok Unknown) -> ChoiceNeeded
        (EQ, Ok Operational)
        | (EQ, Err OutOfBounds) ->
            opDropped |> List.dropFirst (numDamaged + 1) |> Match

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
    choose = \condition -> conditions |> List.set i condition
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

solve = \springs ->
    springs
    |> List.map arrangements
    |> List.sum
    |> Ok
