#include <algorithm>
#include <aoc/aoc.hpp>
#include <boost/ut.hpp>
#include <unordered_map>

using namespace aoc;
using namespace std;
using namespace boost::ut;

// pair<string, string> solve(string, bool);

vector<uint> parse(string input) {
  vector<uint> crabs;
  auto parts = split(input, ',');
  for (auto &&crab : parts)
    crabs.emplace_back(stoul(crab));

  return crabs;
}

auto median(vector<uint> &v) {
  size_t n = v.size() / 2;
  nth_element(v.begin(), v.begin() + n, v.end());
  return v[n];
}

uint cost(uint d) { // arithmetic series
  // Sn = n/2[2a+(n-1) d]
  return d * (2 + (d - 1)) / 2;
}

static unordered_map<uint, uint> map{};

uint mcost(uint d) {
  uint c = map[d];
  if (c != 0)
    return c;
  else {
    auto ncost = cost(d);
    map[d] = ncost;
    return ncost;
  }
}

void pv(vector<uint> const &v) {
  cout << "[";
  for (uint i = 0; i < v.size(); i++) {
    if (i + 1 == v.size())
      cout << v[i];
    else
      cout << v[i] << ",";
  }
  cout << "]\n";
}

uint min(vector<uint> &v) {
  auto min = min_element(v.begin(), v.end());
  return v[distance(v.begin(), min)];
}

uint max(vector<uint> &v) {
  auto max = max_element(v.begin(), v.end());
  return v[distance(v.begin(), max)];
}

uint solve(vector<uint> crabs, bool p1) {
  if (p1) {
    auto med = median(crabs);
    uint cost = 0;
    for (auto crab : crabs)
      cost += abs((int)(crab - med));
    return cost;
  } else {
    vector<uint> costs;
    // cout << "size: " << costs.size() << "\n";
    // sort(crabs.begin(), crabs.end());
    auto mi = min(crabs);
    auto ma = max(crabs);
    for (uint i = mi; i < ma; i++) {
      uint sum = 0;
      for (uint ci = 0; ci < crabs.size(); ci++) {
        int d = abs((int)(i - crabs[ci]));
        // cout << "d: " << d << "\n";
        sum += mcost(d);
      }
      // cout << "i: " << i << "\n";
      costs.emplace_back(sum);
    }

    // cout << "costs:\n";
    // pv(costs);

    auto min = min_element(costs.begin(), costs.end());
    if (min == costs.end())
      return 0;

    return costs[distance(costs.begin(), min)];
  }
}

auto solve(string input) {
  auto inp = parse(input);
  auto p1 = solve(inp, true);
  auto p2 = solve(inp, false);

  return make_pair(p1, p2);
}

suite tests = [] {
  test("example") = [] {
    auto example = R"(16,1,2,0,4,2,7,1,2,14)";

    auto [p1, p2] = solve(example);

    expect(p1 == 37_i);
    expect(p2 == 168_i);
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
