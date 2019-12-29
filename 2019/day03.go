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

// allCrossings returns all points where the two wires cross,
// excluding the origin.
func allCrossings(wire1, wire2 wire) ([]point, error) {
	crossings := []point{}
	for _, seg1 := range wire1 {
		for _, seg2 := range wire2 {
			crossing, err := seg1.crosses(seg2)
			if err != nil {
				return nil, err
			}
			if crossing == nil {
				continue
			}
			if (crossing.x == 0) && (crossing.y == 0) {
				continue
			}
			crossings = append(crossings, *crossing)
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
	best := crossings[0].manhattanDistance()
	for _, crossing := range crossings[1:] {
		dist := crossing.manhattanDistance()
		if dist < best {
			best = dist
		}
	}
	return best, nil
}
