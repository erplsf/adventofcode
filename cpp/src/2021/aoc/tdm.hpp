#ifndef TDM_H_
#define TDM_H_

#include <iostream>
#include <span>
#include <vector>

using namespace std;

namespace aoc {

struct rci {
  size_t r; // row
  size_t c; // column
};

struct rc {
  int r; // row
  int c; // column

  inline bool operator==(const rc &rhs);
};

template <typename V> struct tdm {
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
      int nr = pair.r + cr.r;
      int nc = pair.c + cr.c;
      if ((nr >= 0 && (size_t)nr < max_r) && (nc >= 0 && (size_t)nc < max_c))
        neigh.emplace_back(make_pair(nc, nr));
    }

    return neigh;
  }

  vector<reference_wrapper<V>> neighbour_values(rci cr, bool diag = false) {
    vector<rci> points = neighbour_points(cr, diag);
    vector<reference_wrapper<V>> values;

    for (auto &&p : points) {
      values.emplace_back(ref(map[p.r][p.c]));
    }

    return values;
  }
};
} // namespace aoc

#endif // TDM_H_
