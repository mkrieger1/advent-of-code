#include "register_machine.h"
#include <cassert>
#include <vector>

void run_tests()
{
    RegisterMachine machine{};
    assert(machine.max_register_value() == 0);

    const std::vector<Instruction> instructions{
        {"b inc 5 if a > 1"},
        {"a inc 1 if b < 5"}
    };

    machine.execute(instructions[0]);
    assert(machine.max_register_value() == 0);

    machine.execute(instructions[1]);
    assert(machine.max_register_value() == 1);
}

int main()
{
    run_tests();
}
