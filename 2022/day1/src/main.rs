use std::error::Error;
use std::io;

fn max_elf_calories<B: io::BufRead>(mut input: B) -> Result<i32, io::Error> {
    let mut raw_line = String::new();
    let mut elves: Vec<Vec<i32>> = Vec::new();
    let mut elf: Vec<i32> = Vec::new();

    while input.read_line(&mut raw_line)? != 0 {
        let line = raw_line.trim();
        if line.is_empty() {
            if !elf.is_empty() {
                elves.push(elf.clone());
                elf.clear();
            }
        } else {
            let value: i32 = line.parse().unwrap_or(0);
            elf.push(value);
        }
        raw_line.clear();
    }
    elves.push(elf.clone());

    Ok(elves
        .iter()
        .map(|elf| elf.iter().sum::<i32>())
        .max()
        .unwrap_or(0))
}

fn main() -> Result<(), Box<dyn Error>> {
    println!("{}", max_elf_calories(io::stdin().lock())?);
    Ok(())
}
