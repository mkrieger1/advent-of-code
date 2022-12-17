use std::borrow::Borrow;
use std::collections::HashSet;

type Item = u8;

fn wrong_item(line: &str) -> Item {
    let n = line.len();
    let first_compartment = HashSet::<_>::from_iter(line[..n / 2].bytes());
    let second_compartment = HashSet::<_>::from_iter(line[n / 2..].bytes());
    let common = first_compartment.intersection(&second_compartment).next();
    *common.expect("at least one common item")
}

fn priority_of_item(item: Item) -> i32 {
    ({
        if item >= b'a' {
            item - b'a'
        } else {
            item - b'A' + 26
        }
    } + 1)
        .into()
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
        .map(|line| wrong_item(&line))
        .map(priority_of_item)
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
    fn test_priority_of_item() {
        assert_eq!(priority_of_item(b'a'), 1);
        assert_eq!(priority_of_item(b'z'), 26);
        assert_eq!(priority_of_item(b'A'), 27);
        assert_eq!(priority_of_item(b'Z'), 52);
    }

    #[test]
    fn test_wrong_item() {
        assert_eq!(wrong_item("vJrwpWtwJgWrhcsFMMfFFhFp"), b'p');
        assert_eq!(wrong_item("jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL"), b'L');
        assert_eq!(wrong_item("PmmdzqPrVvPwwTWBwg"), b'P');
        assert_eq!(wrong_item("wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn"), b'v');
        assert_eq!(wrong_item("ttgJtRGJQctTZtZT"), b't');
        assert_eq!(wrong_item("CrZsJsPPZsGzwwsLwLmpwMDw"), b's');
    }
}
