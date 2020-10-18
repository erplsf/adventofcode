use adventofcode::lib::parse_file;

fn parse_line(line: &mut str) -> (usize, usize) {
    let code_count = 0;
    let char_count = 0;
    let chars = line.chars().into_iter();
    loop {
        match chars.next() {
            Some(char) => {
                
            }
            None => break
        }
    }
    (code_count, char_count)
}

fn main() -> Result<(), Box<dyn std::error::Error + 'static>> {
    let contents = parse_file().unwrap();
    Ok(())
}
