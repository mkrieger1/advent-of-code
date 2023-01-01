use std::error::Error;
use std::io;
use std::io::BufRead;

use aoc::day4::cleanup_part2;

fn main() -> Result<(), Box<dyn Error>> {
    let lines = io::stdin().lock().lines().filter_map(Result::ok);
    println!("{}", cleanup_part2(lines));
    Ok(())
}
