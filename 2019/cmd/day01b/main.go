package main

import (
	"aoc2019"
	"fmt"
	"log"
	"os"
)

func main() {
	modules, err := aoc2019.ReadInts(os.Stdin)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(aoc2019.FuelForModulesIncludingFuel(modules))
}
