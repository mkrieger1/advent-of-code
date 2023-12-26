app "day8-part2"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
        common: "../common/main.roc"
    }
    imports [
        pf.Stdout, pf.Stdin, pf.Task,
        Parse.{ parseMaps }
    ]
    provides [main] to pf

unused = Stdin.line

main =
    maps <- parseMaps |> Task.await

    navigate maps
    |> Num.toStr
    |> Stdout.line

endsWith = \label, letter ->
    when label |> Str.toUtf8 is
        [_, _, c] if c == letter -> Bool.true
        _ -> Bool.false

isStart = \label -> label |> endsWith 'A'

isEnd = \label -> label |> endsWith 'Z'

wrappedSteps = \map, steps ->
    steps % (map.instructions |> List.len)

navigateNextEnd = \map, ghost ->
    initialSteps = ghost.steps

    nextLocation = \{ steps, location } ->
        index = wrappedSteps map steps

        instruction =
            when map.instructions |> List.get index is
                Err OutOfBounds -> crash "Should not happen"
                Ok i -> i

        choices =
            when map.network |> Dict.get location is
                Err KeyNotFound -> crash "Location not in map"
                Ok c -> c

        when instruction is
            Left -> choices.left
            Right -> choices.right

    doSteps = \current ->
        next = {
            steps: current.steps + 1,
            location: nextLocation current
        }
        if isEnd next.location then
            next
        else
            doSteps next

    final = doSteps ghost
    { final & steps: final.steps - initialSteps }

findNextEnd = \map, { shortcuts, current } ->
    index = wrappedSteps map current.steps
    key = { location: current.location, index }
    when shortcuts |> Dict.get key is
        Ok found -> {
            shortcuts,
            found: { found & steps: found.steps + current.steps }
        }
        Err KeyNotFound ->
            found = navigateNextEnd map current
            {
                shortcuts: shortcuts |> Dict.insert key found,
                found: { found & steps: found.steps + current.steps }
            }

allEnd = \ghosts ->
    ghosts |> List.map .location |> List.all isEnd

sameSteps = \ghosts ->
    steps = ghosts |> List.map .steps

    unwrap = \result ->
        when result is
            Ok m -> m
            Err ListWasEmpty -> crash "List was empty"

    min = steps |> List.min |> unwrap
    max = steps |> List.max |> unwrap

    if min == max then
        Same min
    else
        Different

finished = \ghosts ->
    if allEnd ghosts then
        when sameSteps ghosts is
            Same steps -> Finished steps
            Different -> NotFinished
    else
        NotFinished

moveLastGhost = \map, { shortcuts, ghosts } ->
    stepsDesc = \a, b -> Num.compare b.steps a.steps
    sortedGhosts = ghosts |> List.sortWith stepsDesc

    last =
        when sortedGhosts |> List.last is
            Err ListWasEmpty -> crash "List was empty"
            Ok l -> l

    remaining =
        n = List.len ghosts
        sortedGhosts |> List.takeFirst (n - 1)

    next = findNextEnd map { shortcuts, current: last }
    {
        shortcuts: next.shortcuts,
        ghosts: remaining |> List.append next.found
    }

navigate = \map ->
    startGhosts =
        Dict.keys map.network
        |> List.keepIf isStart
        |> List.map \label ->
            { steps: 0, location: label }

    doNext = \current ->
        when finished current.ghosts is
            Finished steps -> steps
            NotFinished ->
                moveLastGhost map current
                |> doNext

    doNext { shortcuts: Dict.empty {}, ghosts: startGhosts }
