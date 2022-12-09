use std::io;

pub fn rock_paper_scissors<B: io::BufRead>(input: B) -> Result<i32, io::Error> {
    input
        .lines()
        .map(|line| -> Result<i32, io::Error> { Ok(one_round(&line?)) })
        .sum()
}

fn one_round(line: &str) -> i32 {
    let parts: Vec<_> = line.split_whitespace().collect();
    let shape_score = match parts[..] {
        [_, "X"] => 1, // rock
        [_, "Y"] => 2, // paper
        [_, "Z"] => 3, // scissors
        _ => 0,
    };
    let outcome_score = match parts[..] {
        ["A", "X"] => 3, // rock = rock
        ["A", "Y"] => 6, // rock < paper
        ["A", "Z"] => 0, // rock > scissors
        ["B", "X"] => 0, // paper > rock
        ["B", "Y"] => 3, // paper = paper
        ["B", "Z"] => 6, // paper < scissors
        ["C", "X"] => 6, // scissors < rock
        ["C", "Y"] => 0, // scissors > paper
        ["C", "Z"] => 3, // scissors = scissors
        _ => 0,
    };
    shape_score + outcome_score
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
    fn test_rock_paper_scissors() {
        assert_eq!(rock_paper_scissors(EXAMPLE.as_bytes()).unwrap(), 15);
    }

    #[test]
    fn test_round1_a_y() {
        assert_eq!(one_round("A Y"), 8);
    }

    #[test]
    fn test_round2_b_x() {
        assert_eq!(one_round("B X"), 1);
    }

    #[test]
    fn test_round3_c_z() {
        assert_eq!(one_round("C Z"), 6);
    }
}
