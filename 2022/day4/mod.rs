use std::borrow::Borrow;

/*
 *  assuming  P <= Q,  R <= S
 *
 *  a := P >= R  (=> c)
 *  b := P >  S  (=> a, c, d)
 *  c := Q >= R
 *  d := Q >  S  (=> c)
 *                                 overlap
 *  a b c d       R       S        full partial
 *  0 0 0 0   P Q |       |        0    0
 *  0 0 0 1   -----invalid-----    .    .
 *  0 0 1 0   P   |  Q    |        0    1
 *  0 0 1 1   P   |       |   Q    1    1
 *  0 1 0 0   -----invalid-----    .    .
 *  0 1 0 1   -----invalid-----    .    .
 *  0 1 1 0   -----invalid-----    .    .
 *  0 1 1 1   -----invalid-----    .    .
 *  1 0 0 0   -----invalid-----    .    .
 *  1 0 0 1   -----invalid-----    .    .
 *  1 0 1 0       |  P  Q |        1    1
 *  1 0 1 1       |  P    |   Q    0    1
 *  1 1 0 0   -----invalid-----    .    .
 *  1 1 0 1   -----invalid-----    .    .
 *  1 1 1 0   -----invalid-----    .    .
 *  1 1 1 1       |       | P Q    0    0
 *
 *  Karnaugh maps:
 *                 full      partial
 *      b b
 *    . . . .      0 . x x   0 . . .
 *    . . . . d    x x . .   . . . .
 *  c . . . . d    1 x 0 0   1 . 0 1
 *  c . . . .      0 . x 1   1 . . 1
 *        a a
 *
 *  "." = don't care => can assume 1 ("x")
 *
 *  => full = !a && d || a && !d
 *     partial = !b && c
 */

#[derive(Debug, PartialEq)]
struct Range {
    begin: u32,
    end: u32,
}

impl Range {
    pub fn full_overlap(&self, other: &Range) -> bool {
        assert!(self.begin <= self.end);
        assert!(other.begin <= other.end);
        let a = self.begin >= other.begin;
        let d = self.end > other.end;
        !a && d || a && !d
    }

    pub fn partial_overlap(&self, other: &Range) -> bool {
        assert!(self.begin <= self.end);
        assert!(other.begin <= other.end);
        let b = self.begin > other.end;
        let c = self.end >= other.begin;
        !b && c
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

fn parse_full_overlap(input: &str) -> Option<bool> {
    let (first, second) = parse_ranges(input)?;
    Some(first.full_overlap(&second))
}

fn parse_partial_overlap(input: &str) -> Option<bool> {
    let (first, second) = parse_ranges(input)?;
    Some(first.partial_overlap(&second))
}

pub fn cleanup_part1<I>(input: I) -> i32
where
    I: IntoIterator,
    I::Item: Borrow<str>,
{
    input
        .into_iter()
        .map(|line| {
            parse_full_overlap(line.borrow()).unwrap_or_default() as i32
        })
        .sum()
}

pub fn cleanup_part2<I>(input: I) -> i32
where
    I: IntoIterator,
    I::Item: Borrow<str>,
{
    input
        .into_iter()
        .map(|line| {
            parse_partial_overlap(line.borrow()).unwrap_or_default() as i32
        })
        .sum()
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE: [&str; 6] = [
        "2-4,6-8", "2-3,4-5", "5-7,7-9", "2-8,3-7", "6-6,4-6", "2-6,4-8",
    ];

    #[test]
    fn part1_example() {
        assert_eq!(cleanup_part1(EXAMPLE), 2);
    }

    #[test]
    fn full_overlap_examples() {
        assert_eq!(parse_full_overlap(EXAMPLE[0]), Some(false));
        assert_eq!(parse_full_overlap(EXAMPLE[1]), Some(false));
        assert_eq!(parse_full_overlap(EXAMPLE[2]), Some(false));
        assert_eq!(parse_full_overlap(EXAMPLE[3]), Some(true));
        assert_eq!(parse_full_overlap(EXAMPLE[4]), Some(true));
        assert_eq!(parse_full_overlap(EXAMPLE[5]), Some(false));
    }

    #[test]
    fn parse() {
        assert_eq!(
            parse_ranges(EXAMPLE[0]),
            Some((Range { begin: 2, end: 4 }, Range { begin: 6, end: 8 }))
        )
    }

    #[test]
    fn part2_example() {
        assert_eq!(cleanup_part2(EXAMPLE), 4);
    }

    #[test]
    fn partial_overlap_examples() {
        assert_eq!(parse_partial_overlap(EXAMPLE[0]), Some(false));
        assert_eq!(parse_partial_overlap(EXAMPLE[1]), Some(false));
        assert_eq!(parse_partial_overlap(EXAMPLE[2]), Some(true));
        assert_eq!(parse_partial_overlap(EXAMPLE[3]), Some(true));
        assert_eq!(parse_partial_overlap(EXAMPLE[4]), Some(true));
        assert_eq!(parse_partial_overlap(EXAMPLE[5]), Some(true));
    }

    #[test]
    fn full_overlap_implies_partial() {
        assert!(parse_partial_overlap("7-96,6-99").unwrap());
        assert!(parse_partial_overlap("6-96,7-95").unwrap());
    }
}
