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

// RestoreGravityAssist restores the gravity assist program to the
// "1202 program alarm" state it had just before the last computer
// caught fire and then runs the program.
func RestoreGravityAssist(mem []int) (int, error) {
	mem[1] = 12
	mem[2] = 2
	return runIntMachine(mem)
}
