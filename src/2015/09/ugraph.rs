// use std::collections::HashMap;

#[derive(Debug)]
pub struct UGraph {
    nodes: Vec<String>,
    capacity: usize,
    distance_matrix: Vec<usize>
}

impl UGraph {
    pub fn new(capacity: usize) -> Self {
        Self {
            nodes: vec![],
            capacity: capacity,
            distance_matrix: vec![0; capacity * capacity]
        }
    }

    pub fn insert_node(&mut self, name: &str) -> usize {
        self.get_index(name).unwrap_or_else(|| {
            let current_len = self.nodes.len();
            if current_len == self.capacity {
                panic!("can't insert more than capacity")
            }
            self.nodes.push(name.to_string());
            current_len
        })
    }

    fn extend_matrix(&mut self) {
        let new_matrix = vec![0]
    }

    fn get_index(&self, name: &str) -> Option<usize> {
        self.nodes.iter().position(|n| n == name)
    }

    fn compute_indices(&self, row: usize, column: usize) -> usize {
        row * self.capacity + column
    }

    pub fn insert_edge(&mut self, (left, right): (usize, usize), weight: usize) {
        dbg!(left, right);
        if left <= self.nodes.len() && right <= self.nodes.len() {
            let li = self.compute_indices(left, right);
            let ri = self.compute_indices(right, left);
            dbg!(li, ri);
            self.distance_matrix[li] = weight;
            self.distance_matrix[ri] = weight;
        } else {
            panic!("shit")
        }
    }
}
