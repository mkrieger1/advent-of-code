#include "recursive_circus.h"
#include <iostream>

int main()
{
    ProgramTower tower;
    std::cin >> tower;
    auto name{tower.base()};

    std::cout << "Program '" << name
              << "' is the base of the tower of programs.\n";

    std::cout << "The total weight of the sub-tower starting from '" << name
              << "' is " << tower.total_weight(name) << ".\n";

    auto wrong{tower.wrong_weight(name)};
    std::cout << "The sub-tower supported by '" << name << "' is "
              << (wrong.is_balanced ? "" : "not ")
              << "balanced.\n";

    std::cout << "Program '" << wrong.name << "' has the wrong weight.\n";

    std::cout << "Its weight would need to be "
              << wrong.correct_weight << ".\n";
}
