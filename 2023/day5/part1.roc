app "day5-part1"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
        common: "../common/main.roc"
    }
    imports [
        pf.Stdout, pf.Stdin, pf.Task,
        Day5.{ parseAlmanac, getMapOrCrash }
    ]
    provides [main] to pf

# see https://github.com/roc-lang/roc/issues/5477
unused = Stdin.line

main =
    almanac <- parseAlmanac |> Task.await

    almanac
    |> minLocationForSeeds
    |> Num.toStr
    |> Stdout.line


minLocationForSeeds = \almanac ->
    getMap = \name ->
        almanac.maps |> getMapOrCrash name

    locations =
        almanac.seeds
        |> List.map \seed ->
            seed
            |> lookup (getMap "seed-to-soil")
            |> lookup (getMap "soil-to-fertilizer")
            |> lookup (getMap "fertilizer-to-water")
            |> lookup (getMap "water-to-light")
            |> lookup (getMap "light-to-temperature")
            |> lookup (getMap "temperature-to-humidity")
            |> lookup (getMap "humidity-to-location")

    when locations |> List.min is
        Ok location -> location
        Err ListWasEmpty ->
            expect almanac.seeds == []
            crash "There were no seeds"

lookup = \key, map ->
    result =
        map
        |> List.walkUntil NotFound \_, { destination, source, length } ->
            if source <= key && key < source + length then
                Found (key - source + destination) |> Break
            else
                NotFound |> Continue
    when result is
        Found x -> x
        NotFound -> key
