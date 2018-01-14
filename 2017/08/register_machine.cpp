#include "register_machine.h"

Instruction::Instruction(const std::string& line)
{
}

RegisterMachine::RegisterValue RegisterMachine::max_register_value() const
{
    return 0;
}

void RegisterMachine::execute(const Instruction& instruction)
{
}
