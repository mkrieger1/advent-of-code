package main

import (
	"aoc2019"
	"aoc2019/util"
	"fmt"
	"log"
	"os"
)

func main() {
	mem, err := util.ReadIntsFromLine(os.Stdin, ",")
	if err != nil {
		log.Fatal(err)
	}
	result, err := aoc2019.FindInputs(mem, 19690720)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(result)
}
