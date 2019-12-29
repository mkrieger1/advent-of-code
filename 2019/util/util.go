package util

import (
	"bufio"
	"fmt"
	"io"
	"strings"
)

// ReadIntsFromLines converts all lines from r to a slice of ints.
func ReadIntsFromLines(r io.Reader) ([]int, error) {
	ints := []int{}
	scanner := bufio.NewScanner(r)
	var i int
	for scanner.Scan() {
		_, err := fmt.Sscanf(scanner.Text(), "%d", &i)
		if err != nil {
			return nil, err
		}
		ints = append(ints, i)
	}
	return ints, nil
}

// ReadIntsFromLine reads a line and splits it to a sclice of ints.
func ReadIntsFromLine(r io.Reader, sep string) ([]int, error) {
	ints := []int{}
	reader := bufio.NewReader(r)
	line, err := reader.ReadString('\n')
	if err != nil {
		return nil, err
	}
	var i int
	for _, part := range strings.Split(line, sep) {
		_, err := fmt.Sscanf(part, "%d", &i)
		if err != nil {
			return nil, err
		}
		ints = append(ints, i)
	}
	return ints, nil
}

// ReadSeparatedStringsFromLine reads a line and splits it to a sclice of strings.
func ReadSeparatedStringsFromLine(r io.Reader, sep string) ([]string, error) {
	reader := bufio.NewReader(r)
	line, err := reader.ReadString('\n')
	if err != nil {
		return nil, err
	}
	return strings.Split(line, sep), nil
}

// Abs returns the absolute value of x.
func Abs(x int) int {
	if x < 0 {
		return -x
	}
	return x
}

// InRange determines whether x is in the range (inclusive).
// It does not matter whether the range is ascending or descending.
func InRange(x int, r [2]int) bool {
	var low, high int
	if r[0] < r[1] {
		low, high = r[0], r[1]
	} else {
		low, high = r[1], r[0]
	}
	return (low <= x) && (x <= high)
}
