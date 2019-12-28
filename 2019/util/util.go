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
