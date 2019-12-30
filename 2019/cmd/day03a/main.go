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
	dist, err := aoc2019.MostCentralCrossing(wires)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(dist)
}
