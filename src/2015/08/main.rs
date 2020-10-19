use adventofcode::lib::parse_file;

fn parse_line(line: &str) -> (usize, usize, usize) {
    let mut code_count = 0;
    let mut char_count = 0;
    let mut new_rep_count = 0;
    let mut chars = line.trim().chars().into_iter();
    loop {
        match chars.next() {
            None => break,
            Some('\\') => {
                match chars.next() {
                    None => break,
                    Some('x') => {
                        chars.next(); chars.next();
                        code_count = code_count + 2;
                        new_rep_count = new_rep_count + 1;
                    },
                    Some('"') => (),
                    Some('\\') => (),
                    Some(c) => {
                        dbg!(c);
                        panic!("We should not reach here");
                    }
                }
                code_count = code_count + 2;
                char_count = char_count + 1;
                new_rep_count = new_rep_count + 4;
            },
            Some('"') => {
                code_count = code_count + 1;
                new_rep_count = new_rep_count + 2;
            }
            Some(_) => {
                code_count = code_count + 1;
                char_count = char_count + 1;
                new_rep_count = new_rep_count + 1;
            },
        }
    }
    // println!("line: {} -> {:?}", &line, (code_count, char_count));
    (code_count, char_count, new_rep_count + 2)
}

fn main() -> Result<(), Box<dyn std::error::Error + 'static>> {
    // test cases    
    debug_assert_eq!(parse_line("\"\""), (2, 0, 6));
    debug_assert_eq!(parse_line("\"abc\""), (5, 3, 9));
    debug_assert_eq!(parse_line("\"aaa\\\"aaa\""), (10, 7, 16));
    debug_assert_eq!(parse_line("\"\\x27\""), (6, 1, 11));

    let contents = parse_file().unwrap();
    let total_count = contents.lines().fold(0,|acc, line| {
        let (code_count, char_count, _raw_encoded_count) = parse_line(line);
        acc + (code_count - char_count)
    });

    let second_total_count = contents.lines().fold(0, |acc, line| {
        let (code_count, _char_count, raw_encoded_count) = parse_line(line);
        acc + (raw_encoded_count - code_count)
    });
    
    dbg!(total_count);
    dbg!(second_total_count);
    Ok(())
}
