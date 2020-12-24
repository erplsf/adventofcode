use adventofcode::lib::parse_file;
use phf::{phf_map, phf_set};
use std::collections::HashMap;

// (x, z, y): (-1..1, -1..1, -1..1)
// hexagonal grid: (0, -1, +1)  nw ne (+1, -1, 0)
//                 (-1, 0, +1) w     e (+1, 0, -1)
//                 (-1, +1, 0)  sw se (0, +1, -1)

static MOVEMENTS: phf::Map<&'static str, (isize, isize, isize)> = phf_map! {
    "ne" => (1, -1, 0),
    "e" => (1, 0, -1),
    "se" => (0, 1, -1),
    "sw" => (-1, 1, 0),
    "w" => (-1, 0, 1),
    "nw" => (0, -1, 1),
};

fn new_state(map: &HashMap<(isize, isize, isize), bool>) -> HashMap<(isize, isize, isize), bool> {
    let mut nmap: HashMap<(isize, isize, isize), bool> = HashMap::new();
    for key in map.keys() {
        let mut cells: Vec<(isize, isize, isize)> = MOVEMENTS
            .values()
            .map(|dir| (key.0 + dir.0, key.1 + dir.1, key.2 + dir.2))
            .collect();
        cells.push(*key);
        for cell_pos in cells {
            new_neighborhood(map, &mut nmap, cell_pos);
        }
    }
    nmap
}

fn new_neighborhood(
    map: &HashMap<(isize, isize, isize), bool>,
    nmap: &mut HashMap<(isize, isize, isize), bool>,
    pos: (isize, isize, isize),
) {
    let black_neighbors: usize = MOVEMENTS
        .values()
        .map(|dir| (pos.0 + dir.0, pos.1 + dir.1, pos.2 + dir.2))
        .filter_map(|pos| map.get(&pos))
        .count();
    let tile = map.get(&pos).unwrap_or(&false);
    if *tile {
        // black
        if black_neighbors == 0 || black_neighbors > 2 {
            nmap.insert(pos, false);
            // *tile = false;
        } else {
            nmap.insert(pos, *tile);
        }
    } else {
        // white
        if black_neighbors == 2 {
            nmap.insert(pos, true);
            // *tile = true
        } else {
            nmap.insert(pos, *tile);
        }
    };
    if !nmap.get(&pos).unwrap() {
        // tile is false, remove it
        nmap.remove(&pos);
    }
}

fn main() {
    let contents = parse_file().unwrap();
    let mut map: HashMap<(isize, isize, isize), bool> = HashMap::new();
    for line in contents.lines() {
        let mut pos = (0, 0, 0);
        let mut iter = line.chars();
        while let Some(ch) = iter.next() {
            let st = &ch.to_string()[..];
            if let Some(val) = MOVEMENTS.get(st) {
                pos = (pos.0 + val.0, pos.1 + val.1, pos.2 + val.2);
                // println!("{}", st);
            } else {
                let nch = iter.next().unwrap();
                let nst = format!("{}{}", ch, nch);
                let val = MOVEMENTS.get(&nst[..]).unwrap();
                pos = (pos.0 + val.0, pos.1 + val.1, pos.2 + val.2);
                // println!("{}", nst);
            }
        }
        let tile = map.entry(pos).or_insert(false);
        *tile = !*tile;
        if !*tile {
            // remove false tiles
            map.remove(&pos);
        }
        // println!("{:?} -> {:?}", pos, tile);
    }
    let black_tiles: usize = map.values().filter(|&el| *el).count();
    println!("Day 0: {}", black_tiles);
    for _day in 0..100 {
        map = new_state(&mut map);
    }
    let black_tiles: usize = map.values().filter(|&el| *el).count();
    println!("Day 100: {}", black_tiles);
}
