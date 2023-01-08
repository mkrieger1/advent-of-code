use std::io;

struct BlankLinesSplit<B> {
    lines: std::io::Lines<B>,
}

impl<B> BlankLinesSplit<B>
where
    B: io::BufRead,
{
    fn new(input: B) -> BlankLinesSplit<B> {
        BlankLinesSplit {
            lines: input.lines(),
        }
    }
}

impl<B> Iterator for BlankLinesSplit<B>
where
    B: io::BufRead,
{
    type Item = Vec<String>;

    fn next(&mut self) -> Option<Self::Item> {
        let mut part: Vec<String> = Vec::new();
        for line in &mut self.lines {
            let line = match line {
                Err(_) => break,
                Ok(line) => line,
            };
            let line = line.trim();
            if !line.is_empty() {
                part.push(line.to_string());
                continue;
            }
            if !part.is_empty() {
                return Some(part);
            }
        }
        Some(part).filter(|part| !part.is_empty())
    }
}

fn elf_calories(lines: Vec<String>) -> i32 {
    lines
        .iter()
        .map(|line| line.parse::<i32>().unwrap_or(0))
        .sum()
}

pub fn max_elf_calories<B>(input: B) -> i32
where
    B: io::BufRead,
{
    BlankLinesSplit::new(input)
        .map(elf_calories)
        .max()
        .unwrap_or(0)
}

pub fn top_3_elves_calories<B>(input: B) -> i32
where
    B: io::BufRead,
{
    let parts = BlankLinesSplit::new(input);
    let top_calories = {
        let mut calories: Vec<i32> = parts.map(elf_calories).collect();
        calories.sort_unstable();
        calories
    };
    top_calories.iter().rev().take(3).sum()
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
        let read = |input| -> Vec<Vec<String>> {
            BlankLinesSplit::new(input).collect()
        };
        assert_eq!(read("".as_bytes()), [] as [Vec<String>; 0]);
        assert_eq!(read("1".as_bytes()), vec![["1"]]);
        assert_eq!(read("1\n".as_bytes()), vec![["1"]]);
        assert_eq!(read("1\n2".as_bytes()), vec![["1", "2"]]);
        assert_eq!(read("1\n2\n".as_bytes()), vec![["1", "2"]]);
        assert_eq!(read("1\n2\n\n".as_bytes()), vec![["1", "2"]]);
        assert_eq!(read("1\n\n".as_bytes()), vec![["1"]]);
        assert_eq!(read("1\n\n2".as_bytes()), vec![["1"], ["2"]]);
        assert_eq!(read("1\n\n2\n".as_bytes()), vec![["1"], ["2"]]);
        assert_eq!(read("1\n\n2\n\n".as_bytes()), vec![["1"], ["2"]]);
        assert_eq!(read("1\n\n\n2\n".as_bytes()), vec![["1"], ["2"]]);
        assert_eq!(read("\n".as_bytes()), [] as [Vec<String>; 0]);
        assert_eq!(read("\n1".as_bytes()), vec![["1"]]);
        assert_eq!(read("\n1\n".as_bytes()), vec![["1"]]);
        assert_eq!(read("\n1\n2".as_bytes()), vec![["1", "2"]]);
        assert_eq!(read("\n1\n2\n".as_bytes()), vec![["1", "2"]]);
        assert_eq!(read("\n1\n\n2".as_bytes()), vec![["1"], ["2"]]);
        assert_eq!(read("\n1\n\n2\n".as_bytes()), vec![["1"], ["2"]]);
        assert_eq!(read("\n1\n\n2\n\n".as_bytes()), vec![["1"], ["2"]]);
        assert_eq!(read("\n\n".as_bytes()), [] as [Vec<String>; 0]);
        assert_eq!(read("\n\n1".as_bytes()), vec![["1"]]);
        assert_eq!(read("\n\n1\n".as_bytes()), vec![["1"]]);
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
