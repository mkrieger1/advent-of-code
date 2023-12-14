app "day5-part1"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
        common: "../common/main.roc"
    }
    imports [
        pf.Stdout, pf.Stdin, pf.Task,
        common.Io.{ walkLines },
        common.Parse.{ parseNumsSpaces }
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

parseAlmanac =
    { state: ExpectSeeds, almanac: { seeds: [], maps: Dict.empty {} } }
    |> walkLines parseLine
    |> Task.map .almanac

parseLine = \{ state, almanac }, line ->
    parseSeeds = \_ ->
        when Str.split line ": " is
            ["seeds", x] ->
                {
                    state: ExpectBlankLine,
                    almanac: { almanac & seeds: parseNumsSpaces x },
                }

            _ -> crash "Expected \"seeds: x\""

    parseMapHeader = \_ ->
        when Str.split line " " is
            [name, "map:"] ->
                maps = almanac.maps |> Dict.insert name []
                {
                    state: ReadMap name,
                    almanac: { almanac & maps },
                }

            _ -> crash "Expected \"x map:\""

    parseMapEntry = \name ->
        when parseNumsSpaces line is
            [destination, source, length] ->
                map =
                    almanac.maps
                    |> getMapOrCrash name
                    |> List.append { destination, source, length }
                maps =
                    almanac.maps
                    |> Dict.insert name map
                { state, almanac: { almanac & maps } }

            _ -> crash "Expected \"destination source length\""

    when (state, line) is
        (ExpectSeeds, _) -> parseSeeds {}
        (ExpectBlankLine, "") -> { state: ExpectMap, almanac }
        (ExpectBlankLine, _) -> crash "Expected blank line"
        (ExpectMap, _) -> parseMapHeader {}
        (ReadMap _, "") -> { state: ExpectMap, almanac }
        (ReadMap name, _) -> parseMapEntry name

getMapOrCrash = \maps, name ->
    when maps |> Dict.get name is
        Ok map -> map
        _ -> crash "Expected map \"\(name)\""

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
