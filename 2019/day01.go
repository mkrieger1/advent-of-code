package aoc2019

// fuelToLaunchModule calculates the fuel required to launch a module.
// (Fuel required to launch a given module is based on its mass.
// Specifically, to find the fuel required for a module, take its mass,
// divide by three, round down, and subtract 2.)
func fuelToLaunchModule(mass int) int {
	return mass/3 - 2
}

// FuelToLaunchModules calculates the total fuel requirement.
// (Individually calculate the fuel needed for the mass of each module
// (your puzzle input), then add together all the fuel values.)
func FuelToLaunchModules(masses []int) (int, error) {
	total := 0
	for _, mass := range masses {
		total += fuelToLaunchModule(mass)
	}
	return total, nil
}
