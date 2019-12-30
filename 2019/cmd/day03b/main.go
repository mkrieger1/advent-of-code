package main

import (
	"aoc2019"
	"fmt"
	"log"
	"os"
)

func main() {
	wires, err := aoc2019.ReadTwoWires(os.Stdin)
	if err != nil {
		log.Fatal(err)
	}
	delay, err := aoc2019.ShortestDelayCrossing(wires)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(delay)
}
