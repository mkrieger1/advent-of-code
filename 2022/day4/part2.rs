use std::io;

use aoc::day4::{run, PartialOverlap};

fn main() {
    println!("{}", run::<_, PartialOverlap>(io::stdin().lock()));
}
