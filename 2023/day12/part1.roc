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

Condition : [ Operational, Damaged, Unknown ]
Springs : { conditions : (List Condition), damagedGroups : (List Nat) }

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
            damagedGroups <- parseGroups y |> Result.try
            Ok { conditions, damagedGroups }

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

checkNoDamaged :
    List Condition ->
    [NoDamaged, SomeDamaged, PossibleDamaged (List Condition)]
checkNoDamaged = \conditions ->
    if conditions |> List.any \c -> c == Damaged then
        SomeDamaged
    else
        when conditions |> List.findFirstIndex \c -> c == Unknown is
            Err NotFound -> NoDamaged
            Ok i -> conditions |> List.dropFirst i |> PossibleDamaged

checkDamagedPrefix :
    (List Condition), Nat ->
    [NoMatch, Match (List Condition), PossibleMatch (List Condition)]
checkDamagedPrefix = \conditions, damagedGroup ->
    numDamaged = conditions |> prefixLength Damaged
    next = conditions |> List.get numDamaged

    if numDamaged > damagedGroup then
        NoMatch
    else if numDamaged == damagedGroup then
        when next is
            Ok Unknown -> conditions |> PossibleMatch
            Ok Operational | Err OutOfBounds ->
                conditions |> List.dropFirst (numDamaged + 1) |> Match
            _ -> crash "impossible"
    else
        when next is
            Ok Unknown -> conditions |> PossibleMatch
            _ -> NoMatch

checkFirstGroup : Springs -> [NoMatch, Match, PossibleMatch Springs]
checkFirstGroup = \{ conditions, damagedGroups } ->
    when damagedGroups is
        [] ->
            when conditions |> checkNoDamaged is
                NoDamaged -> Match
                SomeDamaged -> NoMatch
                PossibleDamaged remainingConditions ->
                    PossibleMatch {
                        conditions: remainingConditions,
                        damagedGroups
                    }
        [first, .. as rest] ->
            checkResult =
                conditions
                |> dropPrefix Operational
                |> checkDamagedPrefix first
            when checkResult is
                NoMatch -> NoMatch
                Match remainingConditions ->
                    PossibleMatch {
                        conditions: remainingConditions,
                        damagedGroups: damagedGroups |> List.dropFirst 1
                    }
                PossibleMatch remainingConditions ->
                    PossibleMatch {
                        conditions: remainingConditions,
                        damagedGroups
                    }

checkAllGroups : Springs -> [NoMatch, Match]
checkAllGroups = \springs ->
    when checkFirstGroup springs is
        NoMatch -> NoMatch
        Match -> Match
        PossibleMatch remaining -> checkAllGroups remaining

makeChoice = \conditions ->
    i <-
        conditions
        |> List.findFirstIndex (\c -> c == Unknown)
        |> Result.mapErr \e -> when e is NotFound -> NoChoicesLeft
        |> Result.try
    choose = \condition -> conditions |> List.set i condition
    Ok choose

possibleArrangements = \{ conditions, damagedGroups } ->
    when makeChoice conditions is
        Err NoChoicesLeft ->
            when checkAllGroups { conditions, damagedGroups } is
                NoMatch -> 0
                Match -> 1
        Ok choose ->
            [Operational, Damaged]
            |> List.map \condition ->
                choice = { conditions: choose condition, damagedGroups }
                when checkFirstGroup choice is
                    NoMatch -> 0
                    Match -> 1
                    PossibleMatch remaining -> possibleArrangements remaining
            |> List.sum

solve = \springs ->
    springs
    |> List.map possibleArrangements
    |> List.sum
    |> Ok
