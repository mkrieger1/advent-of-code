use std::borrow::Borrow;

#[derive(Debug, PartialEq)]
struct Range {
    begin: u32,
    end: u32,
}

impl Range {
    pub fn contains(&self, other: &Range) -> bool {
        self.begin <= other.begin && self.end >= other.end
    }
}

fn parse_range(input: &str) -> Option<Range> {
    let parts: Vec<&str> = input.split('-').collect();
    if parts.len() != 2 {
        return None;
    }
    Some(Range {
        begin: parts[0].parse().ok()?,
        end: parts[1].parse().ok()?,
    })
}

fn parse_ranges(input: &str) -> Option<(Range, Range)> {
    let parts: Vec<&str> = input.split(',').collect();
    if parts.len() != 2 {
        return None;
    }
    Some((parse_range(parts[0])?, parse_range(parts[1])?))
}

fn one_range_contains_other(input: &str) -> Option<bool> {
    let (first, second) = parse_ranges(input)?;
    Some(first.contains(&second) || second.contains(&first))
}

pub fn cleanup_part1<I>(input: I) -> i32
where
    I: IntoIterator,
    I::Item: Borrow<str>,
{
    input
        .into_iter()
        .map(|line| {
            one_range_contains_other(line.borrow()).unwrap_or_default() as i32
        })
        .sum()
}

pub fn cleanup_part2<I>(input: I) -> i32
where
    I: IntoIterator,
    I::Item: Borrow<str>,
{
    todo!()
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE: [&str; 6] = [
        "2-4,6-8", "2-3,4-5", "5-7,7-9", "2-8,3-7", "6-6,4-6", "2-6,4-8",
    ];

    #[test]
    fn test_cleanup_part1() {
        assert_eq!(cleanup_part1(EXAMPLE), 2);
    }

    #[test]
    fn test_contains() {
        assert!(
            Range { begin: 2, end: 8 }.contains(&Range { begin: 3, end: 7 })
        );
        assert!(
            Range { begin: 4, end: 6 }.contains(&Range { begin: 6, end: 6 })
        );
    }

    #[test]
    fn test_parse() {
        assert_eq!(
            parse_ranges(EXAMPLE[0]),
            Some((Range { begin: 2, end: 4 }, Range { begin: 6, end: 8 }))
        )
    }
}
