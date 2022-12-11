use std::error::Error;
use std::io;
use std::io::BufRead;

use day2::{Part2, RockPaperScissors};

fn main() -> Result<(), Box<dyn Error>> {
    let lines = io::stdin().lock().lines().filter_map(Result::ok);
    println!("{}", RockPaperScissors { strategy: Part2 }.play(lines));
    Ok(())
}
