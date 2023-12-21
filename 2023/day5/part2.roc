app "day5-part1"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
        common: "../common/main.roc"
    }
    imports [
        pf.Stdout, pf.Stdin, pf.Task,
        Day5.{ Almanac, MapPart, Map, parseAlmanac, getMapOrCrash }
    ]
    provides [main] to pf

# see https://github.com/roc-lang/roc/issues/5477
unused = Stdin.line

Range : { first : Nat, last : Nat }

main =
    almanac <- parseAlmanac |> Task.await

    almanac
    |> minLocationForSeeds
    |> Num.toStr
    |> Stdout.line

minLocationForSeeds : Almanac -> Nat
minLocationForSeeds = \almanac ->
    getMap = \name ->
        almanac.maps |> getMapOrCrash name

    seedRanges : List Range
    seedRanges =
        almanac.seeds
        |> List.chunksOf 2
        |> List.map \chunk ->
            when chunk is
                [start, length] -> { first: start, last: start + length - 1 }
                _ -> crash "This should not happen"

    locations : List Nat
    locations =
        seedRanges
        |> lookup (getMap "seed-to-soil")
        |> lookup (getMap "soil-to-fertilizer")
        |> lookup (getMap "fertilizer-to-water")
        |> lookup (getMap "water-to-light")
        |> lookup (getMap "light-to-temperature")
        |> lookup (getMap "temperature-to-humidity")
        |> lookup (getMap "humidity-to-location")
        |> List.map .first

    when locations |> List.min is
        Ok location -> location
        Err ListWasEmpty ->
            expect almanac.seeds == []
            crash "There were no seeds"

lookupPart :
    List Range, MapPart
    -> { mapped : List Range, remaining : List Range }
lookupPart = \ranges, { destination, source, length } ->
    c = source
    d = source + length - 1

    shift = \first, last ->
        s = \x -> x + destination - source
        { first: s first, last: s last }

    # a--b  c  d
    #       c  d  a--b
    noOverlap =
        ranges |> List.keepIf \{ first: a, last: b } ->
            b < c || d < a

    # a--c==b  d
    leftOverlap =
        ranges |> List.keepIf \{ first: a, last: b } ->
            a < c && c <= b && b <= d

    # c  a==d--b
    rightOverlap =
        ranges |> List.keepIf \{ first: a, last: b } ->
            c <= a && a <= d && d < b

    # a--c==d--b
    bothOverlap =
        ranges |> List.keepIf \{ first: a, last: b } ->
            a < c && d < b

    # c  a==b  d
    fullyContained =
        ranges |> List.keepIf \{ first: a, last: b } ->
            c <= a && b <= d

    # shift and merge parts overlapping c or d as far as possible
    mappedOverlap =
        if List.len bothOverlap > 0 then
            FullOverlap [shift c d]
        else
            maxLeft = leftOverlap |> List.map .last |> List.max
            minRight = rightOverlap |> List.map .first |> List.min

            when (maxLeft, minRight) is
                (Ok l, Ok r) ->
                    if l + 1 >= r then
                        FullOverlap [shift c d]
                    else
                        PartialOverlap [shift c l, shift r d]

                (Ok l, _) ->
                    PartialOverlap [shift c l]

                (_, Ok r) ->
                    PartialOverlap [shift r d]

                _ -> PartialOverlap []

    mapped =
        when mappedOverlap is
            FullOverlap m -> m
            PartialOverlap m ->
                fullyContained
                |> List.map \{ first, last } -> shift first last
                |> List.concat m

    remainingOutsideLeft =
        min =
            List.concat leftOverlap bothOverlap
            |> List.map .first
            |> List.min

        when min is
            Err ListWasEmpty -> []
            Ok x -> [{ first: x, last: c - 1 }]

    remainingOutsideRight =
        max =
            List.concat rightOverlap bothOverlap
            |> List.map .last
            |> List.max

        when max is
            Err ListWasEmpty -> []
            Ok x -> [{ first: d + 1, last: x }]

    remaining =
        noOverlap
        |> List.concat remainingOutsideLeft
        |> List.concat remainingOutsideRight

    { mapped, remaining }

lookup : List Range, Map -> List Range
lookup = \ranges, map ->
    allParts =
        map
        |> List.walk { mapped: [], remaining: ranges } \state, mapPart ->
            result = lookupPart state.remaining mapPart
            {
                mapped: state.mapped |> List.concat result.mapped,
                remaining: result.remaining,
            }
    allParts.mapped |> List.concat allParts.remaining
