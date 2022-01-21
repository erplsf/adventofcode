#include <aoc/aoc.hpp>
#include <aoc/tdm.hpp>
#include <boost/container_hash/hash.hpp>
#include <boost/ut.hpp>
#include <string>
#include <unordered_map>

using namespace aoc;
using namespace std;
using namespace boost::ut;

typedef unordered_map<pair<size_t, size_t>, bool,
                      boost::hash<pair<size_t, size_t>>>
    fm;

void flash_check(tdm<uint>& map, rci rc, fm& flashmap) {
  if (map.map[rc.r][rc.c] > 9 && !flashmap[{rc.r, rc.c}]) {
    flashmap[{rc.r, rc.c}] = true;
    auto points = map.neighbour_points({rc.r, rc.c}, true);
    for (auto&& p: points) {
      map.map[p.r][p.c]++;
      flash_check(map, p, flashmap);
    }
  }
}

size_t step(tdm<uint>& map) {
  fm flashmap;
  for (size_t r = 0; r < map.max_r; r++) {
    for (size_t c = 0; c < map.max_c; c++) {
      map.map[r][c]++;
      flash_check(map, {r, c}, flashmap);
    }
  }

  for (auto&& kv: flashmap) {
    map.map[kv.first.first][kv.first.second] = 0;
  }
  return flashmap.size();
}

string rep(tdm<uint> const& map) {
  string s;
  for (size_t r = 0; r < map.max_r; r++) {
    for (size_t c = 0; c < map.max_c; c++) {
      s += to_string(map.map[r][c]);
    }
    s += "\n";
  }
  return s;
}

auto sol(string input, bool second = false) {
  auto lines = split(input, '\n');
  tdm<uint> map;

  size_t mr = lines.size();
  size_t mc = lines[0].size();

  map.max_c = mc;
  map.max_r = mr;

  for (size_t r = 0; r < lines.size(); r++) {
    map.map.push_back(
        vector<uint>()); // TODO: refactor this to a struct / funccal
    for (auto&& c: lines[r]) {
      uint val = c - '0';
      map.map[r].emplace_back(val);
    }
  }

  uint answer = 0;

  if (!second) {
    for (size_t i = 0; i < 100; i++) {
      answer += step(map);
    }
  } else {
    auto map_size = map.max_c * map.max_r;
    size_t st = 0;
    while (true) {
      st++;
      if (map_size == step(map)) {
        answer = st;
        break;
      }
    }
  }

  return answer;
}

auto solve(string input) {
  auto p1 = sol(input);
  auto p2 = sol(input, true);

  return make_pair(p1, p2);
}

suite tests = [] {
  test("example") = [] {
    auto example = R"(5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526)";

    auto [p1, p2] = solve(example);

    expect(p1 == 1656_i);
    expect(p2 == 195_i);
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
