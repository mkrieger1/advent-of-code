app "day1-part2"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
    }
    imports [pf.Stdout, pf.Stdin, pf.Task.{ await }]
    provides [main] to pf

main =
    Task.loop 0 \sum ->
        read <- await Stdin.line
        when read is
            Input line ->
                sum
                + (
                    twoDigitNumber line
                    |> Result.withDefault 0
                    |> Num.toNat
                )
                |> Step
                |> Task.ok

            End ->
                Num.toStr sum
                |> Stdout.line
                |> Task.map Done

digitMap = [
    ("1", 1),
    ("2", 2),
    ("3", 3),
    ("4", 4),
    ("5", 5),
    ("6", 6),
    ("7", 7),
    ("8", 8),
    ("9", 9),
    ("one", 1),
    ("two", 2),
    ("three", 3),
    ("four", 4),
    ("five", 5),
    ("six", 6),
    ("seven", 7),
    ("eight", 8),
    ("nine", 9),
]

strStartsWithDigit = \s ->
    List.walkUntil digitMap (Err NoDigit) \state, (pattern, digit) ->
        if s |> Str.startsWith pattern then
            Break (Ok digit)
        else
            Continue state

strEndsWithDigit = \s ->
    List.walkUntil digitMap (Err NoDigit) \state, (pattern, digit) ->
        if s |> Str.endsWith pattern then
            Break (Ok digit)
        else
            Continue state

scalarToStr : U32 -> Str
scalarToStr = \scalar ->
    when Str.appendScalar "" scalar is
        Ok s -> s
        Err InvalidScalar -> crash "invalid scalar"

strFromScalars = \scalars ->
    scalars |> List.map scalarToStr |> Str.joinWith ""

strLen = \s ->
    s |> Str.toScalars |> List.len

takeFirst = \s, n ->
    s
    |> Str.toScalars
    |> List.takeFirst n
    |> strFromScalars

expect takeFirst "1abc2" 5 == "1abc2"
expect takeFirst "1abc2" 4 == "1abc"
expect takeFirst "1abc2" 1 == "1"
expect takeFirst "1abc2" 0 == ""

takeLast = \s, n ->
    s
    |> Str.toScalars
    |> List.takeLast n
    |> strFromScalars

expect takeLast "1abc2" 5 == "1abc2"
expect takeLast "1abc2" 4 == "abc2"
expect takeLast "1abc2" 1 == "2"
expect takeLast "1abc2" 0 == ""

firstDigit : Str -> Result U8 [NoDigit]
firstDigit = \line ->
    List.range { start: At (strLen line), end: At 1 }
    |> List.walkUntil (Err NoDigit) \state, i ->
        when line |> takeLast i |> strStartsWithDigit is
            Ok d -> Break (Ok d)
            _ -> Continue state

lastDigit : Str -> Result U8 [NoDigit]
lastDigit = \line ->
    List.range { start: At (strLen line), end: At 1 }
    |> List.walkUntil (Err NoDigit) \state, i ->
        when line |> takeFirst i |> strEndsWithDigit is
            Ok d -> Break (Ok d)
            _ -> Continue state

twoDigitNumber : Str -> Result U8 [NoDigit]
twoDigitNumber = \line ->
    when (firstDigit line, lastDigit line) is
        (Ok first, Ok last) -> Ok (10 * first + last)
        _ -> Err NoDigit

expect strStartsWithDigit "1abc2" == Ok 1
expect strStartsWithDigit "pqr3stu8vwx" == Err NoDigit
expect strStartsWithDigit "pqr3stu" == Err NoDigit
expect strStartsWithDigit "hello" == Err NoDigit
expect strStartsWithDigit "" == Err NoDigit
expect strStartsWithDigit "abcone2threexyz" == Err NoDigit
expect strStartsWithDigit "one2threexyz" == Ok 1

expect firstDigit "1abc2" == Ok 1
expect firstDigit "pqr3stu8vwx" == Ok 3
expect firstDigit "pqr3stu" == Ok 3
expect firstDigit "hello" == Err NoDigit
expect firstDigit "" == Err NoDigit
expect firstDigit "abcone2threexyz" == Ok 1

expect lastDigit "1abc2" == Ok 2
expect lastDigit "pqr3stu8vwx" == Ok 8
expect lastDigit "pqr3stu" == Ok 3
expect lastDigit "hello" == Err NoDigit
expect lastDigit "" == Err NoDigit
expect lastDigit "abcone2threexyz" == Ok 3

expect twoDigitNumber "1abc2" == Ok 12
expect twoDigitNumber "pqr3stu8vwx" == Ok 38
expect twoDigitNumber "pqr3stu" == Ok 33
expect twoDigitNumber "hello" == Err NoDigit
expect twoDigitNumber "" == Err NoDigit
