use adventofcode::lib::parse_file;
use linked_hash_set::LinkedHashSet;
use regex::Regex;
use std::collections::HashMap;
use std::collections::HashSet;

fn build_map(string: &str) -> HashMap<String, String> {
    let mut map = HashMap::new();
    for line in string.lines() {
        let mut split = line.split(':').map(|part| part.trim());
        let key = split.next().unwrap();
        let val = split.next().unwrap().replace('"', "");
        map.insert(key.to_string(), val);
    }
    map
}

fn build_regex_string(map: &mut HashMap<String, String>, key: &str) -> String {
    if map.contains_key(key) {
        let mut res = resolve(map, key);
        res.push('$');
        "^".to_string() + &res
    } else {
        "".to_string()
    }
}

fn resolve(map: &mut HashMap<String, String>, key: &str) -> String {
    let val = map.get(key).cloned().unwrap();
    let parts: Vec<_> = val.split_ascii_whitespace().collect();
    if parts.len() == 1 && !parts.first().unwrap().chars().all(char::is_numeric) {
        // return "(".to_owned() + &parts.first().unwrap().to_string() + ")";
        return parts.first().unwrap().to_string();
    }
    let mut regex = String::from("(");
    let mut groups_so_far: LinkedHashSet<String> = LinkedHashSet::new();
    let mut loops = false;
    for part in parts {
        if part == key {
            loops = true;
            if groups_so_far.len() == 1 {
                let g = "(".to_owned() + &groups_so_far.clone().into_iter().next().unwrap() + ")+";
                regex = g;
            } else {
                dbg!(&groups_so_far);
                let g = (1..=10).into_iter().map(|rec| {
                    groups_so_far
                        .clone()
                        .into_iter()
                        .map(|group| "(".to_owned() + &group + &format!("){{{}}}?", rec))
                        .collect::<Vec<_>>()
                        .join("")
                }).collect::<Vec<_>>().join("|");
                dbg!(&g);
                regex = "(".to_owned() + &g + ")";
            }
            break;
        }
        match part {
            "|" => {
                regex.push_str(")|(");
                // regex.push('|');
            }
            _ => {
                let resolved = resolve(map, part);
                groups_so_far.insert(resolved.clone());
                regex.push_str(&resolved);
            }
        }
    }
    if !loops {
        regex.push(')');
    }
    map.insert(key.to_string(), regex.clone());
    // if loops {
    //     dbg!(&regex);
    // }
    regex
}

fn main() {
    let contents = parse_file().unwrap();
    let mut iter = contents.split("\n\n");
    // println!("{}", &input);
    let mut res = build_map(iter.next().unwrap());
    res.insert("8".to_string(), "42 | 42 8".to_string());
    res.insert("11".to_string(), "42 31 | 42 11 31".to_string());
    // TODO: Solve part 2
    let tests = iter.next().unwrap();
    // dbg!(&res);
    let regex_string = build_regex_string(&mut res, "0");
    let regex = Regex::new(&regex_string).unwrap();
    // dbg!(&regex);
    let matched = tests
        .lines()
        .map(|case| regex.is_match(case))
        .filter(|res| *res)
        .count();
    dbg!(matched);
}
