package util

import (
	"bufio"
	"fmt"
	"io"
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
