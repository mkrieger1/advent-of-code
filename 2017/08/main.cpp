#include "machine.h"
#include <iostream>

int main()
{
    Machine m;
    Machine::Instruction i;
    try {
        while (std::cin >> i) m.execute(i);
    } catch (Machine::Instruction::ParseError& e) {
        std::cerr << e.what() << '\n';
    }
    std::cout << m.max_value() << '\n';
    std::cout << m.max_all_time_value() << '\n';
}
