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
    let mut parsed = vec![];
    for line in string.lines() {
        let result = parse_line(line);
        cities.insert(result.0);
        cities.insert(result.1);
        parsed.push(result);        
    }
    let mut graph = UGraph::new(cities.len());
    graph
}

fn main() -> Result<(), Box<dyn std::error::Error + 'static>> {
    // test case
    let mut graph = UGraph::new(3);
    parse_line("London to Dublin = 464");
    parse_line("London to Belfast = 518");
    parse_line("Dublin to Belfast = 141");
    debug_assert_eq!(graph.held_karp(), 605 as usize);

    /*let mut graph = UGraph::new();
    let contents = parse_file().unwrap();
    for line in contents.lines() {
        parse_line(line, &mut graph);
    }*/

    // let mut graph = UGraph::new();
    
    Ok(())
}
