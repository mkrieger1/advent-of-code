use std::io;
use std::io::BufRead;

use aoc::day3::rucksack_part1;

fn main() {
    let lines = io::stdin().lock().lines().filter_map(Result::ok);
    println!("{}", rucksack_part1(lines));
}
