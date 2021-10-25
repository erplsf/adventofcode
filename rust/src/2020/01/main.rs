use adventofcode::lib::parse_file;
use itertools::Itertools;

fn main() {
    let contents = parse_file().unwrap();
    let numbers: Vec<usize> = contents
        .split("\n")
        .filter_map(|s| s.parse().ok())
        .collect();
    
    for combination in numbers.iter().cloned().combinations(2) {
        if combination.iter().sum::<usize>() == 2020 {
            let product: usize = std::iter::Product::product(combination.iter());
            dbg!(product);
            break;
        }
    }

    for combination in numbers.iter().cloned().combinations(3) {
        if combination.iter().sum::<usize>() == 2020 {
            let product: usize = std::iter::Product::product(combination.iter());
            dbg!(product);
            break;
        }
    }
}
