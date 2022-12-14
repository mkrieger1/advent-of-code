package aoc2019

import (
	"aoc2019/util"
	"fmt"
	"io"
)

type direction int

const (
	up direction = iota
	down
	left
	right
)

// point is an x, y coordinate.
type point struct {
	x int
	y int
}

// manhattanDistance returns the Manhattan distance to the other point.
func (p point) manhattanDistance(other point) int {
	return util.Abs(p.x-other.x) + util.Abs(p.y-other.y)
}

// manhattanDistanceToOrigin returns the Manhattan distance to the origin.
func (p point) manhattanDistanceToOrigin() int {
	return p.manhattanDistance(point{0, 0})
}

// segment is a wire between to points.
type segment struct {
	start  point
	end    point
	dir    direction
	length int
}

// crossing is a point where two segments cross.
type crossing struct {
	position    point
	firstIndex  int // index of segment in first wire
	secondIndex int // index of segment in second wire
}

// wire is a sequence of connected segments starting from the origin.
type wire []segment

// crosses returns the point where seg crosses the other segment.
func (seg segment) crosses(other segment) (*point, error) {
	var vert, hor segment
	if seg.start.x == seg.end.x { // seg vertical
		if other.start.x == other.end.x {
			return nil, nil // both vertical
		}
		vert, hor = seg, other
	} else if seg.start.y == seg.end.y { // seg horizontal
		if other.start.y == other.end.y {
			return nil, nil // both horizontal
		}
		vert, hor = other, seg
	} else {
		return nil, fmt.Errorf("Segment not horizontal or vertical")
	}

	x := vert.start.x
	if !util.InRange(x, [2]int{hor.start.x, hor.end.x}) {
		return nil, nil
	}
	y := hor.start.y
	if !util.InRange(y, [2]int{vert.start.y, vert.end.y}) {
		return nil, nil
	}
	return &point{x, y}, nil
}

// parseSegment converts a string description of a wire segment
// to its direction and length.
func parseSegment(seg string) (direction, int, error) {
	var letter byte
	var length int
	_, err := fmt.Sscanf(seg, "%c%d", &letter, &length)
	if err != nil {
		return 0, 0, err
	}
	var dir direction
	switch letter {
	case 'U':
		dir = up
	case 'D':
		dir = down
	case 'L':
		dir = left
	case 'R':
		dir = right
	default:
		return 0, 0, fmt.Errorf("Invalid direction: %v", letter)
	}
	return dir, length, nil
}

// parseWire converts a slice of string descriptions of segments to a wire.
func parseWire(descriptions []string) (wire, error) {
	segments := wire{}
	pos := point{0, 0}
	prev := pos
	for _, desc := range descriptions {
		dir, length, err := parseSegment(desc)
		if err != nil {
			return nil, err
		}
		switch dir {
		case up:
			pos.y += length
		case down:
			pos.y -= length
		case left:
			pos.x -= length
		case right:
			pos.x += length
		}
		segments = append(segments, segment{prev, pos, dir, length})
		prev = pos
	}
	return segments, nil
}

// parseTwoWires converts two slices of string descriptions of segments
// to two wires.
func parseTwoWires(descriptions [2][]string) ([2]wire, error) {
	var err error
	var wires [2]wire
	for i := range descriptions {
		wires[i], err = parseWire(descriptions[i])
		if err != nil {
			return wires, err
		}
	}
	return wires, nil
}

// ReadTwoWires reads two lines and converts them to two wires.
func ReadTwoWires(r io.Reader) ([2]wire, error) {
	var err error
	var descriptions [2][]string
	for i := 0; i < 2; i++ {
		descriptions[i], err =
			util.ReadSeparatedStringsFromLine(r, ",")
		if err != nil {
			return [2]wire{}, err
		}
	}
	return parseTwoWires(descriptions)
}

// lengthOfSegments returns the total length of the first n segments.
func (w wire) lengthOfSegments(n int) int {
	result := 0
	for _, segment := range w[:n] {
		result += segment.length
	}
	return result
}

// allCrossings returns all crossings between the two wires,
// excluding the origin.
func allCrossings(wires [2]wire) ([]crossing, error) {
	crossings := []crossing{}
	for i, seg1 := range wires[0] {
		for j, seg2 := range wires[1] {
			pos, err := seg1.crosses(seg2)
			if err != nil {
				return nil, err
			}
			if pos == nil {
				continue
			}
			if (pos.x == 0) && (pos.y == 0) {
				continue
			}
			crossings = append(crossings, crossing{*pos, i, j})
		}
	}
	return crossings, nil
}

// MostCentralCrossing returns the Manhattan distance of the point closest to
// the center where the two wires are crossing.
func MostCentralCrossing(wires [2]wire) (int, error) {
	crossings, err := allCrossings(wires)
	if err != nil {
		return 0, err
	}
	if len(crossings) == 0 {
		return 0, fmt.Errorf("No crossing found")
	}
	best := crossings[0].position.manhattanDistanceToOrigin()
	for _, crossing := range crossings[1:] {
		dist := crossing.position.manhattanDistanceToOrigin()
		if dist < best {
			best = dist
		}
	}
	return best, nil
}

// delay returns the combined length of the wires from the origin to the
// crossing.
func (c crossing) delay(wires [2]wire) int {
	return wires[0].lengthOfSegments(c.firstIndex) +
		wires[0][c.firstIndex].start.manhattanDistance(c.position) +
		wires[1].lengthOfSegments(c.secondIndex) +
		wires[1][c.secondIndex].start.manhattanDistance(c.position)
}

// ShortestDelayCrossing returns the combined length of the wires from the
// origin to the crossing where this length is minimal.
func ShortestDelayCrossing(wires [2]wire) (int, error) {
	crossings, err := allCrossings(wires)
	if err != nil {
		return 0, err
	}
	if len(crossings) == 0 {
		return 0, fmt.Errorf("No crossing found")
	}
	best := crossings[0].delay(wires)
	for _, crossing := range crossings[1:] {
		delay := crossing.delay(wires)
		if delay < best {
			best = delay
		}
	}
	return best, nil
}
