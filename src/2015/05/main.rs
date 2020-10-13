use adventofcode::lib::parse_file;

const NAUGHTY_STRINGS: [&str; 4] = ["ab", "cd", "pq", "xy"];
const VOWELS: [char; 5] = ['a', 'e', 'i', 'o', 'u'];

fn is_nice_v1(string: &str) -> bool {
    todo!()
}

fn is_nice_v2(string: &str) -> bool {
    let mut non_overlapping_pair = false;
    let mut sandwich_letters = false;

    for i in 0..string.len()-2 {
        let pair = string.get(i..i+2).unwrap();
        let rest = string.get(i+2..string.len()).unwrap();
        // dbg!(pair, rest);
        if rest.contains(pair) {
            non_overlapping_pair = true;
        }

        let cur = string.get(i..i+1).unwrap();
        let after_next = string.get(i+2..i+3).unwrap();
        // dbg!(cur, after_next);
        if cur == after_next {
            sandwich_letters = true;
        }
    }
    non_overlapping_pair && sandwich_letters
}

fn count_all_nice(string: &str, v2: bool) -> usize {
    let mut count = 0;
    for line in string.lines() {
        if v2 {
            if is_nice_v2(line) {
                count += 1;
            }
        } else {
            if is_nice_v1(line) {
                count += 1;
            }
        }
    }
    count
}

fn main() -> Result<(), Box<dyn std::error::Error + 'static>> {
    // test cases
/*    assert_eq!(is_nice_v1("ugknbfddgicrmopn"), true);
    assert_eq!(is_nice_v1("aaa"), true);
    assert_eq!(is_nice_v1("jchzalrnumimnmhp"), false);
    assert_eq!(is_nice_v1("haegwjzuvuyypxyu"), false);
    assert_eq!(is_nice_v1("dvszwmarrgswjxmb"), false); */
    // test cases v2
    assert_eq!(is_nice_v2("aaa"), false);
    assert_eq!(is_nice_v2("qjhvhtzxzqqjkmpb"), true);
    assert_eq!(is_nice_v2("xxyxx"), true);
    assert_eq!(is_nice_v2("uurcxstgmygtbstg"), false);
    assert_eq!(is_nice_v2("ieodomkazucvgmuy"), false);
    
    let contents = parse_file().unwrap();
    dbg!(count_all_nice(&contents, true));
    Ok(())
}
