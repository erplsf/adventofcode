use adventofcode::lib::parse_file;
use linked_hash_set::LinkedHashSet;
use linked_hash_map::LinkedHashMap;
use std::hash::{Hash, Hasher};
use std::iter::FromIterator;

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

#[derive(Debug)]
struct Map {
    tiles: Vec<Tile>,
}

impl Map {
    pub fn new() -> Self {
        Self { tiles: vec![] }
    }

    pub fn push(&mut self, tile: Tile) {
        self.tiles.push(tile);
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
}

// sides are read from top to bottom and from right to left
// size is 10x10
#[derive(Debug, Clone, PartialEq, Eq)]
struct Tile {
    id: usize,
    rows: Vec<Vec<char>>,
    all_edges: LinkedHashSet<String>,
    edge_hash: LinkedHashMap<L, String>,
}

impl Hash for Tile {
    fn hash<H: Hasher>(&self, state: &mut H) {
        self.id.hash(state);
    }
}

impl Tile {
    pub fn new(id: usize, rows: Vec<Vec<char>>) -> Self {
        let all_edges = calculate_all_edges(&rows);
        let edge_hash = fill_edge_hash(&all_edges);
        Self {
            id,
            rows,
            all_edges,
            edge_hash,
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
    let tile = map.tiles.first().unwrap();
    dbg!(&tile.edge_hash);
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
