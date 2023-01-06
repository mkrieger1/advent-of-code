pub mod day1;
pub mod day2;
pub mod day3;
pub mod day4;

mod input {
    pub fn trimmed_not_blank(line: &str) -> Option<String> {
        let line = line.trim();
        if line.is_empty() {
            None
        } else {
            Some(line.to_string())
        }
    }
}
