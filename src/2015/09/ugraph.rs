use core::cell::RefCell;
use std::collections::HashMap;
use std::rc::Weak;
use std::rc::Rc;

#[derive(Debug)]
pub struct Node {
    pub name: String,
    pub edges: RefCell<Vec<Weak<Edge>>>
}

impl Node {
    pub fn new(name: String) -> Self {
        Self {
            name: name,
            edges: RefCell::new(vec![])
        }
    }

    pub fn edges(&self) -> Vec<Rc<Edge>> {
        let mut edges: Vec<Rc<Edge>> = self.edges.borrow().iter().map(|weak_edge| {
            weak_edge.upgrade().unwrap()
        }).collect();
        edges.sort_by(|a, b| a.weight.cmp(&b.weight));
        edges
    }
}

#[derive(Debug)]
pub struct Edge {
    pub weight: usize,
    pub nodes: (Rc<Node>, Rc<Node>)
}

impl Edge {
    pub fn new(weight: usize, nodes: (Rc<Node>, Rc<Node>)) -> Self {
        Self {
            weight: weight,
            nodes: nodes
        }
    }
}

#[derive(Debug)]
pub struct UGraph {
    nodes: HashMap<String, Rc<Node>>,
    edges: Vec<Rc<Edge>>
}

impl UGraph {
    pub fn new() -> Self {
        Self {
            nodes: HashMap::new(),
            edges: vec![]
        }
    }

    pub fn insert_node(&mut self, name: &str) -> Rc<Node> {
        let node = Rc::new(Node::new(name.to_string()));
        let clone = Rc::clone(&node);
        self.nodes.insert(name.to_string(), node);
        clone
    }

    pub fn insert_edge(&mut self, edge: Rc<Edge>) {
        let (f, s) = &edge.nodes;
        f.edges.borrow_mut().push(Rc::downgrade(&edge));
        s.edges.borrow_mut().push(Rc::downgrade(&edge));
        self.edges.push(edge)
    }

    pub fn get_node(&self, name: &str) -> Option<Rc<Node>> {
        self.nodes.get(name).and_then(|node| Some(Rc::clone(node)))
    }

    pub fn ham_path_length(&mut self) -> usize {
        0
    }
}
