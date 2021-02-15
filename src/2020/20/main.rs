use adventofcode::lib::parse_file;
use linked_hash_map::LinkedHashMap;
use linked_hash_set::LinkedHashSet;
use onig::Regex;
use std::convert::TryFrom;
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

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum S {
    N = 0,
    E = 1,
    S = 2,
    W = 3,
}

static EDGE_LABELS: [L; 8] = [L::A, L::B, L::C, L::D, L::E, L::F, L::G, L::H];
static EDGE_STATES: [[L; 8]; 4] = [
    [L::A, L::B, L::C, L::D, L::E, L::D, L::G, L::B], // 0 deg
    [L::H, L::A, L::F, L::C, L::D, L::C, L::B, L::A], // 90 deg
    [L::G, L::H, L::E, L::F, L::C, L::F, L::A, L::H], // 180 deg
    [L::B, L::G, L::D, L::E, L::F, L::E, L::H, L::G], // 270 deg
];

#[derive(Debug)]
struct TileMap {
    tiles: LinkedHashMap<usize, Tile>,
    assembled: HashMap<(usize, usize), usize>,
    seen: HashSet<usize>,
    dimension: usize,
}

impl TileMap {
    pub fn new() -> Self {
        Self {
            tiles: LinkedHashMap::new(),
            assembled: HashMap::new(),
            seen: HashSet::new(),
            dimension: 0,
        }
    }

    pub fn push(&mut self, tile: Tile) {
        self.tiles.insert(tile.id, tile);
        self.dimension = (self.tiles.len() as f32).sqrt().round() as usize;
    }

    pub fn neighbors_of(&self, tile: &Tile) -> Vec<usize> {
        self.tiles
            .values()
            .into_iter()
            .filter_map(|t| {
                if t.neighbor_of(tile) {
                    Some(t.id)
                } else {
                    None
                }
            })
            .collect()
    }

    pub fn neighbors(&self) -> LinkedHashMap<usize, Vec<usize>> {
        let mut hash = LinkedHashMap::new();
        for tile in self.tiles.values() {
            hash.insert(tile.id, self.neighbors_of(&tile));
        }
        hash
    }

    pub fn corners(&self) -> Vec<usize> {
        self.neighbors()
            .into_iter()
            .filter_map(|(t, nb)| if nb.len() == 2 { Some(t) } else { None })
            .collect()
    }

    pub fn reassemble(&mut self) {
        let corners = self.corners();
        let neighbor_map = self.neighbors();
        let corner_id = corners.first().unwrap();
        let corner = self.tiles.get(corner_id).unwrap();
        let mut nei_tiles: Vec<_> = neighbor_map[corner_id]
            .clone()
            .into_iter()
            .map(|tile_id| corner.shared_edges(self.tiles.get(&tile_id).unwrap()))
            .collect();
        let corner = self.tiles.get_mut(corner_id).unwrap();
        let se1 = nei_tiles.pop().unwrap();
        let se2 = nei_tiles.pop().unwrap();
        for i in 0..8 {
            if se1.contains(&corner.edge_at(S::E)) && se2.contains(&corner.edge_at(S::S)) {
                break;
            }
            if i == 3 {
                corner.flip();
            } else {
                corner.rotate();
            }
        }
        // println!("tile: {}, rot: {}, flip: {}", corner.id, corner.rotations, corner.flipped);
        let corner_id = corner.id;
        self.place_tile(corner_id, (0, 0));
        self.orient(corner_id, (0, 0));
    }
    pub fn place_tile(&mut self, tile_id: usize, rc: (usize, usize)) {
        self.assembled.insert(rc, tile_id);
        self.seen.insert(tile_id);
    }

    pub fn orient(&mut self, tile_id: usize, (rc, cc): (usize, usize)) {
        if rc >= self.dimension || cc >= self.dimension {
            return;
        }
        let mut original_tile = self.tiles.get(&tile_id).unwrap().clone();
        // println!("tile: {}, rot: {}, flip: {}", tile.id, tile.rotations, tile.flipped);
        let mut neighbors_map = self.neighbors();
        if let Some(neighbors) = neighbors_map.get_mut(&tile_id) {
            for next_tile_id in neighbors {
                let next_tile = self.tiles.get_mut(next_tile_id).unwrap();
                if !self.seen.contains(next_tile_id) {
                    if next_tile.has_edge(&original_tile.edge_at(S::E)) {
                        // east
                        next_tile.arrange(S::W, original_tile.edge_at(S::E)); // west, east
                        self.place_tile(*next_tile_id, (rc, cc + 1));
                        self.orient(*next_tile_id, (rc, cc + 1));
                    } else if next_tile.has_edge(&original_tile.edge_at(S::S)) {
                        // south
                        next_tile.arrange(S::N, original_tile.edge_at(S::S)); // north, south
                        self.place_tile(*next_tile_id, (rc + 1, cc));
                        self.orient(*next_tile_id, (rc + 1, cc));
                    }
                } else {
                    // panic!("try to fit a seen tile");
                }
            }
        } else {
            panic!("no neighboors found, wtf");
        }
    }

    pub fn print_assembled_tile_ids(&self) {
        for rc in 0..self.dimension {
            for cc in 0..self.dimension {
                print!("{} ", self.assembled[&(rc, cc)]);
            }
            if rc < self.dimension - 1 {
                println!();
            }
        }
        println!();
    }

    pub fn print_assembled_tiles(&mut self) {
        let tile_size = self.tiles.values().next().unwrap().dimension;
        for rc in 0..self.dimension {
            for trc in 0..tile_size {
                for cc in 0..self.dimension {
                    let tile_id = self.assembled.get(&(rc, cc)).unwrap();
                    let tile = self.tiles.get_mut(&tile_id).unwrap();
                    tile.refresh();
                    for tcc in 0..tile.dimension {
                        print!("{}", tile.data[trc][tcc]);
                    }
                    print!(" ");
                }
                println!();
            }
            if rc < self.dimension - 1 {
                println!();
            }
        }
        println!();
    }

    pub fn export_image(&mut self, stripped: bool) -> Tile {
        let mut rows: Vec<Vec<char>> = vec![];
        let mut tile_size = self.tiles.values().next().unwrap().dimension;
        if stripped {
            tile_size = tile_size - 2;
        }
        for rc in 0..self.dimension {
            for trc in 0..tile_size {
                let mut row: Vec<char> = vec![];
                for cc in 0..self.dimension {
                    let tile_id = self.assembled.get(&(rc, cc)).unwrap();
                    let mut tile = self.tiles.get(&tile_id).unwrap().clone();
                    if stripped {
                        tile = tile.strip_borders();
                    }
                    row.extend(tile.data[trc].clone());
                }
                rows.push(row);
            }
        }
        Tile::new(0, rows)
    }
}

// sides are read from top to bottom and from right to left
// size is 10x10
#[derive(Debug, Clone, PartialEq, Eq)]
struct Tile {
    id: usize,
    rows: Vec<Vec<char>>,
    data: Vec<Vec<char>>,
    dimension: usize,
    all_edges: LinkedHashSet<String>,
    edge_hash: LinkedHashMap<L, String>,
    flipped: bool,
    rotations: usize,
    refreshed: bool,
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
        let len = rows.len();
        Self {
            id,
            rows: rows.clone(),
            data: rows,
            dimension: len,
            all_edges,
            edge_hash,
            flipped: false,
            refreshed: false,
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

    pub fn edge_for(&self, label: L) -> String {
        self.edge_hash.get(&label).cloned().unwrap()
    }

    pub fn rotate(&mut self) {
        self.refreshed = false;
        self.rotations = (self.rotations + 1) % 4
    }

    pub fn flip(&mut self) {
        self.refreshed = false;
        self.flipped = !self.flipped;
    }

    pub fn edge_at(&self, side_index: S) -> String {
        // 0 -> north, 1 -> east...
        let index = if self.flipped {
            side_index as usize + 4
        } else {
            side_index as usize
        };
        self.edge_for(EDGE_STATES[self.rotations][index])
    }

    pub fn has_edge(&self, edge: &String) -> bool {
        self.all_edges.contains(edge)
    }

    pub fn arrange(&mut self, side: S, edge: String) -> bool {
        if self.has_edge(&edge) {
            for i in 0..8 {
                if self.edge_at(side) == edge {
                    return true;
                }
                if i == 3 {
                    self.flip()
                } else {
                    self.rotate()
                }
            }
        } else {
            panic!("should't be here");
        }
        return true;
    }

    pub fn strip_borders(&mut self) -> Self {
        self.refresh();
        let mut vecs: Vec<Vec<char>> = vec![];
        for (rc, row) in self.data.iter().enumerate() {
            if rc == 0 || rc == self.dimension - 1 {
                continue;
            }
            let mut vec: Vec<char> = vec![];
            for (cc, ch) in row.iter().enumerate() {
                if cc == 0 || cc == self.dimension - 1 {
                    continue;
                }
                vec.push(*ch);
            }
            vecs.push(vec);
        }
        Self::new(0, vecs)
    }

    pub fn refresh(&mut self) {
        if self.refreshed {
            return;
        }
        let mut v = self.rows.clone();
        for _i in 0..self.rotations {
            let mut t = transpose(v);
            for iv in t.iter_mut() {
                iv.reverse();
            }
            v = t;
        }
        if self.flipped {
            for iv in v.iter_mut() {
                iv.reverse();
            }
        }
        self.data = v;
        self.refreshed = true;
    }

    pub fn print(&mut self) {
        self.refresh();
        for row in self.data.iter() {
            for ch in row.iter() {
                print!("{}", ch);
            }
            println!();
        }
    }

    pub fn one_line(&mut self) -> String {
        self.refresh();
        self.data
            .clone()
            .iter()
            .map(|row| row.into_iter().collect::<String>())
            .collect()
    }
}

pub fn transpose<T>(v: Vec<Vec<T>>) -> Vec<Vec<T>>
where
    T: Clone,
{
    assert!(!v.is_empty());
    (0..v[0].len())
        .map(|i| v.iter().map(|inner| inner[i].clone()).collect::<Vec<T>>())
        .collect()
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
    edges.push(
        // edge-left
        rows.clone().into_iter().fold("".to_string(), |mut acc, x| {
            acc.push_str(&x.first().unwrap().to_string());
            acc
        }),
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

// Monster:
//"                  # "
//"#    ##    ##    ###"
//" #  #  #  #  #  #   "

// Regex:
//

static MONSTER_LINE_LEN: usize = 20;
static MONSTER_ROCK_COUNT: usize = 15;

fn build_monster(spacing: usize) -> String {
    let filler = "*".repeat(spacing);
    format!(
        "------------------#-{0}#----##----##----###{0}-#--#--#--#--#--#---",
        filler
    )
}

fn compile_monster_searcher(spacing: usize) -> Regex {
    Regex::new(&format!(
        r"(?<=.{{18}}#..{{{0}}})#.{{4}}##.{{4}}##.{{4}}###(?=.{{{0}}}.#..#..#..#..#..#...)",
        spacing
    ))
    .unwrap()
}

fn find_tile_roughness(mut tile: Tile) -> usize {
    assert!(tile.dimension > MONSTER_LINE_LEN);
    let spacing: usize = tile.dimension - MONSTER_LINE_LEN;
    let re = compile_monster_searcher(spacing);
    let mut monsters_count = 0;
    for i in 0..8 {
        let one_line = tile.one_line();
        let captures_len = re.captures_iter(&one_line).count();
        if captures_len > 0 {
            monsters_count = captures_len;
            println!("found monsters here:");
            tile.print();
            break;
        };
        if i == 3 {
            tile.flip();
        } else {
            tile.rotate();
        }
    }
    assert!(monsters_count > 0);
    let monster_rock_count: usize = monsters_count * MONSTER_ROCK_COUNT;
    let tile_rock_count: usize = tile.data.iter().fold(0, |acc, row| {
        acc + row.iter().filter(|&&c| c == '#').count()
    });
    dbg!(monsters_count);
    dbg!(tile_rock_count);
    dbg!(monster_rock_count);
    return tile_rock_count - monster_rock_count;
}

fn main() {
    let contents = parse_file().unwrap();
    let mut map = TileMap::new();
    for tile_block in contents.split("\n\n") {
        let tile = parse_tile_block(tile_block);
        map.push(tile);
    }
    map.reassemble();
    map.print_assembled_tile_ids();
    map.print_assembled_tiles();
    let mut big_tile = map.export_image(true);
    big_tile.print();
    let roughness = find_tile_roughness(big_tile);
    dbg!(roughness);

    // mapping tests
    // let mut map = TileMap::new();
    // let mut t1 = parse_tile_block("Tile: 1\nabcd\naacd\nabcd\ndddd");
    // let mut t2 = parse_tile_block("Tile: 2\nabcd\naacd\nabcd\ndddd");
    // let mut t3 = parse_tile_block("Tile: 3\nabcd\naacd\nabcd\ndddd");
    // let mut t4 = parse_tile_block("Tile: 4\nabcd\naacd\nabcd\ndddd");
    // map.push(t1);
    // map.push(t2);
    // map.push(t3);
    // map.push(t4);
    // map.assembled.insert((0, 0), 1);
    // map.assembled.insert((0, 1), 2);
    // map.assembled.insert((1, 0), 3);
    // map.assembled.insert((1, 1), 4);
    // map.print_assembled_tile_ids();
    // map.print_assembled_tiles();
    // let mut im = map.export_image(true);
    // im.print();

    // asserts
    // let mut t1 = parse_tile_block("Tile: 1\nab\ncd");
    // assert!(t1.edge_at(S::E) == t1.edge_for(L::B));
    // t1.flip();
    // assert!(t1.edge_at(S::E) == t1.edge_for(L::D));
    // t1.flip();
    // assert!(t1.edge_at(S::E) == t1.edge_for(L::B));
    // t1.rotate();
    // assert!(t1.edge_at(S::N) == t1.edge_for(L::H));
    // t1.rotate();
    // assert!(t1.edge_at(S::N) == t1.edge_for(L::G));
    // let mut t2 = t1.clone();
    // t2.refresh();
    // t1.refresh();
    // t1.refresh();
    // assert!(t1 == t2);
    let re = compile_monster_searcher(76);
    let monster = build_monster(76);
    assert!(re.captures_iter(&monster).count() == 1);
}
