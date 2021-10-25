use adventofcode::lib::parse_file;
use std::collections::HashMap;
use std::ops::RangeInclusive;

fn parse_ranges(string: &str) -> Vec<Vec<RangeInclusive<usize>>> {
    string
        .lines()
        .map(|line| {
            let block = line.split(':').last().unwrap();
            let ranges: Vec<_> = block
                .split("or")
                .map(|range| {
                    let range_vec: Vec<usize> = range
                        .trim()
                        .split('-')
                        .filter_map(|num| num.parse().ok())
                        .collect();
                    let range = RangeInclusive::new(
                        range_vec.first().unwrap().clone(),
                        range_vec.last().unwrap().clone(),
                    );
                    range
                })
                .collect();
            ranges
        })
        .collect()
}

fn parse_ticket_block(string: &str) -> Vec<Vec<usize>> {
    let mut iter = string.lines();
    iter.next();
    iter.map(|line| parse_values_line(line)).collect()
}

fn parse_values_line(string: &str) -> Vec<usize> {
    string
        .split(',')
        .filter_map(|num| num.parse().ok())
        .collect()
}

fn invalid_values(
    values: Vec<usize>,
    ranges: &Vec<Vec<RangeInclusive<usize>>>,
) -> Option<Vec<usize>> {
    let mut invalid_values = vec![];
    for value in values {
        let value_is_valid = ranges
            .iter()
            .any(|range_block| range_block.iter().any(|range| range.contains(&value)));
        if !value_is_valid {
            invalid_values.push(value);
        }
    }
    if invalid_values.len() > 0 {
        Some(invalid_values)
    } else {
        None
    }
}

fn matrix_transpose(m: &Vec<Vec<usize>>) -> Vec<Vec<usize>> {
    let mut t = vec![Vec::with_capacity(m.len()); m[0].len()];
    for r in m {
        for i in 0..r.len() {
            t[i].push(r[i]);
        }
    }
    t
}

fn map_values_to_ranges(
    values_vectors: Vec<Vec<usize>>,
    ranges: Vec<Vec<RangeInclusive<usize>>>,
) -> HashMap<usize, usize> {
    let mut map: HashMap<usize, usize> = HashMap::new();
    let mut cloned_ranges = ranges.clone();
    while cloned_ranges.len() > 0 {
        for (v_pos, values) in values_vectors.iter().enumerate() {
            let mut value_range_candidates = vec![];
            for (r_pos, range_block) in cloned_ranges.iter().enumerate() {
                let value_fits_range = values
                    .iter()
                    .all(|v| range_block.iter().any(|range| range.contains(v)));
                if value_fits_range {
                    value_range_candidates.push(r_pos);
                }
            }
            if value_range_candidates.len() == 1 {
                let small_range_pos = *value_range_candidates.first().unwrap();
                let small_range_val = &cloned_ranges[small_range_pos];
                let range_pos = ranges.iter().position(|r| r == small_range_val).unwrap();
                map.insert(range_pos, v_pos);
                cloned_ranges.remove(small_range_pos);
            }
        }
    }
    map
}

fn collect_departure_fields_ids(string: &str) -> Vec<usize> {
    string
        .lines()
        .enumerate()
        .filter_map(|(i, line)| {
            let field_name = line.split(':').next().unwrap();
            if field_name.contains("departure") {
                Some(i)
            } else {
                None
            }
        })
        .collect()
}

fn main() {
    let contents = parse_file().unwrap();
    let blocks: Vec<&str> = contents.split("\n\n").collect();
    let mut iter = blocks.iter();
    let fields_block = iter.next().unwrap();
    let ranges = parse_ranges(&fields_block);
    let departure_field_ids = collect_departure_fields_ids(&fields_block);
    let my_tickets = parse_ticket_block(iter.next().unwrap());
    let my_ticket = my_tickets.first().unwrap();
    let nearby_tickets = parse_ticket_block(iter.next().unwrap());
    let invalid_ticket_values: Vec<_> = nearby_tickets
        .iter()
        .filter_map(|ticket| invalid_values(ticket.to_vec(), &ranges))
        .flatten()
        .collect();
    let scanning_error_rate: usize = invalid_ticket_values.iter().sum();
    dbg!(scanning_error_rate);
    let valid_nearby_tickets: Vec<Vec<usize>> = nearby_tickets
        .iter()
        .cloned()
        .filter(|ticket| invalid_values(ticket.to_vec(), &ranges).is_none())
        .collect();
    // dbg!(&valid_nearby_tickets);
    // valid_nearby_tickets.append(&mut my_ticket);
    let values_vectors = matrix_transpose(&valid_nearby_tickets);
    // dbg!(&values_vectors);
    let map = map_values_to_ranges(values_vectors, ranges);
    let product: usize = departure_field_ids
        .iter()
        .map(|id| my_ticket[map[id]])
        .product();
    dbg!(product);
}
