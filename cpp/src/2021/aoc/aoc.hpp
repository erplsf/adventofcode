#ifndef AOC_H_
#define AOC_H_

#include <optional>
#include <string>
#include <vector>

namespace aoc {
using namespace std;

optional<string> get_input(int argc, char *argv[]);

vector<string> split(const string &input, char delim);

} // namespace aoc

#endif // AOC_H_
