use std::borrow::Borrow;

#[derive(Copy, Clone, Debug, PartialEq, Eq)]
enum Shape {
    Rock,
    Paper,
    Scissors,
}

enum Outcome {
    Win,
    Lose,
    Draw,
}

#[derive(Debug, PartialEq, Eq)]
struct Round {
    theirs: Shape,
    ours: Shape,
}

fn round_outcome(r: Round) -> Outcome {
    match (r.theirs, r.ours) {
        (Shape::Rock, Shape::Paper)
        | (Shape::Paper, Shape::Scissors)
        | (Shape::Scissors, Shape::Rock) => Outcome::Win,
        (Shape::Rock, Shape::Scissors)
        | (Shape::Paper, Shape::Rock)
        | (Shape::Scissors, Shape::Paper) => Outcome::Lose,
        _ => Outcome::Draw,
    }
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

trait ChooseOurs {
    fn choose_ours(&self, line_parts: &[&str]) -> Option<Shape>;
}

struct Part1;

impl ChooseOurs for Part1 {
    fn choose_ours(&self, line_parts: &[&str]) -> Option<Shape> {
        match line_parts[..] {
            [_, "X"] => Some(Shape::Rock),
            [_, "Y"] => Some(Shape::Paper),
            [_, "Z"] => Some(Shape::Scissors),
            _ => None,
        }
    }
}

struct Part2;

impl ChooseOurs for Part2 {
    fn choose_ours(&self, line_parts: &[&str]) -> Option<Shape> {
        let theirs = parse_theirs(line_parts)?;
        let outcome = match line_parts[..] {
            [_, "X"] => Some(Outcome::Lose),
            [_, "Y"] => Some(Outcome::Draw),
            [_, "Z"] => Some(Outcome::Win),
            _ => None,
        }?;
        Some(match (theirs, outcome) {
            (Shape::Rock, Outcome::Draw)
            | (Shape::Paper, Outcome::Lose)
            | (Shape::Scissors, Outcome::Win) => Shape::Rock,
            (Shape::Rock, Outcome::Win)
            | (Shape::Paper, Outcome::Draw)
            | (Shape::Scissors, Outcome::Lose) => Shape::Paper,
            _ => Shape::Scissors,
        })
    }
}

struct RockPaperScissors<S> {
    strategy: S,
}

impl<S> RockPaperScissors<S>
where
    S: ChooseOurs,
{
    fn one_round(&self, line: &str) -> Option<i32> {
        let parts: Vec<_> = line.split_whitespace().collect();
        let round = Round {
            theirs: parse_theirs(&parts)?,
            ours: self.strategy.choose_ours(&parts)?,
        };
        Some(shape_score(round.ours) + outcome_score(round_outcome(round)))
    }

    fn play<I>(&self, input: I) -> i32
    where
        I: IntoIterator,
        I::Item: Borrow<str>,
    {
        input
            .into_iter()
            .map(|line| self.one_round(line.borrow()).unwrap_or(0))
            .sum()
    }
}

pub fn rock_paper_scissors_part1<I>(input: I) -> i32
where
    I: IntoIterator,
    I::Item: Borrow<str>,
{
    let r = RockPaperScissors { strategy: Part1 };
    r.play(input)
}

pub fn rock_paper_scissors_part2<I>(input: I) -> i32
where
    I: IntoIterator,
    I::Item: Borrow<str>,
{
    let r = RockPaperScissors { strategy: Part2 };
    r.play(input)
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
        let r = RockPaperScissors { strategy: Part1 };
        assert_eq!(r.one_round("A Y").unwrap(), 8);
        assert_eq!(r.one_round("B X").unwrap(), 1);
        assert_eq!(r.one_round("C Z").unwrap(), 6);
    }

    #[test]
    fn test_rock_paper_scissors_part2() {
        assert_eq!(rock_paper_scissors_part2(EXAMPLE.lines()), 12);
    }

    #[test]
    fn test_one_round_part2() {
        let r = RockPaperScissors { strategy: Part2 };
        assert_eq!(r.one_round("A Y").unwrap(), 4);
        assert_eq!(r.one_round("B X").unwrap(), 1);
        assert_eq!(r.one_round("C Z").unwrap(), 7);
    }

    #[test]
    fn test_parse_round_part2_choose_scissors() {
        // they choose rock and we need to lose -> choose scissors
        let strategy = Part2;
        assert_eq!(strategy.choose_ours(&["A", "X"]), Some(Shape::Scissors));
    }
}
