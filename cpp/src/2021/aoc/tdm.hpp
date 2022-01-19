#ifndef TDM_H_
#define TDM_H_

#include <span>
#include <vector>

using namespace std;

namespace aoc {
template <typename V> struct tdm {
  typedef pair<int, int> rc;
  typedef pair<size_t, size_t> rci;

  vector<vector<V>> map;
  size_t max_r;
  size_t max_c;

  static constexpr rc CARDINAL[4] = {{-1, 0}, {0, -1}, {1, 0}, {0, 1}};

  static constexpr rc ALL[8] = {{-1, 0},  {0, -1}, {1, 0},  {0, 1},
                                {-1, -1}, {-1, 1}, {1, -1}, {1, 1}};

  vector<rci> neighbour_points(rci cr, bool diag = false) const {
    vector<rci> neigh;
    span<const rc> pairs;

    if (diag)
      pairs = span{ALL};
    else
      pairs = span{CARDINAL};

    for (auto pair : pairs) {
      int nr = pair.first + cr.first;
      int nc = pair.second + cr.second;
      if ((nr >= 0 && (size_t)nr < max_r) && (nc >= 0 && (size_t)nc < max_c))
        neigh.emplace_back(make_pair(nc, nr));
    }

    return neigh;
  }

  vector<V &> neighbour_values(rci cr, bool diag = false) const {
    vector<rci> points = neighbour_points(cr, diag);
    vector<V &> values;

    for (auto &&p : points)
      values.emplace_back(map[p.first][p.second]);

    return values;
  }
};
} // namespace aoc

#endif // TDM_H_
