use std::collections::HashMap;
use adventofcode::lib::parse_file;
use std::collections::VecDeque;
use linked_hash_set::LinkedHashSet;

fn parse_input(string: &str) -> VecDeque<(usize, usize)> {
    string.split(',').filter_map(|n| n.parse().ok()).enumerate().collect()
}

fn count_upto(vec: &mut VecDeque<(usize, usize)>, count: usize) {
    let mut starting_count = vec.len();
    while starting_count < count {
        fill_next(vec);
        starting_count += 1;
    }
}

fn fill_next(vec: &mut VecDeque<(usize, usize)>) {
    let last = vec.pop_back().unwrap(); // temporarily take it from the queue
    // dbg!(&last);
    let find = vec.iter().rev().position(|&x| x.1 == last.1);
    vec.push_back(last);
    match find {
        Some(pos) => {
            // dbg!(pos);
            // dbg!(pos + 1);
            vec.push_back((vec.len(), pos + 1));
        }
        None => {
            // dbg!("not found, inserting 0");
            vec.push_back((vec.len(), 0));
        }
    }
    // prune(vec);
    // dbg!(&vec);
}

fn prune(vec: &mut VecDeque<(usize, usize)>) {
    let mut map: HashMap<usize, usize> = HashMap::new();
    let c = vec.clone();
    let mut iter = c.iter().rev().enumerate();
    while let Some((i, (prev_i, val))) = iter.next() {
        // dbg!(val, i, vec.len());
        let mv = map.get_mut(&val);
        if mv.is_some() {
            *(mv.unwrap()) += 1;
        } else {
            map.insert(*val, 1);
        }
        if map.get(&val).unwrap() > &2 {
            let index = vec.len() - i - 1;
            // dbg!(val, i, vec.len());
            vec.remove(index);
        }
    }
}

fn main() {
    let mut t = parse_input("0,3,6");
    // dbg!(&t);
    count_upto(&mut t, 2020);
    // dbg!(&t);
    let r = t.pop_back().unwrap();
    dbg!(r);
    // fill_next(&mut t);
    // dbg!(&t);
    // fill_next(&mut t);
    // dbg!(&t);
    // fill_next(&mut t);    
    // dbg!(&t);
    // debug_assert!(t.pop_back().unwrap() == 436);

    // let mut t = parse_input("1,3,2");
    // count_upto(&mut t, 2020);
    // debug_assert!(t.pop_back().unwrap() == 1);

    // let mut t = parse_input("3,1,2");
    // count_upto(&mut t, 2020);
    // debug_assert!(t.pop_back().unwrap() == 1836);

    // let mut input = parse_input("0,12,6,13,20,1,17");
    // count_upto(&mut input, 30000000);
    // dbg!(input.pop_back().unwrap());
}
