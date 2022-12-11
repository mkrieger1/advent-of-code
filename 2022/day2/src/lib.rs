use std::io;

#[derive(Copy, Clone, Debug, PartialEq)]
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

#[derive(Debug, PartialEq)]
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

fn parse_ours_part1(line_parts: &[&str]) -> Option<Shape> {
    match line_parts[..] {
        [_, "X"] => Some(Shape::Rock),
        [_, "Y"] => Some(Shape::Paper),
        [_, "Z"] => Some(Shape::Scissors),
        _ => None,
    }
}

fn parse_round_part1(line_parts: &[&str]) -> Option<Round> {
    Some(Round {
        theirs: parse_theirs(line_parts)?,
        ours: parse_ours_part1(line_parts)?,
    })
}

fn parse_ours_part2(line_parts: &[&str]) -> Option<Outcome> {
    match line_parts[..] {
        [_, "X"] => Some(Outcome::Lose),
        [_, "Y"] => Some(Outcome::Draw),
        [_, "Z"] => Some(Outcome::Win),
        _ => None,
    }
}

fn parse_round_part2(line_parts: &[&str]) -> Option<Round> {
    let theirs = parse_theirs(line_parts)?;
    let outcome = parse_ours_part2(line_parts)?;
    let ours = match (theirs, outcome) {
        (Shape::Rock, Outcome::Draw)
        | (Shape::Paper, Outcome::Lose)
        | (Shape::Scissors, Outcome::Win) => Shape::Rock,
        (Shape::Rock, Outcome::Win)
        | (Shape::Paper, Outcome::Draw)
        | (Shape::Scissors, Outcome::Lose) => Shape::Paper,
        _ => Shape::Scissors,
    };
    Some(Round { theirs, ours })
}

fn one_round<F>(line: &str, parse_round: F) -> i32
where
    F: Fn(&[&str]) -> Option<Round>,
{
    let parts: Vec<_> = line.split_whitespace().collect();
    if let Some(round) = parse_round(&parts) {
        shape_score(round.ours) + outcome_score(round_outcome(round))
    } else {
        0
    }
}

fn rock_paper_scissors<B, F>(input: B, parse_round: F) -> Result<i32, io::Error>
where
    B: io::BufRead,
    F: Fn(&[&str]) -> Option<Round>,
{
    input
        .lines()
        .map(|line| -> Result<i32, io::Error> { Ok(one_round(&line?, &parse_round)) })
        .sum()
}

pub fn rock_paper_scissors_part1<B: io::BufRead>(input: B) -> Result<i32, io::Error> {
    rock_paper_scissors(input, parse_round_part1)
}

pub fn rock_paper_scissors_part2<B: io::BufRead>(input: B) -> Result<i32, io::Error> {
    rock_paper_scissors(input, parse_round_part2)
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
        assert_eq!(rock_paper_scissors_part1(EXAMPLE.as_bytes()).unwrap(), 15);
    }

    #[test]
    fn test_one_round_part1() {
        assert_eq!(one_round("A Y", parse_round_part1), 8);
        assert_eq!(one_round("B X", parse_round_part1), 1);
        assert_eq!(one_round("C Z", parse_round_part1), 6);
    }

    #[test]
    fn test_rock_paper_scissors_part2() {
        assert_eq!(rock_paper_scissors_part2(EXAMPLE.as_bytes()).unwrap(), 12);
    }

    #[test]
    fn test_one_round_part2() {
        assert_eq!(one_round("A Y", parse_round_part2), 4);
        assert_eq!(one_round("B X", parse_round_part2), 1);
        assert_eq!(one_round("C Z", parse_round_part2), 7);
    }

    #[test]
    fn test_parse_round_part2_choose_scissors() {
        // they choose rock and we need to lose -> choose scissors
        assert_eq!(
            parse_round_part2(&["A", "X"]),
            Some(Round {
                theirs: Shape::Rock,
                ours: Shape::Scissors
            })
        );
    }
}
