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
	result, err := aoc2019.RestoreGravityAssist(mem)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(result)
}
