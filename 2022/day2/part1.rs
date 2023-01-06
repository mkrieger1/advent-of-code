use std::io;

use aoc::day2::{play, ShapeGiven};

fn main() {
    println!("{}", play::<_, ShapeGiven>(io::stdin().lock()));
}
