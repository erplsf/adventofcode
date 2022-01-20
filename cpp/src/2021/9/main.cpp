#include <aoc/aoc.hpp>
#include <aoc/tdm.hpp>
#include <boost/container_hash/hash.hpp>
#include <boost/ut.hpp>
#include <string>
#include <unordered_map>

using namespace aoc;
using namespace std;
using namespace boost::ut;

bool lowest(tdm<uint>& map, rci point) {
  auto vals = map.neighbour_values(point);
  auto pval = map.map[point.r][point.c];
  return all_of(vals.begin(), vals.end(),
                [&](uint& val) { return pval < val; });
}

size_t size_basin(tdm<uint>& map, rci point) {
  vector<rci> npoints{point};

  auto size = npoints.size();
  for (size_t i = 0; i < size; i++) {
    for (auto&& np: map.neighbour_points(npoints[i])) {
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
    for (size_t r = 0; r < map.max_r; r++) {
      for (size_t c = 0; c < map.max_c; c++) {
        if (lowest(map, {r, c}))
          answer += map.map[r][c] + 1;
      }
    }
  } else {
    answer = 1;
    vector<uint> sizes;
    for (size_t r = 0; r < map.max_r; r++) {
      for (size_t c = 0; c < map.max_c; c++) {
        if (lowest(map, {r, c}))
          sizes.emplace_back(size_basin(map, {r, c}));
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

int main(int argc, char* argv[]) {
  auto contents = get_input(argc, argv);
  if (!contents)
    return 1;

  auto results = solve(*contents);

  cout << "part one: " << get<0>(results) << "\n";
  cout << "part two: " << get<1>(results) << "\n";
}
