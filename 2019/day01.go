package aoc2019

import (
	"io"
)

// fuelToLaunchModule calculates the fuel required to launch a module.
// (Fuel required to launch a given module is based on its mass.
// Specifically, to find the fuel required for a module, take its mass,
// divide by three, round down, and subtract 2.)
func fuelToLaunchModule(mass int) int {
	return mass/3 - 2
}

func FuelToLaunchModules(r io.Reader) (int, error) {
	masses, err := ReadInts(r)
	if err != nil {
		return 0, err
	}
	total := 0
	for mass := range masses {
		total += fuelToLaunchModule(mass)
	}
	return total, nil
}
