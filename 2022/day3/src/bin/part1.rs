use std::error::Error;
use std::io;
use std::io::BufRead;

use day3::rucksack_part1;

fn main() -> Result<(), Box<dyn Error>> {
    let lines = io::stdin().lock().lines().filter_map(Result::ok);
    println!("{}", rucksack_part1(lines));
    Ok(())
}
