// Solution for Advent of Code 2017, Day 7, Parts 1 & 2.

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

    auto balance{tower.check_balance(name)};
    std::cout << "The sub-tower supported by '" << name << "' is "
              << (balance.balanced ? "" : "not ")
              << "balanced.\n";

    std::cout << "Program '" << balance.wrong_program << "' has the wrong weight.\n";

    std::cout << "Its weight would need to be "
              << balance.correct_weight << ".\n";
}
