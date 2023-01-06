use std::io;

use aoc::day4::{count_overlaps, FullOverlap};

fn main() {
    let input = io::stdin().lock();
    println!("{}", count_overlaps::<_, FullOverlap>(input));
}
