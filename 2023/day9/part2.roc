app "day9-part1"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
        common: "../common/main.roc"
    }
    imports [
        pf.Stdin, pf.Stdout, pf.Stderr, pf.Task.{ Task },
        common.Io.{ walkLinesTry },
        common.Parse.{ splitSpaces }
    ]
    provides [main] to pf

unused = Stdin.line

# error handling learned from
# https://roc.zulipchat.com/#narrow/stream/231634-beginners/topic/Tasks.20and.20Error.20handling
main =
    run =
        sequences <- parseSequences |> Task.await
        result <- solve sequences |> Task.fromResult |> Task.await
        result |> Num.toStr |> Stdout.line

    handleErr = \err ->
        msg =
            when err is
                InvalidNumStr -> "Parsing numbers failed"
                ListWasEmpty -> "Input included empty lines"
        msg |> Stderr.line

    run |> Task.onErr handleErr

Sequence : List I32

parseSequences : Task (List Sequence) _
parseSequences =
    walkLinesTry [] \sequences, line ->
        seq <- parseSequence line |> Result.try
        sequences |> List.append seq |> Ok

parseSequence : Str -> Result Sequence _
parseSequence = \line ->
    line
    |> splitSpaces
    |> List.mapTry Str.toI32

solve : List Sequence -> Result I32 _
solve = \sequences ->
    extrapolated <-
        sequences
        |> List.mapTry extrapolate
        |> Result.try

    extrapolated |> List.sum |> Ok

allSame : Sequence -> Bool
allSame = \sequence ->
    when sequence is
        [] -> Bool.true
        [x, .. as rest] -> rest |> List.all \y -> y == x

derivative : Sequence -> Sequence
derivative = \sequence ->
    when sequence is
        [] -> []
        [x, .. as rest] ->
            when rest is
                [] -> []
                [y, ..] -> [y - x] |> List.concat (derivative rest)

extrapolate : Sequence -> Result I32 _
extrapolate = \sequence ->
    first <- List.first sequence |> Result.try
    if allSame sequence then
        first |> Ok
    else
        next <- derivative sequence |> extrapolate |> Result.try
        first - next |> Ok
