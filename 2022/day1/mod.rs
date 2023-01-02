use std::io;

pub fn max_elf_calories<B>(mut input: B) -> Result<i32, io::Error>
where
    B: io::BufRead,
{
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

pub fn top_3_elves_calories<B>(mut input: B) -> Result<i32, io::Error>
where
    B: io::BufRead,
{
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

    let top_calories = {
        let mut calories: Vec<i32> =
            elves.iter().map(|elf| elf.iter().sum()).collect();
        calories.sort_unstable();
        calories.reverse();
        calories
    };
    Ok(top_calories.iter().take(3).sum())
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE: &str = "
    1000
    2000
    3000

    4000

    5000
    6000

    7000
    8000
    9000

    10000
    ";

    #[test]
    fn part1_example() {
        assert_eq!(max_elf_calories(EXAMPLE.as_bytes()).unwrap(), 24000);
    }

    #[test]
    fn part2_example() {
        assert_eq!(top_3_elves_calories(EXAMPLE.as_bytes()).unwrap(), 45000);
    }
}
