#include <cassert>
#include <cstddef>
#include <cmath>
#include <iostream>
#include <vector>

// Location:
// 17 16 15 14 13
// 18  5  4  3 12
// 19  6  1  2 11
// 20  7  8  9 10
// 21 22 23 24 25

// Radius:
//  2  2  2  2  2
//  2  1  1  1  2
//  2  1  0  1  2
//  2  1  1  1  2
//  2  2  2  2  2

// Angle:
//  2  1  0  1  2
//  1  1  0  1  1
//  0  0  0  0  0
//  1  1  0  1  1
//  2  1  0  1  2

// Distance = Radius + Angle

// Return the number of locations within the radius.
// 0 -> 1,  1 -> 9,  2 -> 25,  ...
std::size_t num_locations(int radius) {
    return std::pow(2 * radius + 1, 2);
}

// Return the radius of the location in the spiral memory.
int radius(int location) {
    int radius{0};
    while (num_locations(radius) < location) {
        ++radius;
    }
    return radius;
}

// Return the angle of the location in the spiral memory.
// For a location with radius R, its angle is between 0 and R.
// The first location (*) with radius R+1 is to the right of the last location
// with radius R, so its angle is R.
int angle(int location) {
    int r{radius(location)};
    if (r == 0) { return 0; }
    std::size_t num{num_locations(r - 1)};
    std::size_t rest{location - num};
    int a(rest % (2 * r) - r);
    return std::abs(a);
}

// Return the Manhattan distance from the memory location to the access port
// (at location 1).
int distance(int location) {
    return radius(location) + angle(location);
}

struct TestCase {
    int location;
    int distance;
};

int main() {
    std::vector<TestCase> tests{
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

    for (auto const& test : tests) {
        assert(distance(test.location) == test.distance);
    }

    int location;
    std::cin >> location;
    std::cout << distance(location) << '\n';
}
