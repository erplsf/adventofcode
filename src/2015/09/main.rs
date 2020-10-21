use std::rc::Rc;
use adventofcode::lib::parse_file;

mod ugraph;
use crate::ugraph::*;

fn parse_line(line: &str, graph: &mut UGraph) {
    let expr: Vec<&str> = line.split('=').collect();
    let (cities, distance) = (expr[0].trim(), expr[1].trim().parse::<usize>().unwrap());
    let expr: Vec<&str> = cities.split("to").collect();
    let (from_name, to_name) = (expr[0].trim(), expr[1].trim());
    let from = match graph.get_node(from_name) {
        Some(city) => city,
        None => graph.insert_node(from_name)
    };
    let to = match graph.get_node(to_name) {
        Some(city) => city,
        None => graph.insert_node(to_name)
    };
    graph.insert_edge(Rc::new(Edge::new(distance, (from, to))));
}

fn main() -> Result<(), Box<dyn std::error::Error + 'static>> {
    // test case
    let mut graph = UGraph::new();
    parse_line("London to Dublin = 464", &mut graph);
    parse_line("London to Belfast = 518", &mut graph);
    parse_line("Dublin to Belfast = 141", &mut graph);
    debug_assert_eq!(graph.ham_path_length(), 605 as usize);

    let mut graph = UGraph::new();
    let contents = parse_file().unwrap();
    for line in contents.lines() {
        parse_line(line, &mut graph);
    }
    dbg!(graph.ham_path_length());
    Ok(())
}
