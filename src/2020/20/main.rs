use adventofcode::lib::parse_file;
use linked_hash_map::LinkedHashMap;
use linked_hash_set::LinkedHashSet;
use std::hash::{Hash, Hasher};
use std::{collections::HashMap, collections::HashSet, iter::FromIterator};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum L {
    A,
    B,
    C,
    D,
    E,
    F,
    G,
    H,
}

const EDGE_LABELS: [L; 8] = [L::A, L::B, L::C, L::D, L::E, L::F, L::G, L::H];
const EDGE_STATES: [[L; 8]; 4] = [
    [L::A, L::B, L::C, L::D, L::E, L::D, L::G, L::B],
    [L::H, L::A, L::F, L::C, L::D, L::C, L::B, L::A],
    [L::G, L::H, L::E, L::F, L::C, L::F, L::A, L::H],
    [L::B, L::G, L::D, L::E, L::F, L::E, L::H, L::G],
];

#[derive(Debug)]
struct Map {
    tiles: Vec<Tile>,
    assembled: HashMap<(usize, usize), Tile>,
    seen: HashSet<Tile>,
    dimension: usize,
}

impl Map {
    pub fn new() -> Self {
        Self {
            tiles: vec![],
            assembled: HashMap::new(),
            seen: HashSet::new(),
            dimension: 0,
        }
    }

    pub fn push(&mut self, tile: Tile) {
        self.tiles.push(tile);
        self.dimension = (self.tiles.len() as f32).sqrt().round() as usize;
    }

    pub fn neighbors_of(&self, tile: &Tile) -> Vec<Tile> {
        self.tiles
            .clone()
            .into_iter()
            .filter_map(|t| if t.neighbor_of(tile) { Some(t) } else { None })
            .collect()
    }

    pub fn neighbors(&self) -> LinkedHashMap<Tile, Vec<Tile>> {
        let mut hash: LinkedHashMap<Tile, Vec<Tile>> = LinkedHashMap::new();
        for tile in self.tiles.clone() {
            hash.insert(tile.clone(), self.neighbors_of(&tile));
        }
        hash
    }

    pub fn corners(&self) -> Vec<Tile> {
        self.neighbors()
            .into_iter()
            .filter_map(|(t, nb)| if nb.len() == 2 { Some(t) } else { None })
            .collect()
    }

    pub fn reassemble(&mut self) {
        let mut corners = self.corners();
        let mut corner = corners.first_mut().unwrap().clone();
        let neighbor_map = self.neighbors();
        let mut nei_tiles: Vec<_> = neighbor_map[&corner]
            .clone()
            .into_iter()
            .map(|tile| corner.shared_edges(&tile))
            .collect();
        let se1 = nei_tiles.pop().unwrap();
        let se2 = nei_tiles.pop().unwrap();
        for i in 0..8 {
            if se1.contains(&corner.edge_at(1)) && se2.contains(&corner.edge_at(2)) {
                break;
            }
            if i == 3 {
                corner.flip();
            } else {
                corner.rotate();
            }
        }
        self.place_tile(&corner, (0, 0));
        self.orient(&corner, (0, 0));
    }

    pub fn place_tile(&mut self, tile: &Tile, rc: (usize, usize)) {
        self.assembled.insert(rc, tile.clone());
        self.seen.insert(tile.clone());
    }

    pub fn orient(&mut self, tile: &Tile, rc: (usize, usize)) {
        if rc.0 >= self.dimension || rc.1 >= self.dimension {
            return
        }
        let mut neighbors_map = self.neighbors();
        if let Some(neighbors) = neighbors_map.get_mut(&tile) {
            for neighbor in neighbors {
                if !self.seen.contains(neighbor) {
                    if neighbor.has_edge(&tile.edge_at(1))  { // east
                        neighbor.arrange(3, &tile.edge_at(1)); // west, east
                        self.place_tile(neighbor, (rc.0, rc.1+1));
                        self.orient(neighbor, (rc.0, rc.1+1));
                    } else if neighbor.has_edge(&tile.edge_at(2)) { // south
                        neighbor.arrange(0, &tile.edge_at(2)); // north, south
                        self.place_tile(neighbor, (rc.0+1, rc.1));
                        self.orient(neighbor, (rc.0+1, rc.1));
                    }
                }
            }
        }
    }

    pub fn print_assembled_tile_ids(&self) {
        for rc in 0..self.dimension {
            for cc in 0..self.dimension {
                print!("{} ", self.assembled[&(cc, rc)].id);
            }
            if rc < self.dimension-1 {
                println!();
            }
        }
    }
}

// sides are read from top to bottom and from right to left
// size is 10x10
#[derive(Debug, Clone, PartialEq, Eq)]
struct Tile {
    id: usize,
    rows: Vec<Vec<char>>,
    dimension: usize,
    all_edges: LinkedHashSet<String>,
    edge_hash: LinkedHashMap<L, String>,
    flipped: bool,
    rotations: usize,
}

impl Hash for Tile {
    fn hash<H: Hasher>(&self, state: &mut H) {
        self.id.hash(state);
    }
}

impl Tile {
    //    SIDES = {:N=>0,:E=>1,:S=>2,:W=>3}
    pub fn new(id: usize, rows: Vec<Vec<char>>) -> Self {
        let all_edges = calculate_all_edges(&rows);
        let edge_hash = fill_edge_hash(&all_edges);
        Self {
            id,
            rows,
            dimension: rows.len(),
            all_edges,
            edge_hash,
            flipped: false,
            rotations: 0,
        }
    }

    pub fn shared_edges(&self, tile: &Tile) -> LinkedHashSet<String> {
        self.all_edges
            .intersection(&tile.all_edges)
            .cloned()
            .collect()
    }

    pub fn neighbor_of(&self, tile: &Tile) -> bool {
        self != tile && !self.shared_edges(tile).is_empty()
    }

    pub fn edge_for(&self, label: &L) -> String {
        self.edge_hash.get(label).cloned().unwrap()
    }

    pub fn rotate(&mut self) {
        self.rotations = (self.rotations + 1) % 4
    }

    pub fn flip(&mut self) {
        self.flipped = !self.flipped;
    }

    pub fn edge_at(&self, side_index: usize) -> String {
        // 0 -> north, 1 -> east...
        let index = if self.flipped {
            side_index + 4
        } else {
            side_index
        };
        self.edge_for(&EDGE_STATES[self.rotations][index])
    }

    pub fn has_edge(&self, edge: &String) -> bool {
        self.all_edges.contains(edge)
    }

    pub fn arrange(&mut self, dir_index: usize, edge: &String) -> bool {
        if self.has_edge(edge) {
            for i in 0..8 {
                if self.edge_at(dir_index) == *edge {
                    return true;
                }
                if i == 3 {
                    self.flip()
                } else {
                    self.rotate()
                }
            }
        } else {
            return false;
        }
        return true;
    }

    pub fn strip_borders(&self) -> Self {
        for (rc, row) in self.rows.iter().enumerate() {
            if rc == 0 || rc == self.dimension-1 {
                continue;
            }
        }
        todo!()
    }
}

pub fn fill_edge_hash(edges: &LinkedHashSet<String>) -> LinkedHashMap<L, String> {
    let mut map = LinkedHashMap::new();
    for (label, edge) in EDGE_LABELS.iter().zip(edges.iter()) {
        map.insert(label.clone(), edge.clone());
    }
    map
}

fn calculate_all_edges(rows: &Vec<Vec<char>>) -> LinkedHashSet<String> {
    let mut edges = vec![];
    edges.push(
        // edge-left
        rows.clone().into_iter().fold("".to_string(), |mut acc, x| {
            acc.push_str(&x.first().unwrap().to_string());
            acc
        }),
    );
    edges.push(
        // edge-top
        rows.first().unwrap().iter().collect(),
    );
    edges.push(
        // edge-right
        rows.clone().into_iter().fold("".to_string(), |mut acc, x| {
            acc.push_str(&x.last().unwrap().to_string());
            acc
        }),
    );
    edges.push(
        // edge-bottom
        rows.last().unwrap().iter().collect(),
    );
    let rev: Vec<String> = edges // reverse the edges
        .clone()
        .into_iter()
        .map(|x| x.chars().rev().collect::<String>())
        .collect();
    let mut set = LinkedHashSet::from_iter(edges);
    set.extend(rev);
    set
}

fn parse_tile_block(tile_block: &str) -> Tile {
    let mut iter = tile_block.lines();
    let title = iter.next().unwrap();
    let id: usize = title
        .split(" ")
        .last()
        .unwrap()
        .replace(":", "")
        .parse()
        .unwrap();
    let mut field: Vec<Vec<char>> = vec![];
    for line in iter {
        field.push(line.chars().collect());
    }
    Tile::new(id, field)
}

fn main() {
    let contents = parse_file().unwrap();
    let mut map = Map::new();
    for tile_block in contents.split("\n\n") {
        let tile = parse_tile_block(tile_block);
        map.push(tile);
    }
    map.reassemble();
    map.print_assembled_tile_ids();
    // let corner_product: usize = map.corners().into_iter().map(|t| t.id).product();
    // dbg!(corner_product);
    // let first_tile = unused_tiles.pop().unwrap();
    // let sec_tile = unused_tiles.pop().unwrap();
    // dbg!(first_tile.shared_edges(&sec_tile));
    // dbg data
    // let ft = Tile::new(1, vec![vec!['1', '2'], vec!['3', '4']]);
    // let st = Tile::new(2, vec![vec!['1', '2'], vec!['5', '6']]);
    // let mut map = Map::new();
    // map.push(ft.clone());
    // map.push(st.clone());
    // map.push(Tile::new(2, vec![vec!['7', '8'], vec!['5', '6']]));
    // dbg!(map.corners());
}
