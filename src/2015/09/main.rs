use std::collections::HashSet;
use adventofcode::lib::parse_file;

mod ugraph;
use crate::ugraph::*;

fn parse_line(line: &str) -> (&str, &str, usize) {
    let expr: Vec<&str> = line.split('=').collect();
    let (cities, distance) = (expr[0].trim(), expr[1].trim().parse::<usize>().unwrap());
    let expr: Vec<&str> = cities.split("to").collect();
    let (from_name, to_name) = (expr[0].trim(), expr[1].trim());
    (from_name, to_name, distance)
}

fn parse_string(string: &str) -> UGraph {
    let mut cities = HashSet::new();
    string.lines().fold(vec![], |mut vec, x| {
        let result = parse_line(x);
        cities.insert(result.0);
        cities.insert(result.1);
        vec.push(result);
        vec                        
    }).iter().fold(UGraph::new(cities.len() + 1), |mut graph, x| {
        let zi = graph.insert_node("zero");
        let fi = graph.insert_node(x.0);
        let ti = graph.insert_node(x.1);
        graph.insert_edge((fi, ti), x.2);
        graph.insert_edge((fi, zi), 0);
        graph.insert_edge((ti, zi), 0);
        graph
    })
}

fn main() -> Result<(), Box<dyn std::error::Error + 'static>> {
    // test case
    let test = "London to Dublin = 464\n\
                London to Belfast = 518\n\
                Dublin to Belfast = 141";
    let graph = parse_string(test);
    debug_assert_eq!(graph.held_karp(Goal::Min), 605 as usize);
    debug_assert_eq!(graph.held_karp(Goal::Max), 982 as usize);

    let contents = parse_file().unwrap();
    let graph = parse_string(&contents);
    dbg!(graph.held_karp(Goal::Min));
    dbg!(graph.held_karp(Goal::Max));
    
    Ok(())
}
