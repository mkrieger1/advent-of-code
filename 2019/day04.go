package aoc2019

import (
	"aoc2019/util"
	"fmt"
	"io"
)

// ReadRange reads an integer range.
func ReadRange(r io.Reader) ([2]int, error) {
	var result [2]int
	values, err := util.ReadIntsFromLine(r, "-")
	if err != nil {
		return result, err
	}
	if len(values) != 2 {
		return result, fmt.Errorf("Expected two values")
	}
	for i, v := range values {
		result[i] = v
	}
	return result, nil
}

// digits converts a non-negative integer to a slice of digits from left to
// right.
func digits(x int) ([]int, error) {
	if x < 0 {
		return nil, fmt.Errorf("Input must not be negative")
	}
	reversed := []int{}
	for x > 0 {
		reversed = append(reversed, x%10)
		x /= 10
	}
	n := len(reversed)
	result := make([]int, n)
	for i := 0; i < n; i++ {
		result[i] = reversed[n-1-i]
	}
	return result, nil
}
