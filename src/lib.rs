pub mod lib {
    use std::fs;
    use std::env;
    
    pub fn parse_file() -> Result<String, Box<dyn std::error::Error + 'static>> {
        let args: Vec<String> = env::args().collect();
        let filepath = &args[1];
        let contents = fs::read_to_string(filepath)?;
        Ok(contents)
    }
}
