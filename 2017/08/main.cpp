#include "machine.h"
#include <iostream>

int main()
{
    Machine m;
    std::string line;
    while (std::getline(std::cin, line)) {
        Machine::Instruction i{line};
        m.execute(i);
    }
    std::cout << m.max_value() << '\n';
    std::cout << m.max_all_time_value() << '\n';
}
