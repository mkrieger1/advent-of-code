use std::borrow::Borrow;

#[derive(Copy, Clone, Debug, PartialEq, Eq)]
enum Shape {
    Rock,
    Paper,
    Scissors,
}

#[derive(Debug, PartialEq, Eq)]
enum Outcome {
    Win,
    Lose,
    Draw,
}

#[derive(Debug, PartialEq, Eq)]
struct Round {
    ours: Shape,
    outcome: Outcome,
}

fn what_beats(s: Shape) -> Shape {
    use Shape::*;
    match s {
        Rock => Paper,
        Paper => Scissors,
        Scissors => Rock,
    }
}

fn what_loses(s: Shape) -> Shape {
    let other = what_beats(s);
    let result = what_beats(other);
    assert_eq!(what_beats(result), s);
    result
}

fn outcome_score(outcome: Outcome) -> i32 {
    match outcome {
        Outcome::Win => 6,
        Outcome::Lose => 0,
        Outcome::Draw => 3,
    }
}

fn shape_score(ours: Shape) -> i32 {
    match ours {
        Shape::Rock => 1,
        Shape::Paper => 2,
        Shape::Scissors => 3,
    }
}

fn parse_theirs(line_parts: &[&str]) -> Option<Shape> {
    match line_parts[..] {
        ["A", _] => Some(Shape::Rock),
        ["B", _] => Some(Shape::Paper),
        ["C", _] => Some(Shape::Scissors),
        _ => None,
    }
}

trait Strategy {
    fn choose_ours(theirs: Shape, line_parts: &[&str]) -> Option<Round>;
}

struct Part1;

impl Strategy for Part1 {
    fn choose_ours(theirs: Shape, line_parts: &[&str]) -> Option<Round> {
        let ours = match line_parts[..] {
            [_, "X"] => Some(Shape::Rock),
            [_, "Y"] => Some(Shape::Paper),
            [_, "Z"] => Some(Shape::Scissors),
            _ => None,
        }?;
        let outcome = {
            if ours == what_beats(theirs) {
                Outcome::Win
            } else if ours == what_loses(theirs) {
                Outcome::Lose
            } else {
                assert_eq!(ours, theirs);
                Outcome::Draw
            }
        };
        Some(Round { ours, outcome })
    }
}

struct Part2;

impl Strategy for Part2 {
    fn choose_ours(theirs: Shape, line_parts: &[&str]) -> Option<Round> {
        use Outcome::*;
        let outcome = match line_parts[..] {
            [_, "X"] => Some(Lose),
            [_, "Y"] => Some(Draw),
            [_, "Z"] => Some(Win),
            _ => None,
        }?;
        let ours = match outcome {
            Win => what_beats(theirs),
            Lose => what_loses(theirs),
            Draw => theirs,
        };
        Some(Round { ours, outcome })
    }
}

fn one_round<S>(line: &str) -> Option<i32>
where
    S: Strategy,
{
    let parts: Vec<_> = line.split_whitespace().collect();
    let theirs = parse_theirs(&parts)?;
    let round = S::choose_ours(theirs, &parts)?;
    Some(shape_score(round.ours) + outcome_score(round.outcome))
}

fn play<I, S>(input: I) -> i32
where
    I: IntoIterator,
    I::Item: Borrow<str>,
    S: Strategy,
{
    input
        .into_iter()
        .map(|line| one_round::<S>(line.borrow()).unwrap_or(0))
        .sum()
}

pub fn rock_paper_scissors_part1<I>(input: I) -> i32
where
    I: IntoIterator,
    I::Item: Borrow<str>,
{
    play::<I, Part1>(input)
}

pub fn rock_paper_scissors_part2<I>(input: I) -> i32
where
    I: IntoIterator,
    I::Item: Borrow<str>,
{
    play::<I, Part2>(input)
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE: &str = "
    A Y
    B X
    C Z
    ";

    #[test]
    fn test_rock_paper_scissors_part1() {
        assert_eq!(rock_paper_scissors_part1(EXAMPLE.lines()), 15);
    }

    #[test]
    fn test_one_round_part1() {
        assert_eq!(one_round::<Part1>("A Y").unwrap(), 8);
        assert_eq!(one_round::<Part1>("B X").unwrap(), 1);
        assert_eq!(one_round::<Part1>("C Z").unwrap(), 6);
    }

    #[test]
    fn test_rock_paper_scissors_part2() {
        assert_eq!(rock_paper_scissors_part2(EXAMPLE.lines()), 12);
    }

    #[test]
    fn test_one_round_part2() {
        assert_eq!(one_round::<Part2>("A Y").unwrap(), 4);
        assert_eq!(one_round::<Part2>("B X").unwrap(), 1);
        assert_eq!(one_round::<Part2>("C Z").unwrap(), 7);
    }

    #[test]
    fn test_parse_round_part2_choose_scissors() {
        // they choose rock and we need to lose -> choose scissors
        let input = &["A", "X"];
        let theirs = parse_theirs(input).unwrap();
        assert_eq!(
            Part2::choose_ours(theirs, input).unwrap().ours,
            Shape::Scissors
        );
    }
}
