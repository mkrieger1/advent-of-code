app "day1-part2"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
        common: "../common/main.roc"
    }
    imports [
        pf.Stdout, pf.Stdin, pf.Task,
        common.Io.{ printSumLines },
        common.Parse.{ numOrCrash }
    ]
    provides [main] to pf

# see https://github.com/roc-lang/roc/issues/5477
unused = U Stdout.line Stdin.line Task.ok

main =
    printSumLines lineValue

lineValue = \line ->
    game = parseLine line
    if game.draws |> List.all checkPossible then
        game.num
    else
        0

checkPossible = \draw ->
    draw.red <= 12 && draw.green <= 13 && draw.blue <= 14

parseLine = \line ->
    when Str.split line ": " is
        [x, y] -> {
            num: parseHeader x,
            draws: parseDraws y
        }
        _ -> crash "Input line is not like \"x: y\""

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
