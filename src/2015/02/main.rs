use adventofcode::lib::parse_file;

fn calculate((l, w, h): (usize, usize, usize)) -> (usize, usize) {
    let lw = l * w;
    let wh = w * h;
    let hl = h * l;
    
    let mut sides = [l, w, h];
    sides.sort();

    let slack = sides[0] * sides[1];
    let ribbon = sides[0] * 2 + sides[1] * 2;
    let bow = sides[0] * sides[1] * sides[2];
    
    (2 * lw + 2 * wh + 2 * hl + slack, ribbon + bow)
}

fn main() -> Result<(), Box<dyn std::error::Error + 'static>> {
    // test cases
    assert_eq!(calculate((2, 3, 4)), (58, 34));
    assert_eq!(calculate((1, 1, 10)), (43, 14));

    let mut total_paper: usize = 0;
    let mut total_ribbon: usize = 0;
    
    let contents = parse_file().unwrap();
    for line in contents.lines() {
        let dimensions: Vec<usize> = line.split('x').map(|i| i.parse::<usize>().unwrap()).collect();
        let dimensions = (dimensions[0], dimensions[1], dimensions[2]);
        let (paper, ribbon) = calculate(dimensions);
        total_paper += paper;
        total_ribbon += ribbon;
    }
    dbg!(total_paper, total_ribbon);
    Ok(())
}
