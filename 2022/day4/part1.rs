use std::io;

use aoc::day4::{run, FullOverlap};

fn main() {
    println!("{}", run::<_, FullOverlap>(io::stdin().lock()));
}
