use adventofcode::lib::parse_file;

fn step(value: usize, subject: usize) -> usize {
    (value * subject) % 20201227
}

fn brute(target: usize) -> usize {
    let mut loop_count = 0;
    let mut value = 1;
    loop {
        value = step(value, 7);
        loop_count += 1;
        if value == target {
            break;
        }
    }
    loop_count
}

fn cycle(subject: usize, steps: usize) -> usize {
    let mut value = 1;
    for _i in 0..steps {
        value = step(value, subject);
    }
    value
}

fn main() {
    debug_assert_eq!(brute(5764801), 8);
    debug_assert_eq!(brute(17807724), 11);
    debug_assert_eq!(cycle(17807724, 8), 14897079);

    let contents = parse_file().unwrap();
    let mut iter = contents.lines();
    let first_num: usize = iter.next().unwrap().parse().unwrap();
    let loop_size = brute(first_num);
    let second_num: usize = iter.next().unwrap().parse().unwrap();
    let encryption_key = cycle(second_num, loop_size);
    dbg!(encryption_key);        
}
