use std::error::Error;
use std::io;
use std::io::BufRead;

use aoc::day4::{run, PartialOverlap};

fn main() -> Result<(), Box<dyn Error>> {
    let lines = io::stdin().lock().lines().filter_map(Result::ok);
    println!("{}", run::<_, PartialOverlap>(lines));
    Ok(())
}
