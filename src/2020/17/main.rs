use itertools::Itertools;

fn neighbor_coordinates(dimensions: usize) -> Vec<Vec<i8>> {
    let mut range = vec![];
    for val in -1..=1 {
        range.extend(vec![val; dimensions]);
    }
    let mut gen: Vec<_> = range.clone().into_iter().permutations(dimensions).unique().collect();
    gen.retain(|x| x != &vec![0; dimensions]);
    gen
}

fn main() {
    let res = neighbor_coordinates(2);
    dbg!(&res.len());
    dbg!(&res);
}
