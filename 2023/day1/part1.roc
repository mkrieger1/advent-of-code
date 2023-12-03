app "day1-part1-hello"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.5.0/Cufzl36_SnJ4QbOoEmiJ5dIpUxBvdB3NEySvuH82Wio.tar.br" }
    imports [pf.Stdout, pf.Stdin, pf.Task.{ await }]
    provides [main] to pf

main =
    line <- await Stdin.line
    first = firstDigit line
    answer =
        when first is
            Ok s -> s
            Err NoDigit -> "Invalid input: no digits found"
    Stdout.line answer

isScalarDigit : U32 -> Bool
isScalarDigit = \scalar ->
    digit0 = 48
    scalar >= digit0 && scalar <= digit0 + 10

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

expect firstDigit "1abc2" == Ok "1"
expect firstDigit "pqr3stu8vwx" == Ok "3"
expect firstDigit "hello" == Err NoDigit
expect firstDigit "" == Err NoDigit

expect lastDigit "1abc2" == Ok "2"
expect lastDigit "pqr3stu8vwx" == Ok "8"
expect lastDigit "hello" == Err NoDigit
expect lastDigit "" == Err NoDigit
