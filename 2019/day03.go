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

// parseSegments converts a slice of string descriptions of wire segments
// to a slice of segments.
func parseSegments(descriptions []string) ([]segment, error) {
	segments := []segment{}
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

// MostCentralCrossing returns the Manhattan distance of the crossing
// of the two wires closest to the center.
func MostCentralCrossing(wires [2][]string) (int, error) {
	var err error
	var segments [2][]segment
	for i := range wires {
		segments[i], err = parseSegments(wires[i])
		if err != nil {
			return 0, err
		}
	}

	best := -1
	for _, seg1 := range segments[0] {
		for _, seg2 := range segments[1] {
			crossing, err := seg1.crosses(seg2)
			if err != nil {
				return 0, err
			}
			if crossing == nil {
				continue
			}
			if (crossing.x == 0) && (crossing.y == 0) {
				continue // doesn't count
			}
			dist := crossing.manhattanDistance()
			if (best == -1) || (dist < best) {
				best = dist
			}
		}
	}
	if best == -1 {
		return 0, fmt.Errorf("No crossing found")
	}
	return best, nil
}
