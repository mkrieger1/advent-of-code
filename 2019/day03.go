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
// to a slice of (x, y) coordinates.
func pointsFromSegments(segments []string) ([][2]int, error) {
	points := [][2]int{}
	x, y := 0, 0
	for _, seg := range segments {
		dir, length, err := parseSegment(seg)
		if err != nil {
			return nil, err
		}
		switch dir {
		case up:
			y += length
		case down:
			y -= length
		case left:
			x -= length
		case right:
			x += length
		}
		points = append(points, [2]int{x, y})
	}
	return points, nil
}

// MostCentralCrossing returns the Manhattan distance of the crossing
// of the two wires closest to the center.
func MostCentralCrossing(wires [2][]string) (int, error) {
	var err error
	var points [2][][2]int
	for i, segments := range wires {
		points[i], err = pointsFromSegments(segments)
		if err != nil {
			return 0, err
		}
	}
	points1, points2 := points[0], points[1]
	best := -1

	for i := range points[0] {
		if i == 0 {
			continue
		}
		for j := range points[1] {
			if j == 0 {
				continue
			}
			start1, end1 := points1[i-1], points1[i]
			start2, end2 := points2[j-1], points2[j]
			if start1[0] == end1[0] { // segment1 vertical
				x := start1[0]
				xa, xb := start2[0], end2[0]
				if xa == xb {
					continue // both vertical
				}
				if (x < xa) || (x > xb) {
					continue // no crossing
				}
				y := start2[1]
				ya, yb := start1[1], end1[1]
				if (y < ya) || (y > yb) {
					continue // no crossing
				}
				// crossing at x, y
				dist := util.Abs(x) + util.Abs(y)
				if (best == -1) || (dist < best) {
					best = dist
				}
			} else if start1[1] == end1[1] { // segment1 horizontal
				y := start1[1]
				ya, yb := start2[1], end2[1]
				if ya == yb {
					continue // both horizontal
				}
				if (y < ya) || (y > yb) {
					continue // no crossing
				}
				x := start2[0]
				xa, xb := start1[0], end1[0]
				if (x < xa) || (x > xb) {
					continue // no crossing
				}
				// crossing at x, y
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
