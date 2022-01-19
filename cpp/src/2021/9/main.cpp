#include <aoc/aoc.hpp>
#include <aoc/tdm.hpp>
#include <boost/container_hash/hash.hpp>
#include <boost/ut.hpp>
#include <string>
#include <unordered_map>

using namespace aoc;
using namespace std;
using namespace boost::ut;

typedef pair<uint, uint> yx;
typedef unordered_map<yx, uint, boost::hash<yx>> u_map;

struct m {
  u_map map;
  uint mx = 0;
  uint my = 0;
};

vector<yx> neighbors(yx point, uint mx, uint my, bool diag = false) {
  vector<yx> neigh;
  vector<yx> pairs;
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

vector<uint> fetch(u_map &map, vector<yx> points) {
  vector<uint> v;
  for (auto point : points) {
    v.emplace_back(map[point]);
  }
  return v;
}

bool lowest(m &map, yx point) {
  auto neigh = neighbors(point, map.mx, map.my);
  auto point_val = map.map[point];
  // fmt::print("p: {}\n", point);
  // fmt::print("pv: {}\n", point_val);
  // fmt::print("nei: {}\n", neigh);
  auto vals = fetch(map.map, neigh);
  // fmt::print("vals: {}\n", vals);
  return all_of(vals.begin(), vals.end(),
                [&](uint val) { return point_val < val; });
}

uint size_basin(m &map, yx point) {
  // fmt::print("p: {}\n", point);
  vector<yx> npoints{point};

  auto size = npoints.size();
  for (size_t i = 0; i < size; i++) {
    auto nn = neighbors(npoints[i], map.mx, map.my);
    for (auto &&np : nn) {
      if (map.map[np] != 9 && // not a basin
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
  m map;
  // uint mh = lines.size();
  // uint mw = lines[0].size();
  uint h = 0;
  uint w = 0;
  for (auto &&line : lines) {
    w = 0;
    for (char c : line) {
      uint val = c - '0';
      map.map[make_pair(h, w)] = val;
      w++;
    }
    h++;
  }

  map.mx = h;
  map.my = w;

  uint answer = 0;
  if (!second) {
    for (auto &&it : map.map) {
      if (lowest(map, it.first)) {
        // fmt::print("point: {}, value: {}\n", it.first, it.second);
        answer += it.second + 1;
      }
    }
  } else {
    answer = 1;
    vector<uint> sizes;
    for (auto &&it : map.map) {
      if (lowest(map, it.first)) {
        sizes.emplace_back(size_basin(map, it.first));
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
