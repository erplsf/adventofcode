use adventofcode::lib::parse_file;

fn main() {
    let contents = parse_file().unwrap();
    let lines = contents.split("\n");
    let mut rule_one_valid_passwords = 0;
    let mut rule_two_valid_passwords = 0;
    for line in lines {
        let mut parts: Vec<&str> = line.split(" ").collect();
        if parts.len() > 1 {
            let password = parts.pop().unwrap();
            let ch = parts.pop().unwrap().chars().next().unwrap();
            let pos: Vec<usize> = parts
                .pop()
                .unwrap()
                .split("-")
                .map(|c| c.parse().unwrap())
                .collect();
            let range = pos[0]..=pos[1];
            let count = password.matches(ch).count();
            if range.contains(&count) {
                rule_one_valid_passwords += 1;
            }
            if (password.chars().nth(pos[0] - 1).unwrap() == ch)
                ^ (password.chars().nth(pos[1] - 1).unwrap() == ch)
            {
                rule_two_valid_passwords += 1;
            }
        }
    }
    dbg!(rule_one_valid_passwords);
    dbg!(rule_two_valid_passwords);
}
