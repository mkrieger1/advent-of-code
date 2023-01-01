use std::error::Error;
use std::io;

use aoc::day1::top_3_elves_calories;

fn main() -> Result<(), Box<dyn Error>> {
    println!("{}", top_3_elves_calories(io::stdin().lock())?);
    Ok(())
}
