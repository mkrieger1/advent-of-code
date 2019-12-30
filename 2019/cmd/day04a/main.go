package main

import (
	"aoc2019"
	"fmt"
	"log"
	"os"
)

func main() {
	numbers, err := aoc2019.ReadRange(os.Stdin)
	if err != nil {
		log.Fatal(err)
	}
	result, err := aoc2019.NumPasswords(numbers[0], numbers[1])
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(result)
}
