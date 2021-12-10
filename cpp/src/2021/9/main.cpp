#include <aoc/aoc.hpp>
#include <boost/container_hash/hash.hpp>
#include <boost/ut.hpp>
#include <string>
#include <unordered_map>

using namespace aoc;
using namespace std;
using namespace boost::ut;

typedef pair<uint, uint> xy;
typedef unordered_map<xy, uint, boost::hash<xy>> u_map;

struct m {
  u_map map;
  uint mx = 0;
  uint my = 0;
};

vector<xy> neighbors(xy point, uint mx, uint my, bool diag = false) {
  vector<xy> neigh;
  vector<xy> pairs;
  if (!diag)
    pairs = {{-1, 0}, {0, -1}, {1, 0}, {0, 1}};
  else
    pairs = {{-1, 0},  {0, -1}, {1, 0},  {0, 1},
             {-1, -1}, {-1, 1}, {1, -1}, {1, 1}};

  for (auto pair : pairs) {
    int nx = pair.first + point.first;
    int ny = pair.second + point.second;
    if ((nx >= 0 && (uint)nx < mx) && (ny >= 0 && (uint)ny < my))
      neigh.emplace_back(make_pair(nx, ny));
  }

  return neigh;
}

vector<uint> fetch(u_map &map, vector<xy> points) {
  vector<uint> v;
  for (auto point : points) {
    v.emplace_back(map[point]);
  }
  return v;
}

bool lowest(m &map, xy point) {
  auto neigh = neighbors(point, map.mx, map.my);
  auto vals = fetch(map.map, neigh);
}

auto sol(string input) {
  auto lines = split(input, '\n');
  m map;
  // uint mh = lines.size();
  // uint mw = lines[0].size();
  uint h = 0;
  uint w = 0;
  for (auto &&line : lines) {
    for (char c : line) {
      uint val = atoi(&c);
      map.map[make_pair(h, w)] = val;
      w++;
    }
    h++;
  }
  return 0;
}

auto solve(string input) {
  auto p1 = sol(input);
  auto p2 = sol(input);

  return make_pair(p1, p2);
}

suite tests = [] {
  test("example") = [] {
    auto example =
        R"(2199943210
3987894921
9856789892
8767896789
9899965678)";

    auto [p1, p2] = solve(example);

    expect(p1 == 15_i);
    expect(p2 == 15_i);
  };
};

int main(int argc, char *argv[]) {
  auto contents = get_input(argc, argv);
  if (!contents)
    return 1;

  auto results = solve(*contents);

  cout << "part one: " << get<0>(results) << "\n";
  cout << "part two: " << get<1>(results) << "\n";
}
