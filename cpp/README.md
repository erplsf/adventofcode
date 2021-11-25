0. `git submodule --update`
1. `cmake -S . -GNinja -B build`
2. `ln -s build/compile_commands.json .`
3. `cmake --build build`
4. `./build/bin/2021/1`
