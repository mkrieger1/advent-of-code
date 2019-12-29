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

// segment is a wire between to points.
type segment struct {
	start  point
	end    point
	dir    direction
	length int
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
			var vert, hor segment
			if seg1.start.x == seg1.end.x { // segment1 vertical
				if seg2.start.x == seg2.end.x {
					continue // both vertical
				}
				vert, hor = seg1, seg2
			} else if seg1.start.y == seg1.end.y { // segment1 horizontal
				if seg2.start.y == seg2.end.y {
					continue // both horizontal
				}
				vert, hor = seg2, seg1
			} else {
				return 0, fmt.Errorf("Segment not horizontal or vertical")
			}

			x := vert.start.x
			var xlow, xhigh int
			if hor.start.x < hor.end.x {
				xlow, xhigh = hor.start.x, hor.end.x
			} else {
				xlow, xhigh = hor.end.x, hor.start.x
			}
			if (x < xlow) || (x > xhigh) {
				continue // no crossing
			}

			y := hor.start.y
			var ylow, yhigh int
			if vert.start.y < vert.end.y {
				ylow, yhigh = vert.start.y, vert.end.y
			} else {
				ylow, yhigh = vert.end.y, vert.start.y
			}
			if (y < ylow) || (y > yhigh) {
				continue // no crossing
			}

			// crossing at x, y
			if (x == 0) && (y == 0) {
				continue // doesn't count
			}
			dist := util.Abs(x) + util.Abs(y)
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
