#include <aoc/aoc.hpp>
#include <aoc/tdm.hpp>
#include <boost/container_hash/hash.hpp>
#include <boost/ut.hpp>
#include <string>
#include <unordered_map>

using namespace aoc;
using namespace std;
using namespace boost::ut;

bool lowest(tdm<uint> &map, rci point) {
  auto vals = map.neighbour_values(point);
  auto point_val = map.map[point.r][point.c];
  // fmt::print("p: {}\n", point);
  // fmt::print("pv: {}\n", point_val);
  // fmt::print("nei: {}\n", neigh);
  // fmt::print("vals: {}\n", vals);
  return all_of(vals.begin(), vals.end(),
                [&](uint &val) { return point_val < val; });
}

uint size_basin(tdm<uint> &map, rci point) {
  // fmt::print("p: {}\n", point);
  vector<rci> npoints{point};

  auto size = npoints.size();
  for (size_t i = 0; i < size; i++) {
    auto nn = map.neighbour_points(npoints[i]);
    for (rci np : nn) {
      if (map.map[np.r][np.c] != 9 && // not a basin
          find(npoints.begin(), npoints.end(), np) ==
              npoints.end() // first time finding this point
      ) {
        npoints.emplace_back(np);
        size++;
      }
    }
  }
  return npoints.size();
}

auto sol(string input, bool second = false) {
  auto lines = split(input, '\n');
  tdm<uint> map;
  // uint mh = lines.size();
  // uint mw = lines[0].size();
  uint h = 0;
  uint w = 0;

  for (auto &&line : lines) {
    w = 0;
    map.map.push_back(vector<uint>());
    for (char c : line) {
      uint val = c - '0';
      map.map[h].emplace_back(val);
      w++;
    }
    h++;
  }

  map.max_c = w;
  map.max_r = h;

  uint answer = 0;
  if (!second) {
    for (size_t r = 0; r < map.max_r; r++) {
      for (size_t c = 0; c < map.max_c; c++) {
        if (lowest(map, {r, c})) {
          // fmt::print("point: {}, value: {}\n", it.first, it.second);
          answer += map.map[r][c] + 1;
        }
      }
    }
  } else {
    answer = 1;
    vector<uint> sizes;
    for (size_t r = 0; r < map.max_r; r++) {
      for (size_t c = 0; c < map.max_c; c++) {
        if (lowest(map, {r, c})) {
          sizes.emplace_back(size_basin(map, {r, c}));
        }
      }
    }
    sort(sizes.begin(), sizes.end());
    auto it = sizes.rbegin();
    for (auto i = 0; i < 3; i++) {
      answer *= *it;
      it++;
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
    auto example =
        R"(2199943210
3987894921
9856789892
8767896789
9899965678)";

    auto [p1, p2] = solve(example);

    expect(p1 == 15_i);
    expect(p2 == 1134_i);
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
