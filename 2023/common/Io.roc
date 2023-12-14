interface Io
    exposes [
        walkLines,
        printSumLines,
    ]
    imports [pf.Stdin, pf.Stdout, pf.Task]

walkLines = \init, accumulate ->
    Task.loop init \acc ->
        read <- Task.await Stdin.line
        result =
            when read is
                Input line -> accumulate acc line |> Step
                End -> acc |> Done
        Task.ok result

sumLines = \evaluate ->
    walkLines 0 \acc, line -> acc + (line |> evaluate |> Num.toNat)

printSumLines = \evaluate ->
    sum <- sumLines evaluate |> Task.await
    Num.toStr sum |> Stdout.line
