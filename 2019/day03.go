package aoc2019

import (
	"aoc2019/util"
	"fmt"
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

// manhattanDistance returns the Manhattan distance of a point from the origin.
func (p point) manhattanDistance() int {
	return util.Abs(p.x) + util.Abs(p.y)
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
func allCrossings(wire1, wire2 wire) ([]crossing, error) {
	crossings := []crossing{}
	for i, seg1 := range wire1 {
		for j, seg2 := range wire2 {
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
// the center where the two wires given by the segment string descriptions are
// crossing.
func MostCentralCrossing(wiresDescriptions [2][]string) (int, error) {
	var err error
	var wires [2]wire
	for i := range wiresDescriptions {
		wires[i], err = parseWire(wiresDescriptions[i])
		if err != nil {
			return 0, err
		}
	}

	crossings, err := allCrossings(wires[0], wires[1])
	if err != nil {
		return 0, err
	}
	if len(crossings) == 0 {
		return 0, fmt.Errorf("No crossing found")
	}
	best := crossings[0].position.manhattanDistance()
	for _, crossing := range crossings[1:] {
		dist := crossing.position.manhattanDistance()
		if dist < best {
			best = dist
		}
	}
	return best, nil
}
