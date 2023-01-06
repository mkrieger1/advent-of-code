use std::io::BufRead;

use crate::input::trimmed_not_blank;

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
pub struct Range {
    begin: u32,
    end: u32,
}

pub trait OverlapRule {
    fn overlap(first: &Range, second: &Range) -> bool;
}

pub struct FullOverlap;

impl OverlapRule for FullOverlap {
    fn overlap(first: &Range, second: &Range) -> bool {
        assert!(first.begin <= first.end);
        assert!(second.begin <= second.end);
        let a = first.begin >= second.begin;
        let d = first.end > second.end;
        !a && d || a && !d
    }
}

pub struct PartialOverlap;

impl OverlapRule for PartialOverlap {
    fn overlap(first: &Range, second: &Range) -> bool {
        assert!(first.begin <= first.end);
        assert!(second.begin <= second.end);
        let b = first.begin > second.end;
        let c = first.end >= second.begin;
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

fn parse_and_overlap<R: OverlapRule>(input: &str) -> Option<bool> {
    let (first, second) = parse_ranges(input)?;
    Some(R::overlap(&first, &second))
}

pub fn count_overlaps<I, R>(input: I) -> i32
where
    I: BufRead,
    R: OverlapRule,
{
    input
        .lines()
        .filter_map(|line| trimmed_not_blank(&line.ok()?))
        .map(|line| parse_and_overlap::<R>(&line).unwrap_or(false) as i32)
        .sum()
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE: &str = "
        2-4,6-8
        2-3,4-5
        5-7,7-9
        2-8,3-7
        6-6,4-6
        2-6,4-8
    ";

    #[test]
    fn part1_example() {
        assert_eq!(count_overlaps::<_, FullOverlap>(EXAMPLE.as_bytes()), 2);
    }

    #[test]
    fn full_overlap_examples() {
        let p = parse_and_overlap::<FullOverlap>;
        let lines: Vec<String> =
            EXAMPLE.lines().filter_map(trimmed_not_blank).collect();
        assert_eq!(p(&lines[0]), Some(false));
        assert_eq!(p(&lines[1]), Some(false));
        assert_eq!(p(&lines[2]), Some(false));
        assert_eq!(p(&lines[3]), Some(true));
        assert_eq!(p(&lines[4]), Some(true));
        assert_eq!(p(&lines[5]), Some(false));
    }

    #[test]
    fn parse() {
        let first_line = EXAMPLE
            .lines()
            .filter_map(trimmed_not_blank)
            .next()
            .unwrap();
        assert_eq!(
            parse_ranges(&first_line),
            Some((Range { begin: 2, end: 4 }, Range { begin: 6, end: 8 }))
        )
    }

    #[test]
    fn part2_example() {
        assert_eq!(count_overlaps::<_, PartialOverlap>(EXAMPLE.as_bytes()), 4);
    }

    #[test]
    fn partial_overlap_examples() {
        let p = parse_and_overlap::<PartialOverlap>;
        let lines: Vec<String> =
            EXAMPLE.lines().filter_map(trimmed_not_blank).collect();
        assert_eq!(p(&lines[0]), Some(false));
        assert_eq!(p(&lines[1]), Some(false));
        assert_eq!(p(&lines[2]), Some(true));
        assert_eq!(p(&lines[3]), Some(true));
        assert_eq!(p(&lines[4]), Some(true));
        assert_eq!(p(&lines[5]), Some(true));
    }

    #[test]
    fn full_overlap_implies_partial() {
        let p = parse_and_overlap::<PartialOverlap>;
        assert!(p("7-96,6-99").unwrap());
        assert!(p("6-96,7-95").unwrap());
    }
}
