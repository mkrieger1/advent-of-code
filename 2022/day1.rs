use std::error::Error;
use std::io;

fn main() -> Result<(), Box<dyn Error>> {
    let mut raw_line = String::new();
    let stdin = io::stdin();
    let mut elves: Vec<Vec<i32>> = Vec::new();
    let mut elf: Vec<i32> = Vec::new();

    while stdin.read_line(&mut raw_line)? != 0 {
        let line = raw_line.trim();
        if line.len() == 0 {
            if elf.len() > 0 {
                elves.push(elf.clone());
                elf.clear();
            }
        } else {
            let value: i32 = line.parse()?;
            elf.push(value);
        }
        raw_line.clear();
    }
    elves.push(elf.clone());

    let result = elves.iter().map(|elf| elf.iter().sum::<i32>()).max().unwrap();
    println!("{}", result);

    Ok(())
}
