use std::io;
use std::io::BufRead;

use aoc::day3::rucksack_part2;

fn main() {
    let lines = io::stdin().lock().lines().filter_map(Result::ok);
    println!("{}", rucksack_part2(lines));
}
