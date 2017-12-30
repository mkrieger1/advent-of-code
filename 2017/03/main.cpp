#include "spiral_memory.h"

#include <cassert>
#include <iostream>
#include <vector>

struct TestCase {
    Location location;
    Location::Distance distance;
};

int main()
{
    std::vector<TestCase> tests{
        {{1}, 0},
        {{9}, 2},
        {{10}, 3},
        {{11}, 2},
        {{12}, 3},
        {{13}, 4},
        {{14}, 3},
        {{23}, 2},
        {{1024}, 31}
    };

    for (auto const& test : tests) {
        assert(test.location.distance_origin() == test.distance);
    }

    Location::Address a;
    std::cin >> a;
    std::cout << Location{a}.distance_origin() << '\n';
}
