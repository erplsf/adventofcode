use adventofcode::lib::parse_file;
use itertools::Itertools;
use std::collections::HashSet;
use std::collections::VecDeque;
use std::convert::TryInto;
use std::iter::FromIterator;

fn find_error(numbers: Vec<usize>, preamble_size: usize) -> (usize, usize) {
    let (preamble_slice, rest_slice) = numbers.split_at(preamble_size);
    let mut preamble = VecDeque::from(preamble_slice.to_owned());
    let mut rest = VecDeque::from(rest_slice.to_owned());
    let mut invalid_number = 0;
    while rest.len() != 0 {
        // dbg!(preamble.len());
        // dbg!(rest.len());
        let sums: HashSet<usize> = preamble
            .iter()
            .combinations(2)
            .map(|comb| comb.into_iter().sum())
            .collect();
        let number = rest.pop_front().unwrap();

        if !sums.contains(&number) {
            invalid_number = number;
            break;
        }
        preamble.pop_front();
        preamble.push_back(number);
    }

    let mut final_value = 0;

    if invalid_number != 0 {
        // we have found the answer
        // dbg!("found invalid, looking for sum");
        let invalid_index = numbers.iter().position(|&x| x == invalid_number).unwrap();
        // dbg!(&invalid_number);
        // dbg!(&invalid_index);
        let mut considered_numbers: Vec<usize> = numbers.into_iter().take(invalid_index).collect(); // take up to index elements from original vector
        // dbg!(&considered_numbers);
        let mut sum_set = VecDeque::new();
        while considered_numbers.len() != 0 {
            // dbg!(considered_numbers.len());
            sum_set.push_front(considered_numbers.pop().unwrap());
            // dbg!(&sum_set);
            let sum = sum_set.iter().sum::<usize>();
            // dbg!(&sum);
            if sum == invalid_number {
                break;
            } else if sum > invalid_number {
            sum_set.pop_back();
        }
    }
    let sum_set = sum_set.make_contiguous();
    sum_set.sort();
    final_value = sum_set.first().unwrap() + sum_set.last().unwrap();
}
(invalid_number, final_value)
}

fn main() {
    let contents = parse_file().unwrap();
    let numbers: Vec<usize> = contents
        .lines()
        .map(str::trim)
        .filter_map(|num| Some(num.parse::<usize>().unwrap()))
        .collect();
    dbg!(find_error(numbers, 25));
}
