use adventofcode::lib::parse_file;
use std::collections::HashSet;

fn calculate_presents(path: &str) -> usize {
    // (0, 0) - origin
    // (1, 1) - right, up (x, y)
    let mut santas_map = [HashSet::new() as HashSet<(isize, isize)>, HashSet::new() as HashSet<(isize, isize)>];
    let mut santas_pos = [(0, 0); 2];
    let mut current_santa = 0;
    
    santas_map[0].insert((0, 0));
    santas_map[1].insert((0, 0));
    
    for c in path.chars() {
        let direction = match c {
            '>' => (1, 0),
            '^' => (0, 1),
            '<' => (-1, 0),
            'v' => (0, -1),
             _ => (0, 0)
        };
        santas_pos[current_santa] = (santas_pos[current_santa].0 + direction.0,
                                     santas_pos[current_santa].1 + direction.1);
        santas_map[current_santa].insert(santas_pos[current_santa]);
        if current_santa == 0 {
            current_santa = 1
        } else {
            current_santa = 0
        }
    }
    santas_map[0].union(&santas_map[1]).count()
}

fn main() -> Result<(), Box<dyn std::error::Error + 'static>> {
    // test cases
    /* v1, doesn't work anymore
    assert_eq!(calculate_presents(">"), 2);
    assert_eq!(calculate_presents("^>v<"), 4);
    assert_eq!(calculate_presents("^v^v^v^v^v"), 2);
     */

    assert_eq!(calculate_presents("^v"), 3);
    assert_eq!(calculate_presents("^>v<"), 3);
    assert_eq!(calculate_presents("^v^v^v^v^v"), 11);
    
    let contents = parse_file().unwrap();
    dbg!(calculate_presents(&contents));
    Ok(())
}

