package aoc2019

import (
	"aoc2019/util"
	"os"
	"testing"
)

func TestFuelToLaunchMass(t *testing.T) {
	cases := []struct {
		in, out int
	}{
		{1969, 654},
		{100756, 33583},
	}
	for _, c := range cases {
		result := fuelToLaunchMass(c.in)
		if result != c.out {
			t.Errorf("fuelToLaunchMass(%d) = %d, expected %d",
				c.in, result, c.out)
		}
	}
}

func TestFuelForModulesAlone(t *testing.T) {
	f, err := os.Open("day01.txt")
	if err != nil {
		t.Fatalf("Failed to read test input: %v", err)
	}
	modules, err := util.ReadIntsFromLines(f)
	if err != nil {
		t.Fatal(err)
	}
	f.Close()
	result := FuelForModulesAlone(modules)
	expected := 3415695
	if result != expected {
		t.Errorf("FuelForModulesAlone(%v) = %d, expected %d",
			modules, result, expected)
	}
}
