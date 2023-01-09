use std::collections::HashSet;
use std::io::BufRead;

use crate::input::trimmed_not_blank;

type Item = u8;
type Group = [String; 3];

struct GroupLines<I> {
    lines: I,
}

impl<I> Iterator for GroupLines<I>
where
    I: Iterator<Item = String>,
{
    type Item = Group;

    fn next(&mut self) -> Option<Group> {
        let lines = &mut self.lines;
        let result: Vec<String> = lines.take(3).collect();
        result.try_into().ok()
    }
}

fn wrong_item(line: &str) -> Item {
    let n = line.len();
    let first_compartment: HashSet<Item> = line[..n / 2].bytes().collect();
    let second_compartment: HashSet<Item> = line[n / 2..].bytes().collect();
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

pub fn rucksack_part1<I: BufRead>(input: I) -> i32 {
    input
        .lines()
        .filter_map(|line| trimmed_not_blank(&line.ok()?))
        .map(|line| wrong_item(&line))
        .map(priority_of_item)
        .sum()
}

fn common_item_in_group(group: &Group) -> Item {
    let mut candidates: HashSet<Item> = group[0].bytes().collect();
    let line2: HashSet<Item> = group[1].bytes().collect();

    // TODO try https://stackoverflow.com/a/55977965/
    candidates = candidates.intersection(&line2).cloned().collect();

    let line3: HashSet<Item> = group[2].bytes().collect();
    let common = candidates.intersection(&line3).next();

    *common.expect("There should be one common item")
}

pub fn rucksack_part2<I: BufRead>(input: I) -> i32 {
    let lines = input
        .lines()
        .filter_map(|line| trimmed_not_blank(&line.ok()?));

    GroupLines { lines }
        .map(|g| common_item_in_group(&g))
        .map(priority_of_item)
        .sum()
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
    fn part1_example() {
        assert_eq!(rucksack_part1(EXAMPLE.as_bytes()), 157);
    }

    #[test]
    fn priority() {
        assert_eq!(priority_of_item(b'a'), 1);
        assert_eq!(priority_of_item(b'z'), 26);
        assert_eq!(priority_of_item(b'A'), 27);
        assert_eq!(priority_of_item(b'Z'), 52);
    }

    #[test]
    fn wrong_item_examples() {
        let lines: Vec<String> =
            EXAMPLE.lines().filter_map(trimmed_not_blank).collect();
        assert_eq!(wrong_item(&lines[0]), b'p');
        assert_eq!(wrong_item(&lines[1]), b'L');
        assert_eq!(wrong_item(&lines[2]), b'P');
        assert_eq!(wrong_item(&lines[3]), b'v');
        assert_eq!(wrong_item(&lines[4]), b't');
        assert_eq!(wrong_item(&lines[5]), b's');
    }

    #[test]
    fn badge_items_examples() {
        let lines = EXAMPLE.lines().filter_map(trimmed_not_blank);
        let groups: Vec<Group> = GroupLines { lines }.collect();
        assert_eq!(common_item_in_group(&groups[0]), b'r');
        assert_eq!(common_item_in_group(&groups[1]), b'Z');
    }

    #[test]
    fn part2_example() {
        assert_eq!(rucksack_part2(EXAMPLE.as_bytes()), 70);
    }
}
