use std::error::Error;
use std::io;

use aoc::day1::max_elf_calories;

fn main() -> Result<(), Box<dyn Error>> {
    println!("{}", max_elf_calories(io::stdin().lock())?);
    Ok(())
}
