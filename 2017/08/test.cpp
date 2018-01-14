#include "register_machine.h"
#include <cassert>

void run_tests()
{
    RegisterMachine machine{};
    assert(machine.max_register_value() == 0);
}

int main()
{
    run_tests();
}
