#include "machine.h"
#include <iostream>

int main()
{
    Machine m;
    Machine::Instruction i;
    while (std::cin >> i) {
        m.execute(i);
    }
    std::cout << m.max_value() << '\n';
    std::cout << m.max_all_time_value() << '\n';
}
