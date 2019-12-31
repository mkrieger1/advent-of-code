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

// rangeSize returns the number of integers in the inclusive range.
func rangeSize(low, high int) int {
	if high < low {
		return 0
	}
	return high - low + 1
}

func notHigher(a, b int) int {
	if a < b {
		return a
	}
	return b
}

func notLower(a, b int) int {
	if a > b {
		return a
	}
	return b
}

func largestCombination(high []int) []int {
	result := make([]int, len(high))
	result[0] = high[0]
	for i := 1; i < len(high); i++ {
		if result[i-1] > high[i] {
			result[i-1] -= 1
			result[i] = 9
		} else {
			result[i] = high[i]
		}
	}
	return high
}

// numCombinationsSameDigit returns the number of combinations of 6 digits
// within the range, where all digits are non-descending from left to right and
// the n-th pair of digits are identical (n=1: first and second).
func numCombinationsSameDigit(low, high []int, n int) (int, error) {
	if len(low) != 6 || len(high) != 6 {
		return 0, fmt.Errorf("Limits must be 6 digits")
	}
	if !(1 <= n && n < 6) {
		return 0, fmt.Errorf("n must be between 1 and 5")
	}
	highCopy := largestCombination(high)
	result := rangeSize(low[0], highCopy[0])
	for i := 1; i < 6; i++ {
		if i < n {
			low[i] = notLower(low[i], low[i-1]+1)
		} else if i == n {
			highCopy[i] = notHigher(highCopy[i], highCopy[i-1])
			low[i] = notLower(low[i], low[i-1])
		} else {
			low[i] = notLower(low[i], low[i-1])
		}
		result *= rangeSize(low[i], highCopy[i])
	}
	return result, nil
}

// NumPasswordsTooClever returns the number of valid passwords within the
// integer range and tries to be clever so it doesn't work.
func NumPasswordsTooClever(low, high int) (int, error) {
	lowDigits, err := digits(low)
	if err != nil {
		return 0, err
	}
	highDigits, err := digits(high)
	if err != nil {
		return 0, err
	}
	result := 0
	for n := 1; n < 6; n++ {
		comb, err := numCombinationsSameDigit(lowDigits, highDigits, n)
		if err != nil {
			return 0, err
		}
		result += comb
	}
	return result, nil
}

func isValidPassword(x int) bool {
	twoConsecutiveFound := false
	digitToTheRight := 10 // initialize higher than any digit
	// going in reverse
	for ; x > 0; x /= 10 {
		digit := x % 10
		if digit == digitToTheRight {
			twoConsecutiveFound = true
		}
		if digit > digitToTheRight {
			return false
		}
		digitToTheRight = digit
	}
	return twoConsecutiveFound
}

// NumPasswords returns the number of valid passwords within the integer range
// (inclusive) by testing each candidate individually.
func NumPasswords(low, high int) (int, error) {
	result := 0
	for candidate := low; candidate <= high; candidate++ {
		if isValidPassword(candidate) {
			result += 1
		}
	}
	return result, nil
}
