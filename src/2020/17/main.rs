use adventofcode::lib::parse_file;
use itertools::Itertools;
use std::collections::HashMap;

type Coord = Vec<isize>;
type Movements = Vec<Coord>;
type StateMap = HashMap<Coord, bool>;

// (x, y, z): (-1..1, -1..1, -1..1)

fn movements(dimensions: usize) -> Movements {
    let mut range = vec![];
    for val in -1..=1 {
        range.extend(vec![val; dimensions]);
    }
    let mut gen: Vec<_> = range
        .clone()
        .into_iter()
        .permutations(dimensions)
        .unique()
        .collect();
    gen.retain(|x| x != &vec![0; dimensions]);
    gen
}

fn new_state(map: &StateMap, movements: &Movements) -> StateMap {
    let mut nmap: StateMap = HashMap::new();
    let dimensions = movements.first().unwrap().len();
    for pos in map.keys() {
        let mut cells: Vec<Coord> = movements
            .iter()
            .map(|dir| {
                let mut new_pos = vec![];
                for ind in 0..dimensions {
                    new_pos.push(pos[ind] + dir[ind]);
                }
                // new_pos.reverse();
                new_pos
            })
            .collect();
        cells.push(pos.clone());
        for cell_pos in cells {
            new_neighborhood(map, &mut nmap, cell_pos, movements);
        }
    }
    nmap
}

fn new_neighborhood(map: &StateMap, nmap: &mut StateMap, pos: Coord, movements: &Movements) {
    let dimensions = pos.len();
    let alive_neighbors: usize = movements
        .iter()
        .map(|dir| {
            let mut new_pos = vec![];
            for ind in 0..dimensions {
                new_pos.push(pos[ind] + dir[ind]);
            }
            // new_pos.reverse();
            new_pos
        })
        .filter_map(|pos| map.get(&pos))
        .count();
    let tile = map.get(&pos).unwrap_or(&false);
    let new_state = rules(*tile, alive_neighbors);
    if new_state {
        nmap.insert(pos.clone(), new_state);
    } else {
        // cell is dead, remove it if it was present
        nmap.remove(&pos);
    }
}

fn rules(cell_alive: bool, alive_neighbors: usize) -> bool {
    if cell_alive && (alive_neighbors == 2 || alive_neighbors == 3) {
        true
    } else if !cell_alive && alive_neighbors == 3 {
        true
    } else {
        false
    }
}

fn parse_input(contents: &str, dimensions: usize) -> StateMap {
    let mut map = HashMap::new();
    for (ri, line) in contents.lines().enumerate() {
        for (ci, cell) in line.chars().enumerate() {
            match cell {
                '#' => {
                    let mut pos = vec![ri as isize, ci as isize];
                    for _i in 0..(dimensions-2) {
                        pos.push(0 as isize);
                    }
                    map.insert(pos, true);
                }
                _ => {}
            }
        }
    }
    map
}

fn main() {
    let contents = parse_file().unwrap();
    // let contents = r#".#.
    // ..#
    // ###"#;
    let dimensions = 3;
    let moves = movements(dimensions);    
    let mut map = parse_input(&contents, dimensions);
    // dbg!(&map);
    for _cycle in 0..6 {
        map = new_state(&mut map, &moves);
    }
    let alive_cells: usize = map.values().filter(|&el| *el).count();
    dbg!(alive_cells);
    let dimensions = 4;
    let moves = movements(dimensions);
    let mut map = parse_input(&contents, dimensions);
    for _cycle in 0..6 {
        map = new_state(&mut map, &moves);
    }
    let alive_cells: usize = map.values().filter(|&el| *el).count();
    dbg!(alive_cells);
}
