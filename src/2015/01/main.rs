use adventofcode::lib::parse_file;

fn parse_level(string: &String) -> (i32, usize) {
    let mut level = 0;
    let mut basement_position = 0;
    
    for (i, c) in string.chars().enumerate() {
        if let '(' = c {
            level += 1;
        } else if let ')' = c {
            level -= 1;
        }
        if level == -1 && basement_position == 0 {
            basement_position = i + 1;
        }
    }
    (level, basement_position)
}

fn main() -> Result<(), Box<dyn std::error::Error + 'static>> {
    let contents = parse_file().unwrap();
    let (final_level, basement_position) = parse_level(&contents);
    dbg!(final_level, basement_position);
    Ok(())
}
