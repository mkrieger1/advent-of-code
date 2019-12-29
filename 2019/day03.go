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

// pointsFromSegments converts a slice of string descriptions of wire segments
// to a slice of points.
func pointsFromSegments(segments []string) ([]point, error) {
	pos := point{0, 0}
	points := []point{pos}
	for _, seg := range segments {
		dir, length, err := parseSegment(seg)
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
		points = append(points, pos)
	}
	return points, nil
}

// MostCentralCrossing returns the Manhattan distance of the crossing
// of the two wires closest to the center.
func MostCentralCrossing(wires [2][]string) (int, error) {
	var err error
	var points [2][]point
	for i, segments := range wires {
		points[i], err = pointsFromSegments(segments)
		if err != nil {
			return 0, err
		}
	}
	points1, points2 := points[0], points[1]
	best := -1

	for i := range points1 {
		if i == 0 {
			continue
		}
		for j := range points2 {
			if j == 0 {
				continue
			}
			start1, end1 := points1[i-1], points1[i]
			start2, end2 := points2[j-1], points2[j]
			if start1.x == end1.x { // segment1 vertical
				x := start1.x
				xa, xb := start2.x, end2.x
				if xa == xb {
					continue // both vertical
				}
				if (x < xa) || (x > xb) {
					continue // no crossing
				}
				y := start2.y
				ya, yb := start1.y, end1.y
				if (y < ya) || (y > yb) {
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
			} else if start1.y == end1.y { // segment1 horizontal
				y := start1.y
				ya, yb := start2.y, end2.y
				if ya == yb {
					continue // both horizontal
				}
				if (y < ya) || (y > yb) {
					continue // no crossing
				}
				x := start2.x
				xa, xb := start1.x, end1.x
				if (x < xa) || (x > xb) {
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
			} else {
				return 0, fmt.Errorf("Segment not horizontal or vertical")
			}
		}
	}
	if best == -1 {
		return 0, fmt.Errorf("No crossing found")
	}
	return best, nil
}
