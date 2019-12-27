package main

import (
	"aoc2019"
	"fmt"
	"log"
	"os"
)

func main() {
	t, err := aoc2019.FuelToLaunchModules(os.Stdin)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(t)
}
