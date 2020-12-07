use petgraph::Outgoing;
use petgraph::prelude::Dfs;
use petgraph::visit::EdgeRef;
use petgraph::graph::EdgeReference;
use petgraph::Incoming;
use adventofcode::lib::parse_file;
use petgraph::dot::{Config, Dot};
use petgraph::graph::Graph;
use petgraph::prelude::NodeIndex;
use std::collections::{HashMap, HashSet};

fn parse_line(line: &str) -> Vec<String> {
    line.replace("bags", "")
        .replace("bag", "")
        .replace(".", "")
        .split("contain")
        .flat_map(|s| s.split(','))
        .map(|s| s.trim())
        .map(String::from)
        .collect()
}

fn process_entry(
    bags: Vec<String>,
    node_map: &mut HashMap<String, NodeIndex>,
    graph: &mut Graph<String, usize>,
) {
    let mut iter = bags.into_iter();
    let parent_name = iter.next().unwrap();
    let parent_node: NodeIndex;
    if let Some(parent_index) = node_map.get(&parent_name) {
        parent_node = *parent_index;
    } else {    
        parent_node = graph.add_node(parent_name.clone());
        node_map.insert(parent_name, parent_node);
    }
    for child in iter {
        let mut iter = child.split_whitespace();
        let count: usize = iter.next().unwrap().parse().unwrap();
        let child_name = iter
            .fold(String::new(), |a, b| a + " " + b)
            .trim()
            .to_string();
        let child_node: NodeIndex;
        if let Some(child_index) = node_map.get(&child_name) {
            child_node = *child_index;
        } else {
            child_node = graph.add_node(child_name.clone());
            node_map.insert(child_name, child_node);
        }
        graph.add_edge(parent_node, child_node, count);
    }
}

fn count_incoming_nodes(graph: &Graph::<String, usize>, node_index: NodeIndex) -> usize {
    let mut count = 0;
    let mut visited_set = HashSet::<NodeIndex>::new();
    for edge in graph.edges_directed(node_index, Incoming) {
        visited_set.insert(edge.source());
        count = count + 1 + inner_count(graph, edge.source(), &mut visited_set);
    }
    count
}

fn inner_count(graph: &Graph::<String, usize>, node_index: NodeIndex, visited_set: &mut HashSet<NodeIndex>) -> usize {
    let mut count = 0;
    for edge in graph.edges_directed(node_index, Incoming) {
        if visited_set.get(&edge.source()).is_some() {
            continue
        }
        
        visited_set.insert(edge.source());
        count = count + 1 + inner_count(graph, edge.source(), visited_set);
    }
    count
}

fn count_contained_bags(graph: &Graph::<String, usize>, node_index: NodeIndex) -> usize {
    let mut total_bags = 1;
    for edge in graph.edges_directed(node_index, Outgoing) {
        total_bags += *edge.weight() * count_contained_bags(graph, edge.target())
    }
    total_bags
}

fn main() {
    let mut node_map = HashMap::<String, NodeIndex>::new();
    let colors = 0;
    let mut graph = Graph::<String, usize>::new();
    let contents = parse_file().unwrap();
    for line in contents.lines() {
        let r = parse_line(line);
        if r.contains(&"no other".to_string()) {
            continue;
        }

        process_entry(r, &mut node_map, &mut graph);
    }
    // dbg!(&node_map);
    let shiny_index = node_map.get("shiny gold").unwrap();
    let colors = count_incoming_nodes(&graph, *shiny_index);
    dbg!(colors);

    let contained_bags = count_contained_bags(&graph, *shiny_index) - 1;
    dbg!(contained_bags);
    use std::fs;

    fs::write("graph.dot", format!("{:?}", Dot::new(&graph)));
}
