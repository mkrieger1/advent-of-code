interface Io
    exposes [
        walkLines,
        walkLinesTry,
        printSumLines,
    ]
    imports [pf.Stdin, pf.Stdout, pf.Task.{ Task }]

walkLines : a, (a, Str -> a) -> Task a *
walkLines = \init, accumulate ->
    walkLinesTry init (\acc, line -> accumulate acc line |> Ok)

walkLinesTry : a, (a, Str -> Result a b) -> Task a b
walkLinesTry = \init, accumulate ->
    Task.loop init \acc ->
        read <- Task.await Stdin.line
        when read is
            End -> Done acc |> Task.ok
            Input line ->
                when accumulate acc line is
                    Err e -> e |> Task.err
                    Ok a -> Step a |> Task.ok

sumLines = \evaluate ->
    walkLines 0 \acc, line -> acc + (line |> evaluate |> Num.toNat)

printSumLines = \evaluate ->
    sum <- sumLines evaluate |> Task.await
    Num.toStr sum |> Stdout.line
