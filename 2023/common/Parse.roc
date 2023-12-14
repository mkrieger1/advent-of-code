interface Parse
    exposes [
        numOrCrash,
        splitSpaces,
        parseNumsSpaces
    ]
    imports []

numOrCrash = \s, help ->
    when Str.toNat s is
        Ok num -> num
        _ -> crash help

splitSpaces = \s ->
    Str.split s " "
    |> List.keepIf \part -> Str.trim part != ""

parseNumsSpaces = \s ->
    splitSpaces s
    |> List.map \n -> numOrCrash n "invalid number: \(n)"
