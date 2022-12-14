#include "machine.h"
#include <iostream>

int main()
{
    Machine m;
    Machine::Instruction i;
    try {
        while (std::cin >> i) m.execute(i);
    } catch (const Machine::Instruction::ParseError& e) {
        std::cerr << e.what() << '\n';
    }
    std::cout << m.max_value() << '\n';
    std::cout << m.all_time_max_value() << '\n';
}
