use adventofcode::lib::parse_file;
use std::collections::HashMap;
use std::collections::HashSet;
use std::iter::FromIterator;

type Map = HashMap<String, HashSet<String>>;
type SolvedMap = HashMap<String, String>;

fn collect_all_ingridients(contents: &str) -> Vec<String> {
    let mut all: Vec<String> = vec![];
    for line in contents.lines() {
        let rep = line.replace('(', "").replace(')', "").replace(',', "");
        let mut split = rep.split("contains");
        let ingridients: Vec<String> = split
            .next()
            .unwrap()
            .split_ascii_whitespace()
            .map(|el| el.to_owned())
            .collect();

        all.extend(ingridients);
    }
    all
}

fn parse_to_set(contents: &str) -> Map {
    let mut map: Map = HashMap::new();
    for line in contents.lines() {
        let rep = line.replace('(', "").replace(')', "").replace(',', "");
        let mut split = rep.split("contains");
        let ingridients: Vec<String> = split
            .next()
            .unwrap()
            .split_ascii_whitespace()
            .map(|el| el.to_owned())
            .collect();
        let contains: Vec<String> = split
            .next()
            .unwrap()
            .split_ascii_whitespace()
            .map(|el| el.to_owned())
            .collect();
        for contained in contains {
            let set = HashSet::from_iter(ingridients.iter().cloned());
            let entry = map
                .entry(contained)
                .or_insert(HashSet::from_iter(ingridients.clone()));
            *entry = entry.intersection(&set).cloned().collect();
        }
    }
    map
}

fn solve_map(map: &Map) -> SolvedMap {
    let mut map = map.clone();
    let mut solved_map: SolvedMap = HashMap::new();
    while map.len() > 0 {
        if let Some(key) = map.iter().find(|(_k, v)| v.len() == 1).map(|(k, _v)| k) {
            let value = map.get(key).unwrap().iter().last().unwrap().to_string();
            solved_map.insert(key.to_string(), value.clone());
            map.remove(&key.clone());
            for v in map.values_mut() {
                v.remove(&value);
            }
        } else {
            panic!("Can't solve it!");
        }
        // dbg!(&solved_map, &map);
    }
    solved_map
}

fn count_unknowns(all_ingridients: &Vec<String>, known_set: &HashSet<String>) -> usize {
    let mut count = 0;
    for ingridient in all_ingridients {
        if !known_set.contains(ingridient) {
            count += 1;
        }
    }
    count
}

fn main() {
    let contents = parse_file().unwrap();
    let all_ingridients = collect_all_ingridients(&contents);
    let map = parse_to_set(&contents);
    let solved_map = solve_map(&map);
    let known_set = HashSet::from_iter(solved_map.values().cloned());
    let unknown_count = count_unknowns(&all_ingridients, &known_set);
    let mut dangerous_ingridients_names: Vec<String> = solved_map.keys().cloned().collect();
    dangerous_ingridients_names.sort();
    let dangerous_ingridients: Vec<String> = dangerous_ingridients_names.iter().map(|name| solved_map[name].clone()).collect();
    dbg!(unknown_count);
    println!("{}", &dangerous_ingridients.join(","));
}
