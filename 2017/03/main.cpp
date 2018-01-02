#include "spiral_memory.h"

#include <cassert>
#include <cstddef>
#include <iostream>
#include <vector>
#include <unordered_map>

struct TestCaseDistance {
    Location::Address address;
    Location::Distance distance;
};

struct TestCaseCartesian {
    Location::Address address;
    Cartesian coords;
};

void run_tests()
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
        Location loc2{Cartesian{test.coords.x, test.coords.y}};
        assert(loc2.address() == test.address);
    }
}

using SpiralSum = std::size_t;
using SpiralSums = std::unordered_map<Location::Address, SpiralSum>;

SpiralSum get_sum(Location::Address addr, SpiralSums& sums)
{
    auto result{sums.find(addr)};
    if (result != std::end(sums)) return result->second;

    SpiralSum s{0};
    for (auto const& n : Location{addr}.neighbors()) {
        if (n.address() < addr) {
            s += get_sum(n.address(), sums);
        }
    }
    sums.insert({addr, s});
    return s;
}

void part1()
{
    Location::Address addr;
    std::cout << "Enter an address: ";
    std::cin >> addr;
    Location loc{addr};
    std::cout << "The distance of address " << addr
              << " is " << loc.distance_origin() << '\n';
}

void part2()
{
    SpiralSum target;
    std::cout << "Enter a target sum: ";
    std::cin >> target;

    Location::Address addr{1};
    SpiralSums sums{{addr, 1}};
    SpiralSum s{};
    while ((s = get_sum(addr, sums)) <= target) ++addr;
    std::cout << "The first value written larger than " << target
              << " is " << s << '\n';
}

int main()
{
    run_tests();
    part1();
    part2();
}
