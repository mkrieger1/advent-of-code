package main

import (
	"aoc2019"
	"aoc2019/util"
	"fmt"
	"log"
	"os"
)

func main() {
	modules, err := util.ReadIntsFromLines(os.Stdin)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(aoc2019.FuelForModulesAlone(modules))
}
