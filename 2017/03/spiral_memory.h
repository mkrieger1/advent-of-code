#ifndef SPIRAL_MEMORY_H
#define SPIRAL_MEMORY_H

#include <cstddef>
#include <stdexcept>

struct Polar {
    // Radius:
    //  2  2  2  2  2
    //  2  1  1  1  2
    //  2  1  0  1  2
    //  2  1  1  1  2
    //  2  2  2  2  2
    using Radius = std::size_t;

    // Angle:
    // 11 10  9  8  7  6  5
    // 12  7  6  5  4  3  4
    // 13  8  3  2  1  2  3
    // 14  9  4  0  0  1  2
    // 15 10  5  6  7  0  1
    // 16 11 12 13 14 15  0
    // 17 18 19 20 21 22 23
    using Angle = std::size_t;

    struct InvalidAngle : public std::runtime_error {
        InvalidAngle();
    };

    // Return the maximum angle for the given radius.
    // 0 -> 0, 1 -> 7, 2 -> 15, 3 -> 23
    static Angle max_angle(const Radius&);

    Polar() = default;
    Polar(const Radius&, const Angle&);

    Radius r{0};
    Angle phi{0};
};

struct Cartesian {
    using Coordinate = long long int;

    // Return the coordinates rotated clockwise by 90 degrees.
    // (1, 0) -> (0, -1) -> (-1, 0) -> (0, 1)
    Cartesian rotated_clockwise();

    Coordinate x{0};
    Coordinate y{0};
};

class Location {
public:
    // Address:
    // 37 36 35 34 33 32 31
    // 38 17 16 15 14 13 30
    // 39 18  5  4  3 12 29
    // 40 19  6  1  2 11 28
    // 41 20  7  8  9 10 27
    // 42 21 22 23 24 25 26
    // 43 44 45 46 47 48 49
    using Address = std::size_t;

    // Distance:
    //  4  3  2  3  4
    //  3  2  1  2  3
    //  2  1  0  1  2
    //  3  2  1  2  3
    //  4  3  2  3  4
    using Distance = std::size_t;

    struct InvalidAddress : public std::runtime_error {
        InvalidAddress();
    };

    Location(const Address&);
    Location(const Polar&);
    Location(const Cartesian&);

    Address address() const;
    Polar::Radius radius() const;
    Polar::Angle angle() const;
    Cartesian::Coordinate x() const;
    Cartesian::Coordinate y() const;
    Distance distance_origin() const;

private:
    // Return the number of locations within the radius.
    // 0 -> 1,  1 -> 9,  2 -> 25,  ...
    static std::size_t num_locations(const Polar::Radius&);

    // Return the address of the location given the polar coordinates.
    static Address address_from_polar(const Polar&);

    // Return the polar coordinates of the location with the given address.
    static Polar polar_from_address(const Address&);

    // Return the cartesian coordinates of the location given the polar coordinates.
    static Cartesian cartesian_from_polar(const Polar&);

    // Return the polar coordinates of the location given the cartesian coordinates.
    static Polar polar_from_cartesian(const Cartesian&);

    Polar polar_;
    Cartesian cartesian_;
    Address addr_{1};
};

#endif
