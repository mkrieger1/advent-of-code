use std::io;

use aoc::day2::{play, OutcomeGiven};

fn main() {
    println!("{}", play::<_, OutcomeGiven>(io::stdin().lock()));
}
