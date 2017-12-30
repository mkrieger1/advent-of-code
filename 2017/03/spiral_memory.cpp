#include "spiral_memory.h"

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
    addr_{address_from_polar(p)}
{}

Location::Location(const Address& addr)
  : polar_{polar_from_address(addr)},
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

// Return the number of locations within the radius.
// 0 -> 1,  1 -> 9,  2 -> 25,  ...
std::size_t Location::num_locations(const Polar::Radius& r)
{
    return std::pow(2 * r + 1, 2);
}

// Return the address of the location given the polar coordinates.
Location::Address Location::address_from_polar(const Polar& p)
{
    if (p.r == 0) return 1;
    return num_locations(p.r - 1) + p.phi + 1;
}

// Return the polar coordinates of the location with the given address.
Polar Location::polar_from_address(const Address& addr)
{
    Polar p;
    while (num_locations(p.r) < addr) ++p.r;
    if (p.r > 0) p.phi = addr - num_locations(p.r - 1) - 1;
    return p;
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

Location::LateralOffset Location::lateral_offset() const
{
    Polar::Radius r{radius()};
    if (r == 0) return 0;
    return angle() % (2 * r) - r + 1;
}

Location::Distance Location::distance() const
{
    return radius() + std::abs(lateral_offset());
}
