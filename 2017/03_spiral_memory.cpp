#include <cassert>
#include <cstddef>
#include <cmath>
#include <iostream>
#include <stdexcept>
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

// Lateral offset:
//  3  2  1  0 -1 -2  3
// -2  2  1  0 -1  2  2
// -1 -1  1  0  1  1  1
//  0  0  0  0  0  0  0
//  1  1  1  0  1 -1 -1
//  2  2 -1  0  1  2 -2
//  3 -2 -1  0  1  2  3

// Angle:
// 11 10  9  8  7  6  5
// 12  7  6  5  4  3  4
// 13  8  3  2  1  2  3
// 14  9  4  0  0  1  2
// 15 10  5  6  7  0  1
// 16 11 12 13 14 15  0
// 17 18 19 20 21 22 23

// Distance = Radius + abs(Lateral offset)

struct Polar {
    using Radius = std::size_t;
    using Angle = std::size_t;

    struct InvalidAngle : public std::runtime_error {
        InvalidAngle()
            : std::runtime_error("Angle is too large.") // TODO include values
        {}
    };

    // Return the maximum angle for the given radius.
    // 0 -> 0, 1 -> 7, 2 -> 15, 3 -> 23
    static Angle max_angle(const Radius& r)
    {
        if (r == 0) return 0;
        return 8 * r - 1;
    }

    Polar() = default;

    Polar(const Radius& r_, const Angle& phi_)
    : r{r_}, phi{phi_}
    {
        if (phi_ > max_angle(r_)) throw InvalidAngle();
    }

    Radius r{0};
    Angle phi{0};
};


class Location {
public:
    using Address = std::size_t;
    using LateralOffset = long long int;
    using Distance = std::size_t;

    struct InvalidAddress : public std::runtime_error {
        InvalidAddress()
            : std::runtime_error("Address must be 1 or greater.")
        {}
    };

private:
    // Return the number of locations within the radius.
    // 0 -> 1,  1 -> 9,  2 -> 25,  ...
    static std::size_t num_locations(const Polar::Radius& r)
    {
        return std::pow(2 * r + 1, 2);
    }

    // Return the address of the location given the polar coordinates.
    static Address address_from_polar(const Polar& p)
    {
        if (p.r == 0) return 1;
        return num_locations(p.r - 1) + p.phi + 1;
    }

    // Return the polar coordinates of the location with the given address.
    static Polar polar_from_address(const Address& addr)
    {
        Polar p;
        while (num_locations(p.r) < addr) ++p.r;
        if (p.r > 0) p.phi = addr - num_locations(p.r - 1) - 1;
        return p;
    }

public:
    Location(const Polar& p)
      : polar_{p},
        addr_{address_from_polar(p)}
    {}

    Location(const Address& addr)
      : polar_{polar_from_address(addr)},
        addr_{addr}
    {
        if (addr < 1) throw InvalidAddress();
    }

    Polar::Radius radius() const { return polar_.r; }
    Polar::Angle angle() const { return polar_.phi; }
    Address address() const { return addr_; }

    LateralOffset lateral_offset() const
    {
        Polar::Radius r{radius()};
        if (r == 0) return 0;
        return angle() % (2 * r) - r + 1;
    }

    Distance distance() const
    {
        return radius() + std::abs(lateral_offset());
    }

private:
    Polar polar_;
    Address addr_{1};
};

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
        assert(test.location.distance() == test.distance);
    }

    Location::Address a;
    std::cin >> a;
    std::cout << Location{a}.distance() << '\n';
}
