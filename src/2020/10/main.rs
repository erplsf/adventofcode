use std::collections::HashMap;
use adventofcode::lib::parse_file;

fn find_lefts(chargers: Vec<usize>) -> Vec<usize> {
    let mut lefts: Vec<usize> = vec![];
    for triple in chargers.windows(3).rev() {
        let f = triple.first().unwrap();
        let s = triple[1];
        let t = triple.last().unwrap();

        // dbg!(t, s, f);

        let d = t - f;
        // idea: if d < 3 then take the next number and check if we can throw it out too
        if d < 3 {
            dbg!(t, s, f);
            lefts.push(s);
        }
    }
    lefts
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
    let lefts = find_lefts(chargers);
    dbg!(&diffs);
    dbg!(&lefts);
    // dbg!(&chargers);
    dbg!(&result);
}
