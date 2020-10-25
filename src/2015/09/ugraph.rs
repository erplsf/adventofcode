use std::collections::HashMap;
use itertools::Itertools;

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

    fn get_index(&self, name: &str) -> Option<usize> {
        self.nodes.iter().position(|n| n == name)
    }

    fn compute_indices(&self, row: usize, column: usize) -> usize {
        row * self.capacity + column
    }

    pub fn insert_edge(&mut self, (left, right): (usize, usize), weight: usize) {
        if left <= self.nodes.len() && right <= self.nodes.len() {
            let li = self.compute_indices(left, right);
            let ri = self.compute_indices(right, left);
            self.distance_matrix[li] = weight;
            self.distance_matrix[ri] = weight;
        } else {
            panic!("can't add edge to nodes that are out of bounds")
        }
    }

    pub fn held_karp(&self, goal: Goal) -> usize {
        let n = self.nodes.len();
        let mut c = HashMap::new();
        for k in 1..n {
            let index = self.compute_indices(0, k);
            c.insert((1 << k, k), (self.distance_matrix[index], 0));
        }

        for subset_size in 2..n {
            for subset in (1..n).combinations(subset_size) {
                let mut bits = 0;
                for bit in &subset {
                    bits |= 1 << bit;
                }

                for k in &subset {
                    let prev = bits & !(1 << k);

                    let mut res = vec![];
                    for m in &subset {
                        if *m == 0 || *m == *k {
                            continue
                        }
                        let index = self.compute_indices(*m, *k);
                        res.push(
                            (c.get(&(prev, *m)).unwrap().0 + self.distance_matrix[index], *m)
                        );
                    }
                    let val = match &goal {
                        Goal::Min => res.iter().min_by(|x, y| x.0.cmp(&y.0)).unwrap(),
                        Goal::Max => res.iter().max_by(|x, y| x.0.cmp(&y.0)).unwrap()
                    };
                    c.insert((bits, *k), *val);
                }
            }
        }

        let bits = (2_usize.pow(n as u32) - 1) - 1;

        let mut res = vec![];

        for k in 1..n {
            let index = self.compute_indices(k, 0);
            res.push(
                (c.get(&(bits, k)).unwrap().0 + self.distance_matrix[index], k)
            )
        }

        let val = match &goal {
            Goal::Min => res.iter().min_by(|x, y| x.0.cmp(&y.0)).unwrap(),
            Goal::Max => res.iter().max_by(|x, y| x.0.cmp(&y.0)).unwrap()
        };
       
        val.0
    }
}

pub enum Goal {
    Min,
    Max
}
