interface Day5
    exposes [parseAlmanac, getMapOrCrash]
    imports [
        pf.Task,
        common.Io.{ walkLines },
        common.Parse.{ parseNumsSpaces },
    ]

MapPart : { destination : Nat, source : Nat, length : Nat }
Map : List MapPart
Almanac : { seeds : List Nat, maps : Dict Str Map }

parseAlmanac : Task.Task Almanac *
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

getMapOrCrash : Dict Str Map, Str -> Map
getMapOrCrash = \maps, name ->
    when maps |> Dict.get name is
        Ok map -> map
        _ -> crash "Expected map \"\(name)\""
