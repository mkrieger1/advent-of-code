app "day1-part2"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
    }
    imports [pf.Stdout, pf.Stdin, pf.Task]
    provides [main] to pf

main =
    printSumLines lineValue

printSumLines = \evaluate ->
    sum <- sumLines evaluate |> Task.await
    Num.toStr sum |> Stdout.line

sumLines = \evaluate ->
    walkLines 0 \acc, line -> acc + (line |> evaluate |> Num.toNat)

walkLines = \init, accumulate ->
    Task.loop init \acc ->
        read <- Task.await Stdin.line
        result =
            when read is
                Input line -> accumulate acc line |> Step
                End -> acc |> Done
        Task.ok result

lineValue = \line ->
    game = parseLine line
    game.draws |> minimumCubes |> cubesPower

minimumCubes = \draws ->
    List.walk draws {red: 0, green: 0, blue: 0} \result, cubes ->
        {
            red: Num.max cubes.red result.red,
            green: Num.max cubes.green result.green,
            blue: Num.max cubes.blue result.blue
        }

cubesPower = \cubes ->
    cubes.red * cubes.green * cubes.blue

parseLine = \line ->
    when Str.split line ": " is
        [x, y] -> {
            num: parseHeader x,
            draws: parseDraws y
        }
        _ -> crash "Input line is not like \"x: y\""

numOrCrash = \s, help ->
    when Str.toNat s is
        Ok num -> num
        _ -> crash help

parseHeader = \header ->
    when Str.split header " " is
        ["Game", x] -> numOrCrash x "x is not a number in \"Game x\""
        _ -> crash "Header is not like \"Game x\""

parseDraws = \draws ->
    Str.split draws "; "
    |> List.map parseCubes

parseCubes = \cubes ->
    Str.split cubes ", "
    |> List.map parseCube
    |> joinCubes

parseCube = \cube ->
    when Str.split cube " " is
        [x, y] -> {
            num: numOrCrash x "x is not a number in cube record \"x y\"",
            color: parseColor y
        }
        _ -> crash "Cube record is not like \"x y\""

parseColor = \color ->
    when color is
        "red" -> Red
        "green" -> Green
        "blue" -> Blue
        _ -> crash "Invalid color"

joinCubes = \cubes ->
    List.walk cubes {red: 0, green: 0, blue: 0} \result, cube ->
        when cube.color is
            Red -> {result & red: cube.num}
            Green -> {result & green: cube.num}
            Blue -> {result & blue: cube.num}
