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

parseSequences : Task (List (List I32)) _
parseSequences =
    walkLinesTry [] \sequences, line ->
        seq <- parseSequence line |> Result.try
        sequences |> List.append seq |> Ok

parseSequence : Str -> Result (List I32) _
parseSequence = \line ->
    line
    |> splitSpaces
    |> List.mapTry Str.toI32

solve : List (List I32) -> Result I32 _
solve = \sequences ->
    extrapolated <-
        sequences
        |> List.mapTry extrapolate
        |> Result.try

    extrapolated |> List.sum |> Ok

extrapolate : List I32 -> Result I32 _
extrapolate = \sequence ->
    List.last sequence
