use std::error::Error;
use std::io;

use day2::rock_paper_scissors;

fn main() -> Result<(), Box<dyn Error>> {
    println!("{}", rock_paper_scissors(io::stdin().lock())?);
    Ok(())
}
