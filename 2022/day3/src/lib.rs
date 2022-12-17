use std::borrow::Borrow;
use std::collections::HashSet;

fn priority_of_wrong_item(line: &str) -> i32 {
    let n = line.len();
    let first_compartment = HashSet::<_>::from_iter(line[..n / 2].bytes());
    let second_compartment = HashSet::<_>::from_iter(line[n / 2..].bytes());
    let wrong_item = first_compartment.intersection(&second_compartment).next();
    priority_of_item(*wrong_item.expect("at least one common item"))
}

fn priority_of_item(item: u8) -> i32 {
    let offset = {
        if item >= b'a' {
            item - b'a'
        } else {
            item - b'A' + 26
        }
    };
    (offset + 1).into()
}

pub fn rucksack_part1<I>(input: I) -> i32
where
    I: IntoIterator,
    I::Item: Borrow<str>,
{
    input
        .into_iter()
        .filter_map(|line| {
            let line = line.borrow().trim();
            if line.is_empty() {
                None
            } else {
                Some(line.to_string())
            }
        })
        .map(|line| priority_of_wrong_item(&line))
        .sum()
}

pub fn rucksack_part2<I>(_input: I) -> i32
where
    I: IntoIterator,
    I::Item: Borrow<str>,
{
    0
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE: &str = "
    vJrwpWtwJgWrhcsFMMfFFhFp
    jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
    PmmdzqPrVvPwwTWBwg
    wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
    ttgJtRGJQctTZtZT
    CrZsJsPPZsGzwwsLwLmpwMDw
    ";

    #[test]
    fn test_rucksack_part1() {
        assert_eq!(rucksack_part1(EXAMPLE.lines()), 157);
    }

    #[test]
    fn test_priority_of_wrong_item() {
        assert_eq!(priority_of_wrong_item("vJrwpWtwJgWrhcsFMMfFFhFp"), 16);
        assert_eq!(
            priority_of_wrong_item("jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL"),
            38
        );
        assert_eq!(priority_of_wrong_item("PmmdzqPrVvPwwTWBwg"), 42);
        assert_eq!(priority_of_wrong_item("wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn"), 22);
        assert_eq!(priority_of_wrong_item("ttgJtRGJQctTZtZT"), 20);
        assert_eq!(priority_of_wrong_item("CrZsJsPPZsGzwwsLwLmpwMDw"), 19);
    }
}
