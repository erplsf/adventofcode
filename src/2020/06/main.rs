use adventofcode::lib::parse_file;
use std::collections::HashSet;

fn answer_count(group: &str) -> usize {
    let mut set: HashSet<char> = HashSet::new();
    for person in group.lines() {
        for answer in person.chars() {
            set.insert(answer);
        }
    }
    set.len()
}

fn collect_answers(group: &str) -> usize {
    let intersection = HashSet::new();
    let mut iter = group.lines();
    let first_person = iter.next().unwrap();
    let intersection = first_person.chars().fold(intersection, |mut set, answer| { set.insert(answer); set });
    let intersection = iter.fold(intersection, |intersection, person|  {
        let mut set = HashSet::new();
        for answer in person.chars() {
            set.insert(answer);
        };        
        intersection.intersection(&set).cloned().collect()
    });
    intersection.len()
}

fn main() {
    let contents = parse_file().unwrap();
    let anyone_said_yes = contents
        .split("\n\n")
        .filter(|g| g.len() > 0)
        .fold(0, |acc, g| acc + answer_count(g));
    dbg!(anyone_said_yes);
    
    let everyone_said_yes =
        contents
        .split("\n\n")
        .filter(|g| g.len() > 0)
        .fold(0, |acc, g| {
            acc + collect_answers(g)
        });
    dbg!(everyone_said_yes);
}
