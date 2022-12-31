use std::borrow::Borrow;
use std::collections::HashSet;

type Item = u8;

fn wrong_item(line: &str) -> Item {
    let n = line.len();
    let first_compartment = HashSet::<_>::from_iter(line[..n / 2].bytes());
    let second_compartment = HashSet::<_>::from_iter(line[n / 2..].bytes());
    let common = first_compartment.intersection(&second_compartment).next();
    *common.expect("There should be one common item")
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

fn badge_items_in_groups(lines: Vec<String>) -> Vec<Item> {
    let mut badge_items = Vec::new();
    let mut lines = lines.iter();
    loop {
        // TODO factor out repeated code
        let mut candidates: HashSet<Item> = match lines.next() {
            None => break,
            Some(line) => line.bytes().collect(),
        };

        let line2: HashSet<Item> = match lines.next() {
            None => break,
            Some(line) => line.bytes().collect(),
        };
        // TODO try https://stackoverflow.com/a/55977965/
        candidates = candidates.intersection(&line2).cloned().collect();

        let line3: HashSet<Item> = match lines.next() {
            None => break,
            Some(line) => line.bytes().collect(),
        };
        let common = candidates.intersection(&line3).next();

        badge_items.push(*common.expect("There should be one common item"));
    }
    badge_items
}

pub fn rucksack_part2<I>(input: I) -> i32
where
    I: IntoIterator,
    I::Item: Borrow<str>,
{
    let lines: Vec<String> = input
        .into_iter()
        .filter_map(|line| {
            let line = line.borrow().trim();
            if line.is_empty() {
                None
            } else {
                Some(line.to_string())
            }
        })
        .collect();

    // TODO how to chain the iterators
    let badge_items = badge_items_in_groups(lines);

    badge_items.iter().map(|item| priority_of_item(*item)).sum()
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE: [&str; 6] = [
        "vJrwpWtwJgWrhcsFMMfFFhFp",
        "jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL",
        "PmmdzqPrVvPwwTWBwg",
        "wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn",
        "ttgJtRGJQctTZtZT",
        "CrZsJsPPZsGzwwsLwLmpwMDw",
    ];

    #[test]
    fn test_rucksack_part1() {
        assert_eq!(rucksack_part1(EXAMPLE), 157);
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
        assert_eq!(wrong_item(EXAMPLE[0]), b'p');
        assert_eq!(wrong_item(EXAMPLE[1]), b'L');
        assert_eq!(wrong_item(EXAMPLE[2]), b'P');
        assert_eq!(wrong_item(EXAMPLE[3]), b'v');
        assert_eq!(wrong_item(EXAMPLE[4]), b't');
        assert_eq!(wrong_item(EXAMPLE[5]), b's');
    }

    #[test]
    fn test_badge_items_in_groups() {
        let lines = EXAMPLE.iter().map(|s| s.to_string()).collect();
        assert_eq!(badge_items_in_groups(lines), [b'r', b'Z']);
    }

    #[test]
    fn test_rucksack_part2() {
        assert_eq!(rucksack_part2(EXAMPLE), 70);
    }
}
