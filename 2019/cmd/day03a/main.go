package main

import (
	"aoc2019"
	"aoc2019/util"
	"fmt"
	"log"
	"os"
)

func main() {
	var err error
	var wires [2][]string
	for i := 0; i < 2; i++ {
		wires[i], err = util.ReadSeparatedStringsFromLine(os.Stdin, ",")
		if err != nil {
			log.Fatal(err)
		}
	}
	dist, err := aoc2019.MostCentralCrossing(wires)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(dist)
}
