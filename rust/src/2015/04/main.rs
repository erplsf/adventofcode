use adventofcode::lib::parse_file;

fn find_md5_zeros(key: &str, start: usize, search_prefix: &str) -> usize {
    let mut counter = start;
    loop {
        let input = format!("{}{}", key, counter);
        let result = format!("{:x}", md5::compute(input));
        if result.starts_with(search_prefix) {
            return counter;
        }
        counter += 1;
    }
}

fn main() -> Result<(), Box<dyn std::error::Error + 'static>> {
    // test cases
    assert_eq!(find_md5_zeros("abcdef", 609040, "00000"), 609043);
    assert_eq!(find_md5_zeros("pqrstuv", 1048960, "00000"), 1048970);
    
    let contents = parse_file().unwrap();
    dbg!(find_md5_zeros(&contents.trim(), 0, "00000"));
    dbg!(find_md5_zeros(&contents.trim(), 0, "000000"));
    Ok(())
}
