package aoc2019

import (
	"bufio"
	"fmt"
	"io"
	"os"
)

// ReadInts converts all lines from the Reader to a slice of ints.
func ReadInts(r io.Reader) ([]int, error) {
	scanner := bufio.NewScanner(os.Stdin)
	ints := []int{}
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
