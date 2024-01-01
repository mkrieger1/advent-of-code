app "day10-part2"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
        common: "../common/main.roc",
    }
    imports [
        pf.Stdin, pf.Stdout, pf.Stderr, pf.Task.{ Task },
        common.Loop,
        Day10.{
            Direction, Index, Maze, Position, Tile,
            findStart, move, nextDirection, parseMaze,
        }
    ]
    provides [main] to pf

unused = Stdin.line

main =
    run =
        maze <- parseMaze |> Task.await
        result <- solve maze |> Task.fromResult |> Task.await
        result |> Num.toStr |> Stdout.line

    handleErr = \err ->
        msg =
            when err is
                InvalidTile c -> "Found invalid tile: \(Num.toStr c)"
                NoStart -> "Maze contains no start tile"
                InvalidStart -> "Start tile is not connected to 2 neighbors"
                OutOfBounds -> "Moved past the borders of the maze"
                DeadEnd -> "Reached a dead end in the maze"
        msg |> Stderr.line

    run |> Task.onErr handleErr

revealStart :
    Maze, Position -> Result { dir : Direction, tile : Tile } [InvalidStart]
revealStart = \maze, start ->
    isConnected = \dir, tile ->
        when (dir, tile) is
            (Up, SouthEast) | (Up, SouthWest) | (Up, NorthSouth)
            | (Down, NorthEast) | (Down, NorthWest) | (Down, NorthSouth)
            | (Left, NorthEast) | (Left, SouthEast) | (Left, EastWest)
            | (Right, NorthWest) | (Right, SouthWest) | (Right, EastWest)
              -> Bool.true
            _ -> Bool.false

    dirs =
        [Up, Down, Left, Right]
        |> List.keepIf \dir ->
            when maze |> move start dir is
                Ok { tile } if isConnected dir tile -> Bool.true
                _ -> Bool.false

    startTile = \dir, otherDir ->
        when (dir, otherDir) is
            (Up, Down) -> NorthSouth
            (Up, Left) -> NorthWest
            (Up, Right) -> NorthEast
            (Down, Left) -> SouthWest
            (Down, Right) -> SouthEast
            (Left, Right) -> EastWest
            _ -> crash "impossible"

    when dirs is
        [dir, otherDir] -> { dir, tile: startTile dir otherDir } |> Ok
        _ -> InvalidStart |> Err

ensureSize : List a, Index, a -> List a
ensureSize = \list, i, fillValue ->
    length = List.len list
    needed = i + 1
    if length >= needed then
        list
    else
        missing = needed - length
        expect missing >= 1
        fill = fillValue |> List.repeat missing
        list |> List.concat fill

Angle : [Up, Down]
Boundary : [Empty, Open Angle, Close Angle, StayOpen, Vertical]
BoundaryMap : List (List Boundary)

insert : BoundaryMap, Position, Tile -> BoundaryMap
insert = \map, pos, tile ->
    newMap = map |> ensureSize pos.row []
    row =
        when newMap |> List.get pos.row is
            Err OutOfBounds -> crash "impossible"
            Ok r -> r

    boundary =
        when tile is
            NorthSouth -> Vertical
            EastWest -> StayOpen
            NorthEast -> Open Up
            SouthEast -> Open Down
            NorthWest -> Close Up
            SouthWest -> Close Down
            _ -> Empty
    newRow =
        row
        |> ensureSize pos.col Empty
        |> List.set pos.col boundary

    newMap |> List.set pos.row newRow

drawBoundary : Maze -> Result BoundaryMap _
drawBoundary = \maze ->
    start <- maze |> findStart |> Result.try
    { dir, tile: startTile } <- maze |> revealStart start |> Result.try
    init <- maze |> move start dir |> Result.try

    step = \{ state: { tile, pos, inDir }, map } ->
        if tile == Start then
            expect pos == start  # assume there is only one start
            map |> insert pos startTile |> Break |> Ok
        else
            outDir <- nextDirection inDir tile |> Result.try
            state <- maze |> move pos outDir |> Result.try
            { state, map: map |> insert pos tile } |> Continue |> Ok

    Loop.loop { state: init, map: [] } step


countEnclosed : (List Boundary) -> Nat
countEnclosed = \row ->
    init = { enclosed: Outside, horizontal: Closed, count: 0 }

    toggle = \enclosed ->
        when enclosed is
            Inside -> Outside
            Outside -> Inside

    step = \state, boundary ->
        when (state.horizontal, boundary) is
            (Closed, Empty) ->
                when state.enclosed is
                    Inside -> { state & count: state.count + 1 }
                    Outside -> state

            (Closed, Vertical) ->
                { state & enclosed: toggle state.enclosed }

            (Closed, Open angle) ->
                { state & horizontal: Open angle }

            (Open _, StayOpen) ->
                state

            (Open Up, Close Down) | (Open Down, Close Up) ->
                { state & enclosed: toggle state.enclosed, horizontal: Closed }

            (Open Up, Close Up) | (Open Down, Close Down) ->
                { state & horizontal: Closed }

            _ -> crash "impossible dead end"

    row |> List.walk init step |> .count

solve : Maze -> Result Nat _
solve = \maze ->
    map <- drawBoundary maze |> Result.try
    map |> List.map countEnclosed |> List.sum |> Ok
