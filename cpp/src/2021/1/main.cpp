#include <aoc/aoc.hpp>
#include <boost/ut.hpp>
#include <fstream>
#include <iostream>
#include <numeric>
#include <optional>
#include <sstream>
#include <streambuf>
#include <string>
#include <vector>

using namespace std;
using namespace aoc;
using namespace boost::ut;

uint count_increases(const vector<uint>& mes, uint window) {
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

    if (second - first > 0)
      count++;
    i++;
  }

  return count;
}

auto solve(string input) {
  auto lines = split(input, '\n');
  vector<uint> mes;

  for (auto&& line: lines)
    mes.emplace_back(stoul(line));
  return make_tuple(count_increases(mes, 1), count_increases(mes, 3));
}

suite tests = [] {
  test("example") = [] {
    auto example = R"(199
200
208
210
200
207
240
269
260
263)";

    auto results = solve(example);

    expect(get<0>(results) == 7_i);
    expect(get<1>(results) == 5_i);
  };
};

int main(int argc, char* argv[]) {
  auto contents = get_input(argc, argv);
  if (!contents)
    return 1;

  auto results = solve(*contents);

  cout << "part one: " << get<0>(results) << "\n";
  cout << "part two: " << get<1>(results) << "\n";
}
