use std::io;
use std::io::BufRead;

use aoc::day4::{run, FullOverlap};

fn main() {
    let lines = io::stdin().lock().lines().filter_map(Result::ok);
    println!("{}", run::<_, FullOverlap>(lines));
}