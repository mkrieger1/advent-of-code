#include <cassert>
#include <cstddef>
#include <cmath>
#include <iostream>
#include <vector>

// Address:
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

// Phase:
// 11 10  9  8  7  6  5
// 12  7  6  5  4  3  4
// 13  8  3  2  1  2  3
// 14  9  4  0  0  1  2
// 15 10  5  6  7  0  1
// 16 11 12 13 14 15  0
// 17 18 19 20 21 22 23

// Distance = Radius + Angle

struct Radius { std::size_t value; };
struct Phase { std::size_t value; };
struct Address { std::size_t value; };

// Return the number of locations within the radius.
// 0 -> 1,  1 -> 9,  2 -> 25,  ...
std::size_t num_locations(const Radius& r)
{
    return std::pow(2 * r.value + 1, 2);
}

// Return the maximum phase for the given radius.
// 0 -> 0, 1 -> 7, 2 -> 15, 3 -> 23
Phase max_phase(const Radius& r)
{
    if (r.value == 0) return {0};
    return {8 * r.value - 1};
}

class Location {
public:
    Location(const Radius& r, const Phase& ph)
      : r_{r},
        ph_{ph},
        addr_{static_cast<std::size_t>(
            r.value == 0 ? 1
            : std::pow(2 * r.value - 1, 2) + ph.value + 1
        )}
    {
        if (ph.value > max_phase(r).value) {
            throw "Phase too large.";
            // TODO throw appropriate exception
        }
    }

    Location(const Address& addr)
      : r_{0},
        ph_{0},
        addr_{addr}
    {
        if (addr.value < 1) {
            throw "Address must be 1 or higher.";
            // TODO throw appropriate exception
        }
        while (num_locations(r_) < addr.value) ++r_.value;
        if (r_.value > 0) {
            std::size_t num{num_locations({r_.value - 1})};
            ph_ = {addr.value - num};
        }
    }

    Radius radius() const { return r_; }
    Phase phase() const { return ph_; }
    Address address() const { return addr_; }

    int angle() const
    {
        if (r_.value == 0) return 0;
        int signed_angle(ph_.value % (2 * r_.value) - r_.value);
        return std::abs(signed_angle);
    }

    int distance() const
    {
        return r_.value + angle();
    }

private:
    Radius r_{0};
    Phase ph_{0};
    Address addr_{1};
};

struct TestCase {
    Location location;
    int distance;
};

int main()
{
    std::vector<TestCase> tests{
        {{Address{1}}, 0},
        {{Address{9}}, 2},
        {{Address{10}}, 3},
        {{Address{11}}, 2},
        {{Address{12}}, 3},
        {{Address{13}}, 4},
        {{Address{14}}, 3},
        {{Address{23}}, 2},
        {{Address{1024}}, 31}
    };

    for (auto const& test : tests) {
        assert(test.location.distance() == test.distance);
    }

    std::size_t a;
    std::cin >> a;
    std::cout << Location{Address{a}}.distance() << '\n';
}
