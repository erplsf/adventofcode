use adventofcode::lib::parse_file;

fn parse_ids(ids: &str) -> Vec<usize> {
    ids.split(",").filter_map(|id| {
        if id != "x" {
            id.parse().ok()
        } else {
            Some(0)
        }
    }).collect()
}

fn find_next_departure_since(since: usize, schedules: &Vec<usize>) -> Vec<usize> {
    schedules.iter().map(|bus| {
        let fits = since / *bus;
        (fits + 1) * *bus
    }).collect()
}

// function extended_gcd(a, b)
//     (old_r, r) := (a, b)
//     (old_s, s) := (1, 0)
//     (old_t, t) := (0, 1)

//     while r ≠ 0 do
//     quotient := old_r div r
//     (old_r, r) := (r, old_r − quotient × r)
//     (old_s, s) := (s, old_s − quotient × s)
//     (old_t, t) := (t, old_t − quotient × t)

//     output "Bézout coefficients:", (old_s, old_t)
//     output "greatest common divisor:", old_r
//     output "quotients by the gcd:", (t, s)

fn extended_euclid(a: isize, b: isize) -> (isize, isize) {
    let (mut old_r, mut r) = (a, b);
    let (mut old_s, mut s) = (1, 0);
    let (mut old_t, mut t) = (0, 1);

    while r != 0 {
        let quotient = old_r / r;
        let prov = r;
        r = old_r - quotient * prov;
        old_r = prov;
        let prov = s;
        s = old_s - quotient * prov;
        old_s = prov;
        let prov = t;
        t = old_t - quotient * prov;
        old_t = prov;
    }

    (old_s, old_t)
}

fn main() {
    let contents = parse_file().unwrap();
    let mut iter = contents.lines();
    let start_time: usize = iter.next().unwrap().parse().unwrap();
    let schedules = parse_ids(iter.next().unwrap());
    let en: Vec<_> = schedules.iter().enumerate().filter(|&(i, v)| *v != 0).collect();
    dbg!(&start_time, en);
    // let nearest_next_schedules = find_next_departure_since(start_time, &schedules);
    // let diff: Vec<usize> = nearest_next_schedules.iter().map(|bus| bus - start_time).collect();
    // let min_index = diff.iter().enumerate().min_by_key(|&(_, item)| item).unwrap();
    // let final_result = schedules[min_index.0] * min_index.1;
    // dbg!(&final_result);
    // TODO: Solve part 2 with "Сhinese remainder theorem -> existence construction"
    dbg!(extended_euclid(3, 4));
}
