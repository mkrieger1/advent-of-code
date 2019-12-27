package aoc2019

// fuelToLaunchMass calculates the fuel required to launch a mass.
func fuelToLaunchMass(mass int) int {
	f := mass/3 - 2
	if f < 0 {
		return 0
	}
	return f
}

// fuelToLaunchModuleWithFuel calculates the fuel required to launch a
// module, including the fuel required to launch the fuel itself.
func fuelToLaunchMassWithFuel(mass int) int {
	total := 0
	add := fuelToLaunchMass(mass)
	for add > 0 {
		total += add
		add = fuelToLaunchMass(add)
	}
	return total
}

// FuelForModulesAlone calculates the fuel required to launch the modules,
// without taking the fuel required to launch the fuel itself into account.
func FuelForModulesAlone(modules []int) int {
	total := 0
	for _, module := range modules {
		total += fuelToLaunchMass(module)
	}
	return total
}

/*
MK: Why is the result different between
- (fuel for module + additional fuel) for each module (-> 5120654)
- (fuel for each module) + additional fuel            (-> 5123500)?
*/

// FuelForModulesIncludingFuel calculates the fuel required to launch the
// modules, including the fuel required to launch the fuel itself.
func FuelForModulesIncludingFuel(modules []int) int {
	total := 0
	for _, module := range modules {
		total += fuelToLaunchMassWithFuel(module)
	}
	return total
}
