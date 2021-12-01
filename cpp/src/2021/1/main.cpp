#include <fstream>
#include <iostream>
#include <numeric>
#include <sstream>
#include <streambuf>
#include <string>
#include <vector>

using namespace std;

uint count_increases(const vector<uint> &mes, uint window) {
  uint count = 0;
  uint i = 0;
  uint size = mes.size();

  while ((i + window) < size) {
    auto s1 = mes.begin() + i;
    auto e1 = mes.begin() + i + window;
    auto s2 = mes.begin() + i + 1;
    auto e2 = mes.begin() + i + 1 + window;

    auto first = accumulate(s1, e1, 0, plus<uint>());
    auto second = accumulate(s2, e2, 0, plus<uint>());

    // cout << "first: " << first << "\n";
    // cout << "second: " << second << "\n";

    if (second - first > 0)
      count++;
    i++;
  }

  return count;
}

vector<string> split(const string &input, char delim) { // TODO: move to aoc lib
  vector<string> results;
  auto stream = stringstream{input};

  for (string part; getline(stream, part, delim);)
    results.emplace_back(part);

  return results;
}

int main(int argc, char *argv[]) {
  if (argc != 2) {
    return 1;
  }
  ifstream file(argv[1]);
  string contents((std::istreambuf_iterator<char>(file)),
                  std::istreambuf_iterator<char>()); // TODO: extract to aoc lib

  auto lines = split(contents, '\n');

  vector<uint> mes;
  for (auto &&line : lines)
    mes.emplace_back(atoi(line.c_str()));

  cout << "part one: " << count_increases(mes, 1) << "\n";
  cout << "part two: " << count_increases(mes, 3) << "\n";
}
