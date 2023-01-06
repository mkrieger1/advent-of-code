use std::io;
use std::io::BufRead;

use aoc::day2::rock_paper_scissors_part2;

fn main() {
    let lines = io::stdin().lock().lines().filter_map(Result::ok);
    println!("{}", rock_paper_scissors_part2(lines));
}
