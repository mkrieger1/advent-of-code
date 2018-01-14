#include "register_machine.h"
#include <cassert>

void run_tests()
{
    RegisterMachine machine{};
    assert(machine.max_register_value() == 0);

    Instruction instruction{"b inc 5 if a > 1"};
    machine.execute(instruction);
    assert(machine.max_register_value() == 0);
}

int main()
{
    run_tests();
}
