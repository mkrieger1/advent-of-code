#include "spiral_memory.h"

#include <algorithm>
#include <cassert>
#include <cmath>

Polar::InvalidAngle::InvalidAngle()
  : std::runtime_error("Angle is too large.") // TODO include values
{}

Location::InvalidAddress::InvalidAddress()
  : std::runtime_error("Address must be 1 or greater.")
{}

Polar::Polar(const Radius& r_, const Angle& phi_)
  : r{r_}, phi{phi_}
{
    if (phi_ > max_angle(r_)) throw InvalidAngle();
}

Location::Location(const Polar& p)
  : polar_{p},
    cartesian_{cartesian_from_polar(p)},
    addr_{address_from_polar(p)}
{}

Location::Location(const Cartesian& c)
  : polar_{polar_from_cartesian(c)},
    cartesian_{c},
    addr_{address_from_polar(polar_)}
{}

Location::Location(const Address& addr)
  : polar_{polar_from_address(addr)},
    cartesian_{cartesian_from_polar(polar_)},
    addr_{addr}
{
    if (addr < 1) throw InvalidAddress();
}

// Return the maximum angle for the given radius.
// 0 -> 0, 1 -> 7, 2 -> 15, 3 -> 23
Polar::Angle Polar::max_angle(const Radius& r)
{
    if (r == 0) return 0;
    return 8 * r - 1;
}

// Return the coordinates rotated clockwise by 90 degrees.
// (1, 0) -> (0, -1) -> (-1, 0) -> (0, 1)
Cartesian Cartesian::rotated_clockwise()
{
    return {y, -x};
}

// Return the number of locations with radius smaller than the given value.
// 0 -> 0,  1 -> 1,  2 -> 9,  3 -> 25,  ...
std::size_t Location::num_locations(const Polar::Radius& r)
{
    if (r == 0) return 0;
    return std::pow(2 * r - 1, 2);
}

// Return the address of the location given the polar coordinates.
Location::Address Location::address_from_polar(const Polar& p)
{
    return num_locations(p.r) + p.phi + 1;
}

// Return the polar coordinates of the location with the given address.
Polar Location::polar_from_address(const Address& addr)
{
    Polar::Radius r(std::ceil((std::sqrt(addr) - 1) / 2));
    return {r, addr - num_locations(r) - 1};
}

// Return the cartesian coordinates of the location given the polar coordinates.
Cartesian Location::cartesian_from_polar(const Polar& p)
{
    if (p.r == 0) return {0, 0};

    auto side_length{2 * p.r};
    auto side{p.phi / side_length};
    assert(0 <= side && side < 4);

    Cartesian::Coordinate u(p.r);
    Cartesian::Coordinate v(p.phi % side_length - side_length / 2 + 1);
    assert(-u < v && v <= u);

    switch (side) {
        case 0:  return { u,  v};
        case 1:  return {-v,  u};
        case 2:  return {-u, -v};
        default: return { v, -u};
    }
}

// Return the polar coordinates of the location given the cartesian coordinates.
Polar Location::polar_from_cartesian(const Cartesian& c)
{
    if (c.x == 0 && c.y == 0) return {0, 0};

    int side{0};
    Cartesian t{c};

    while (!(-t.x < t.y && t.y <= t.x)) {
        ++side;
        t = t.rotated_clockwise();
    }
    assert(side < 4);

    Polar::Radius r(t.x);
    auto side_length{2 * r};
    Polar::Angle phi{side * side_length + side_length / 2 + t.y - 1};
    return {r, phi};
}

Polar::Radius Location::radius() const
{
    return polar_.r;
}

Polar::Angle Location::angle() const
{
    return polar_.phi;
}

Location::Address Location::address() const
{
    return addr_;
}

Cartesian::Coordinate Location::x() const
{
    return cartesian_.x;
}

Cartesian::Coordinate Location::y() const
{
    return cartesian_.y;
}

Location::Distance Location::distance_origin() const
{
    return std::abs(x()) + std::abs(y());
}

// Return a list of the 8 neighbor locations.
std::vector<Location> Location::neighbors() const
{
    std::vector<Location> result;
    Cartesian straight{1, 0}, diagonal{1, 1};
    for (int i{0}; i < 4; ++i) {
        result.push_back({Cartesian{x() + straight.x, y() + straight.y}});
        result.push_back({Cartesian{x() + diagonal.x, y() + diagonal.y}});
        straight = straight.rotated_clockwise();
        diagonal = diagonal.rotated_clockwise();
    }
    return result;
}
