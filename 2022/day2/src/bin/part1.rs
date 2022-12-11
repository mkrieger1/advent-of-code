use std::error::Error;
use std::io::BufRead;
use std::io;

use day2::rock_paper_scissors_part1;

fn main() -> Result<(), Box<dyn Error>> {
    let lines = io::stdin().lock().lines().filter_map(Result::ok);
    println!("{}", rock_paper_scissors_part1(lines));
    Ok(())
}
