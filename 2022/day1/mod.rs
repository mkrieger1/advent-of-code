use std::io;

struct ReadElves<B> {
    lines: std::io::Lines<B>,
}

impl<B> ReadElves<B>
where
    B: io::BufRead,
{
    fn new(input: B) -> ReadElves<B> {
        ReadElves {
            lines: input.lines(),
        }
    }
}

impl<B> Iterator for ReadElves<B>
where
    B: io::BufRead,
{
    type Item = Vec<i32>;

    fn next(&mut self) -> Option<Self::Item> {
        let mut elf: Vec<i32> = Vec::new();
        for line in &mut self.lines {
            let line = match line {
                Err(_) => break,
                Ok(line) => line,
            };
            let line = line.trim();
            if !line.is_empty() {
                let value: i32 = line.parse().unwrap_or(0);
                elf.push(value);
                continue;
            }
            if !elf.is_empty() {
                return Some(elf);
            }
        }
        Some(elf).filter(|elf| !elf.is_empty())
    }
}

pub fn max_elf_calories<B>(input: B) -> i32
where
    B: io::BufRead,
{
    ReadElves::new(input)
        .map(|elf| elf.iter().sum::<i32>())
        .max()
        .unwrap_or(0)
}

pub fn top_3_elves_calories<B>(input: B) -> i32
where
    B: io::BufRead,
{
    let elves = ReadElves::new(input);
    let top_calories = {
        let mut calories: Vec<i32> =
            elves.map(|elf| elf.iter().sum()).collect();
        calories.sort_unstable();
        calories.reverse();
        calories
    };
    top_calories.iter().take(3).sum()
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
    fn read_lines() {
        let read =
            |input| -> Vec<Vec<i32>> { ReadElves::new(input).collect() };
        assert_eq!(read("".as_bytes()), [] as [Vec<i32>; 0]);
        assert_eq!(read("1".as_bytes()), vec![[1]]);
        assert_eq!(read("1\n".as_bytes()), vec![[1]]);
        assert_eq!(read("1\n2".as_bytes()), vec![[1, 2]]);
        assert_eq!(read("1\n2\n".as_bytes()), vec![[1, 2]]);
        assert_eq!(read("1\n2\n\n".as_bytes()), vec![[1, 2]]);
        assert_eq!(read("1\n\n".as_bytes()), vec![[1]]);
        assert_eq!(read("1\n\n2".as_bytes()), vec![[1], [2]]);
        assert_eq!(read("1\n\n2\n".as_bytes()), vec![[1], [2]]);
        assert_eq!(read("1\n\n2\n\n".as_bytes()), vec![[1], [2]]);
        assert_eq!(read("1\n\n\n2\n".as_bytes()), vec![[1], [2]]);
        assert_eq!(read("\n".as_bytes()), [] as [Vec<i32>; 0]);
        assert_eq!(read("\n1".as_bytes()), vec![[1]]);
        assert_eq!(read("\n1\n".as_bytes()), vec![[1]]);
        assert_eq!(read("\n1\n2".as_bytes()), vec![[1, 2]]);
        assert_eq!(read("\n1\n2\n".as_bytes()), vec![[1, 2]]);
        assert_eq!(read("\n1\n\n2".as_bytes()), vec![[1], [2]]);
        assert_eq!(read("\n1\n\n2\n".as_bytes()), vec![[1], [2]]);
        assert_eq!(read("\n1\n\n2\n\n".as_bytes()), vec![[1], [2]]);
        assert_eq!(read("\n\n".as_bytes()), [] as [Vec<i32>; 0]);
        assert_eq!(read("\n\n1".as_bytes()), vec![[1]]);
        assert_eq!(read("\n\n1\n".as_bytes()), vec![[1]]);
    }

    #[test]
    fn part1_example() {
        assert_eq!(max_elf_calories(EXAMPLE.as_bytes()), 24000);
    }

    #[test]
    fn part2_example() {
        assert_eq!(top_3_elves_calories(EXAMPLE.as_bytes()), 45000);
    }
}
