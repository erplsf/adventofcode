use adventofcode::lib::parse_file;
use std::collections::HashMap;

fn find_lefts(chargers: &Vec<usize>) -> Vec<usize> {
    let mut lefts: Vec<usize> = vec![];
    for triple in chargers.windows(3) {
        let f = triple.first().unwrap();
        let s = triple[1];
        let t = triple.last().unwrap();

        // dbg!(t, s, f);

        let d = t - f;
        // idea: if d < 3 then take the next number and check if we can throw it out too
        if d < 3 {
            // dbg!(t, s, f);
            lefts.push(s);
        }
    }
    lefts
}

fn split_in_ranges(chargers: &Vec<usize>) -> Vec<Vec<usize>> {
    let mut ranges: Vec<Vec<usize>> = vec![];
    let mut current_range = vec![];
    for double in chargers.windows(2) {
        let f = double.first().unwrap();
        let s = double.last().unwrap();
        let d = s - f;
        if d == 1 {
            current_range.push(*f);
            current_range.push(*s);
        } else {
            // dbg!(*s, double);
            current_range.dedup();
            ranges.push(current_range);
            current_range = vec![];
            current_range.push(*s);
        }
    }
    current_range.dedup();
    ranges.push(current_range);
    ranges
}

fn main() {
    let contents = parse_file().unwrap();
    let mut diffs: HashMap<usize, usize> = HashMap::new();
    let mut chargers: Vec<usize> = contents.lines().filter_map(|n| n.parse().ok()).collect();
    chargers.push(0);
    chargers.sort();
    chargers.push(chargers.last().unwrap() + 3);
    for pair in chargers.windows(2) {
        let f = pair.first().unwrap();
        let s = pair.last().unwrap();
        let diff = s - f;
        let count = diffs.entry(diff).or_insert(0);
        *count += 1
    }
    let result = diffs.get(&1).unwrap() * diffs.get(&3).unwrap();
    let lefts = find_lefts(&chargers);
    let ranges = split_in_ranges(&lefts);
    // dbg!(&chargers);
    dbg!(&result);
    // dbg!(&chargers);
    // dbg!(&lefts);
    // dbg!(&ranges);
    let combs: usize = ranges
        .iter()
        .map(|range| match range.len() {
            1 => 2,
            2 => 4,
            3 => 7,
            _ => panic!("unsupported case!"),
        })
        .product();
    dbg!(&combs);
}
