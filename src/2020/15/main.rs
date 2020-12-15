use adventofcode::lib::parse_file;
use std::collections::HashMap;

// key is the number, value is the turns at which it was spoken
fn parse_input(string: &str) -> (HashMap<usize, (usize, usize)>, (usize, usize)) {
    let iter = string.split(',').filter_map(|n| n.parse().ok());

    let turn = iter.clone().count();
    let last = iter.clone().last().unwrap();

    (
        iter.clone()
            .enumerate()
            .map(|(i, v)| (v, (i + 1, i + 1)))
            .collect(),
        (turn, last),
    )
}

fn fill_next(
    map: &mut HashMap<usize, (usize, usize)>,
    (turn, last): (usize, usize),
) -> usize {
    let mut next_number: usize = 0;
    if let Some(find) = map.get_mut(&last) {
        // number was spoken before
        next_number = turn - find.1;
        find.0 = find.1;
        find.1 = turn;
    } else {
        // first time number was spoken
        map.insert(last, (turn, turn));
    };
    next_number
}

fn main() {
    let (mut map, (mut turn, mut last)) = parse_input("0,12,6,13,20,1,17");
    while turn < 2020 {
        let new_last = fill_next(&mut map, (turn, last));
        turn += 1;
        last = new_last;
    }
    dbg!(last);
    while turn < 30000000 {
        let new_last = fill_next(&mut map, (turn, last));
        turn += 1;
        last = new_last;
    };
    dbg!(last);
}
