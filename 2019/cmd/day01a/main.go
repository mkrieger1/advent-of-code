package main

import (
	"aoc2019"
	"fmt"
	"log"
	"os"
)

func main() {
	masses, err := aoc2019.ReadInts(os.Stdin)
	if err != nil {
		log.Fatal(err)
	}
	result, err := aoc2019.FuelToLaunchModules(masses)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(result)
}
