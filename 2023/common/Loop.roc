interface Loop
    exposes [loop]
    imports []

## Call a function repeatedly, until it fails with `err`
## or completes with `done`.
loop :
    state,
    (state -> Result [Continue state, Break done] err)
    -> Result done err
loop = \state, step ->
    init = step state

    recurse = \result ->
        when result is
            Err e -> Err e
            Ok (Break v) -> Ok v
            Ok (Continue s) -> step s |> recurse

    recurse init
