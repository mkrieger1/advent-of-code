#include "machine.h"
#include <cassert>
#include <vector>

const std::vector<Machine::Instruction> instructions{
    {"b inc 5 if a > 1"},
    {"a inc 1 if b < 5"},
    {"c dec -10 if a >= 1"},
    {"c inc -20 if c == 10"}
};

void test_instruction_from_string()
{
    assert(instructions[0].target == "b");
    assert(instructions[0].operation == Machine::Instruction::Operation::Inc);
    assert(instructions[0].operation_amount == 5);
    assert(instructions[0].source == "a");
    assert(instructions[0].comparison == Machine::Instruction::Comparison::Greater);
    assert(instructions[0].compare_value == 1);
}

void run_simple_example()
{
    Machine machine{};
    assert(machine.max_register_value() == 0);

    machine.execute(instructions[0]);
    assert(machine.max_register_value() == 0);

    machine.execute(instructions[1]);
    assert(machine.max_register_value() == 1);

    machine.execute(instructions[2]);
    assert(machine.max_register_value() == 10);

    machine.execute(instructions[3]);
    assert(machine.max_register_value() == 1);
}

int main()
{
    run_simple_example();
    test_instruction_from_string();
}
