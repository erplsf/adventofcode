use adventofcode::lib::parse_file;

fn parse_ids(ids: &str) -> Vec<usize> {
    ids.split(",").filter_map(|id| {
        if id != "x" {
            id.parse().ok()
        } else {
            None
        }
    }).collect()
}

fn find_next_departure_since(since: usize, schedules: &Vec<usize>) -> Vec<usize> {
    schedules.iter().map(|bus| {
        let fits = since / *bus;
        (fits + 1) * *bus
    }).collect()
}

fn main() {
    let contents = parse_file().unwrap();
    let mut iter = contents.lines();
    let start_time: usize = iter.next().unwrap().parse().unwrap();
    let schedules = parse_ids(iter.next().unwrap());
    // dbg!(&start_time, &schedules);
    let nearest_next_schedules = find_next_departure_since(start_time, &schedules);
    let diff: Vec<usize> = nearest_next_schedules.iter().map(|bus| bus - start_time).collect();
    let min_index = diff.iter().enumerate().min_by_key(|&(_, item)| item).unwrap();
    let final_result = schedules[min_index.0] * min_index.1;
    dbg!(&final_result);
    // part 2 - system of linear equations
}
