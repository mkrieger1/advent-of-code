// Solution for Advent of Code 2017, Day 7, Parts 1 & 2.

#include "recursive_circus.h"
#include <iostream>

int main()
{
    ProgramTower tower;
    std::cin >> tower;

    std::cout << "Program '" << tower.base()
              << "' is the base of the tower of programs.\n";

    std::cout << "The total weight of the tower is "
              << tower.total_weight() << ".\n";

    auto balance{tower.check_balance()};
    std::cout << "The tower is "
              << (balance.balanced ? "" : "not ") << "balanced.\n";

    if (!balance.balanced) {
        std::cout << "Program '" << balance.wrong_program
                  << "' has the wrong weight.\n";

        std::cout << "Its weight would need to be "
                  << balance.correct_weight << ".\n";
    }
}
