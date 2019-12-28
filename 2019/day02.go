package aoc2019

import "fmt"

// runIntMachine runs the instructions in the memory until the program
// halts and returns the final value at memory location 0.
func runIntMachine(mem []int) (int, error) {
	p := 0
	end := false
	for {
		switch opcode := mem[p]; opcode {
		case 1:
			op1, op2, dest := mem[p+1], mem[p+2], mem[p+3]
			mem[dest] = mem[op1] + mem[op2]
		case 2:
			op1, op2, dest := mem[p+1], mem[p+2], mem[p+3]
			mem[dest] = mem[op1] * mem[op2]
		case 99:
			end = true
		default:
			return 0, fmt.Errorf("Invalid opcode: %d", opcode)
		}
		if end {
			break
		}
		p += 4
	}
	return mem[0], nil
}

func runIntMachineWithInput(mem []int, noun int, verb int) (int, error) {
	mem[1] = noun
	mem[2] = verb
	return runIntMachine(mem)
}

// RestoreGravityAssist restores the gravity assist program to the
// "1202 program alarm" state it had just before the last computer
// caught fire and then runs the program.
func RestoreGravityAssist(mem []int) (int, error) {
	return runIntMachineWithInput(mem, 12, 2)
}

func findInputsBruteForce(mem []int, target int) (noun int, verb int, err error) {
	memCopy := make([]int, len(mem)) // see https://stackoverflow.com/questions/30182538
	for noun = 0; noun <= 99; noun++ {
		for verb = 0; verb <= 99; verb++ {
			copy(memCopy, mem)
			result, err := runIntMachineWithInput(memCopy, noun, verb)
			if err != nil {
				return 0, 0, err
			}
			if result == target {
				return noun, verb, nil
			}
		}
	}
	return 0, 0, fmt.Errorf("No inputs produced target %d", target)
}

// FindInputs finds the noun and verb producing the target result when
// running the program in the memory and returns it as 100 * noun + verb.
func FindInputs(mem []int, target int) (int, error) {
	noun, verb, err := findInputsBruteForce(mem, target)
	if err != nil {
		return 0, err
	}
	return 100*noun + verb, nil
}
