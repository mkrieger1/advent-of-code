#include "spiral_memory.h"

#include <cassert>
#include <iostream>
#include <vector>

struct TestCaseDistance {
    Location::Address address;
    Location::Distance distance;
};

struct TestCaseCartesian {
    Location::Address address;
    Cartesian coords;
};

int main()
{
    std::vector<TestCaseDistance> tests_distance{
        {1, 0},
        {9, 2},
        {10, 3},
        {11, 2},
        {12, 3},
        {13, 4},
        {14, 3},
        {23, 2},
        {1024, 31}
    };

    std::vector<TestCaseCartesian> tests_cartesian{
        {1, {0, 0}},
        {9, {1, -1}},
        {10, {2, -1}},
        {11, {2, 0}},
        {12, {2, 1}},
        {13, {2, 2}},
        {14, {1, 2}},
        {23, {0, -2}}
    };

    for (auto const& test : tests_distance) {
        assert(Location{test.address}.distance_origin() == test.distance);
    }

    for (auto const& test : tests_cartesian) {
        Location loc{test.address};
        assert(loc.x() == test.coords.x);
        assert(loc.y() == test.coords.y);
    }

    Location::Address a;
    std::cin >> a;
    std::cout << Location{a}.distance_origin() << '\n';
}
