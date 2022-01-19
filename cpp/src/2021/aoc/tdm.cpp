#include "tdm.hpp"

inline bool aoc::rc::operator==(const rc &lhs, const rc &rhs) {
  return lhs.r == rhs.r && lhs.c == rhs.c;
};
