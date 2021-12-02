#include "aoc.hpp"
#include <fstream>
#include <sstream>

namespace aoc {
using namespace std;

optional<string> get_input(int argc, char *argv[]) {
  if (argc != 2) {
    return {};
  }
  ifstream file(argv[1]);
  return string((std::istreambuf_iterator<char>(file)),
                std::istreambuf_iterator<char>()); // TODO: extract to aoc lib
}

vector<string> split(const string &input, char delim) { // TODO: move to aoc lib
  vector<string> results;
  auto stream = stringstream{input};

  for (string part; getline(stream, part, delim);)
    results.emplace_back(part);

  return results;
}

} // namespace aoc
