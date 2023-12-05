app "day1-part1-hello"
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
                sum + (twoDigitNumber line |> Result.withDefault 0)
                |> Step
                |> Task.ok

            End ->
                Num.toStr sum
                |> Stdout.line
                |> Task.map Done

isScalarDigit : U32 -> Bool
isScalarDigit = \scalar ->
    digit0 = 48
    scalar >= digit0 && scalar < digit0 + 10

MaybeDigit : [NoDigit, Digit U32]

walkUntilDigit :
    MaybeDigit,
    U32
    -> [
        Break [Digit U32],
        Continue MaybeDigit,
    ]
walkUntilDigit = \state, scalar ->
    if isScalarDigit scalar then
        Break (Digit scalar)
    else
        Continue state

digitToStr : U32 -> Str
digitToStr = \scalar ->
    when Str.appendScalar "" scalar is
        Ok s -> s
        Err InvalidScalar -> crash "invalid scalar"

maybeDigitToStr : MaybeDigit -> Result Str [NoDigit]
maybeDigitToStr = \m ->
    when m is
        Digit scalar -> Ok (digitToStr scalar)
        NoDigit -> Err NoDigit

firstDigit : Str -> Result Str [NoDigit]
firstDigit = \line ->
    Str.walkScalarsUntil line NoDigit walkUntilDigit
    |> maybeDigitToStr

lastDigit : Str -> Result Str [NoDigit]
lastDigit = \line ->
    scalars = Str.toScalars line
    List.walkBackwardsUntil scalars NoDigit walkUntilDigit
    |> maybeDigitToStr

firstAndLastDigit : Str -> Result Str [NoDigit]
firstAndLastDigit = \line ->
    when (firstDigit line, lastDigit line) is
        (Ok first, Ok last) -> Ok (Str.concat first last)
        _ -> Err NoDigit

twoDigitNumber : Str -> Result U8 [NoDigit]
twoDigitNumber = \line ->
    firstAndLastDigit line
    |> Result.map \digits ->
        when Str.toU8 digits is
            Ok n -> n
            Err InvalidNumStr -> crash "two digits to U8 failed"

expect firstDigit "1abc2" == Ok "1"
expect firstDigit "pqr3stu8vwx" == Ok "3"
expect firstDigit "pqr3stu" == Ok "3"
expect firstDigit "hello" == Err NoDigit
expect firstDigit "" == Err NoDigit

expect lastDigit "1abc2" == Ok "2"
expect lastDigit "pqr3stu8vwx" == Ok "8"
expect lastDigit "pqr3stu" == Ok "3"
expect lastDigit "hello" == Err NoDigit
expect lastDigit "" == Err NoDigit

expect firstAndLastDigit "1abc2" == Ok "12"
expect firstAndLastDigit "pqr3stu8vwx" == Ok "38"
expect firstAndLastDigit "pqr3stu" == Ok "33"
expect firstAndLastDigit "hello" == Err NoDigit
expect firstAndLastDigit "" == Err NoDigit

expect twoDigitNumber "1abc2" == Ok 12
expect twoDigitNumber "pqr3stu8vwx" == Ok 38
expect twoDigitNumber "pqr3stu" == Ok 33
expect twoDigitNumber "hello" == Err NoDigit
expect twoDigitNumber "" == Err NoDigit

expect "/" |> Str.toScalars |> List.map isScalarDigit == [Bool.false]
expect "0" |> Str.toScalars |> List.map isScalarDigit == [Bool.true]
expect "9" |> Str.toScalars |> List.map isScalarDigit == [Bool.true]
expect ":" |> Str.toScalars |> List.map isScalarDigit == [Bool.false]
