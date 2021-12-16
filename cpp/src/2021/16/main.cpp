#include <algorithm>
#include <aoc/aoc.hpp>
#include <boost/ut.hpp>
#include <numeric>
#include <string>
#include <unordered_map>
#include <variant>

using namespace aoc;
using namespace std;
using namespace boost::ut;

struct packet {
  uint64_t version;
  uint64_t type_id;
  uint64_t l_type_id;
  uint64_t sub_length;
  uint64_t sub_count;
  variant<uint64_t, vector<packet>> data;
  uint64_t value; // stores final computed value
};

string htob(char c) {
  switch (toupper(c)) {
  case '0':
    return "0000";
  case '1':
    return "0001";
  case '2':
    return "0010";
  case '3':
    return "0011";
  case '4':
    return "0100";
  case '5':
    return "0101";
  case '6':
    return "0110";
  case '7':
    return "0111";
  case '8':
    return "1000";
  case '9':
    return "1001";
  case 'A':
    return "1010";
  case 'B':
    return "1011";
  case 'C':
    return "1100";
  case 'D':
    return "1101";
  case 'E':
    return "1110";
  case 'F':
    return "1111";
  };
  return "";
}

string convert(const string input) {
  string out;
  for (auto &&c : input) {
    out += htob(c);
  }
  return out;
}

uint64_t decode(const string &input, uint64_t start, uint64_t length) {
  return stoull(input.substr(start, length), nullptr, 2);
}

pair<packet, uint> parse_packet(const string input, bool need_decode = true) {
  string dcd;
  if (need_decode)
    dcd = convert(input);
  else
    dcd = input;

  // cout << "decoded: " << dcd << "\n";
  size_t i = 0;
  packet pkt;

  pkt.version = decode(dcd, i, 3);
  i += 3;

  pkt.type_id = decode(dcd, i, 3);
  i += 3;

  if (pkt.type_id == 4) { // literal packet, raw number comes next
    string out;
    bool should_stop;
    while (true) {
      if (dcd[i] == '0') // last loop, stop after processing
        should_stop = true;
      out += dcd.substr(i + 1, 4);
      i += 5; // move over to next flag bit
      if (should_stop)
        break;
    }; // continue while not the last packet
    // cout << "val: " << out << "\n";
    pkt.value = stoull(out, nullptr, 2);
    pkt.data = pkt.value;
  } else { // operator type
    pkt.l_type_id = decode(dcd, i, 1);
    i++;
    vector<packet> sub_packets;

    if (pkt.l_type_id == 0) { // length in bits
      pkt.sub_length = decode(dcd, i, 15);
      i += 15;

      auto length_left = pkt.sub_length;
      while (length_left > 0) {
        auto [packet, read] = parse_packet(dcd.substr(i), false);
        i += read;
        length_left -= read;
        sub_packets.emplace_back(packet);
      }

    } else if (pkt.l_type_id == 1) { // count
      pkt.sub_count = decode(dcd, i, 11);
      i += 11;

      auto count_left = pkt.sub_count;
      while (count_left > 0) {
        auto [packet, read] = parse_packet(dcd.substr(i), false);
        i += read;
        count_left--;
        sub_packets.emplace_back(packet);
      }
    };

    pkt.data = sub_packets;

    // now we can compute the value
    switch (pkt.type_id) {
    case 0: {
      auto sp = get<vector<packet>>(pkt.data);
      pkt.value =
          accumulate(sp.begin(), sp.end(), 0ull,
                     [](uint64_t acc, packet pkt) { return acc + pkt.value; });
      break;
    }
    case 1: {
      auto sp = get<vector<packet>>(pkt.data);
      pkt.value =
          accumulate(sp.begin(), sp.end(), 1ull,
                     [](uint64_t acc, packet pkt) { return acc * pkt.value; });
      break;
    }
    case 2: {
      auto sp = get<vector<packet>>(pkt.data);
      auto r =
          min_element(sp.begin(), sp.end(), [](const packet a, const packet b) {
            return a.value < b.value;
          });
      pkt.value = sp[distance(sp.begin(), r)].value;
      break;
    }
    case 3: {
      auto sp = get<vector<packet>>(pkt.data);
      auto r =
          max_element(sp.begin(), sp.end(), [](const packet a, const packet b) {
            return a.value < b.value;
          });
      pkt.value = sp[distance(sp.begin(), r)].value;
      break;
    }
    case 5: {
      auto sp = get<vector<packet>>(pkt.data);
      if (sp[0].value > sp[1].value)
        pkt.value = 1;
      else
        pkt.value = 0;

      break;
    }
    case 6: {
      auto sp = get<vector<packet>>(pkt.data);
      if (sp[0].value < sp[1].value)
        pkt.value = 1;
      else
        pkt.value = 0;

      break;
    }
    case 7: {
      auto sp = get<vector<packet>>(pkt.data);
      if (sp[0].value == sp[1].value)
        pkt.value = 1;
      else
        pkt.value = 0;

      break;
    }
    }
  };

  return make_pair(pkt, i);
}

uint64_t sov(const packet &pkt) { // sum of versions
  uint64_t sum = 0;
  sum += pkt.version;
  if (auto val = get_if<vector<packet>>(&pkt.data))
    sum += accumulate(val->begin(), val->end(), 0,
                      [](uint64_t acc, packet pkt) { return acc + sov(pkt); });
  return sum;
}

string ttc(uint64_t type) {
  switch (type) {
  case 0:
    return "+";
  case 1:
    return "*";
  case 2:
    return "min";
  case 3:
    return "max";
  case 5:
    return ">";
  case 6:
    return "<";
  case 7:
    return "=";
  }
  return "";
}

void ppv(const packet &pkt) {
  if (pkt.type_id == 4)
    cout << " " << pkt.value;

  cout << ttc(pkt.type_id);

  if (auto val = get_if<vector<packet>>(&pkt.data)) {
    cout << "(";
    for (auto p : *val)
      ppv(p);
    cout << ")";
  };
}

auto solve(string input) {
  auto [pkt, read] = parse_packet(input);

  // ppv(pkt);
  // cout << "\n";

  return make_pair(sov(pkt), pkt.value);
}

suite tests = [] {
  test("example") = [] {
    packet pkt;
    // simplest case
    pkt = parse_packet("D2FE28").first;
    expect(pkt.version == 6_i);
    expect(pkt.type_id == 4_i);
    expect(get<uint64_t>(pkt.data) == 2021_i);

    // sub type 0
    pkt = parse_packet("38006F45291200").first;
    expect(pkt.version == 1_i);
    expect(pkt.type_id == 6_i);
    expect(pkt.l_type_id == 0_i);
    expect(pkt.sub_length == 27_i);
    expect(get<vector<packet>>(pkt.data).size() == 2);
    expect(get<uint64_t>(get<vector<packet>>(pkt.data)[0].data) == 10_i);
    expect(get<uint64_t>(get<vector<packet>>(pkt.data)[1].data) == 20_i);

    // sub type 1
    pkt = parse_packet("EE00D40C823060").first;
    expect(pkt.version == 7_i);
    expect(pkt.type_id == 3_i);
    expect(pkt.l_type_id == 1_i);
    expect(pkt.sub_count == 3_i);
    expect(get<vector<packet>>(pkt.data).size() == 3);
    expect(get<uint64_t>(get<vector<packet>>(pkt.data)[0].data) == 1_i);
    expect(get<uint64_t>(get<vector<packet>>(pkt.data)[1].data) == 2_i);
    expect(get<uint64_t>(get<vector<packet>>(pkt.data)[2].data) == 3_i);

    // sums
    pkt = parse_packet("8A004A801A8002F478").first;
    expect(sov(pkt) == 16_i);

    pkt = parse_packet("620080001611562C8802118E34").first;
    expect(sov(pkt) == 12_i);

    pkt = parse_packet("C0015000016115A2E0802F182340").first;
    expect(sov(pkt) == 23_i);

    pkt = parse_packet("A0016C880162017C3686B18A3D4780").first;
    expect(sov(pkt) == 31_i);

    // operations
    pkt = parse_packet("C200B40A82").first;
    expect(pkt.value == 3_i);

    pkt = parse_packet("04005AC33890").first;
    expect(pkt.value == 54_i);

    pkt = parse_packet("880086C3E88112").first;
    expect(pkt.value == 7_i);

    pkt = parse_packet("CE00C43D881120").first;
    expect(pkt.value == 9_i);

    pkt = parse_packet("D8005AC2A8F0").first;
    expect(pkt.value == 1_i);

    pkt = parse_packet("F600BC2D8F").first;
    expect(pkt.value == 0_i);

    pkt = parse_packet("9C005AC2F8F0").first;
    expect(pkt.value == 0_i);

    pkt = parse_packet("9C0141080250320F1802104A08").first;
    expect(pkt.value == 1_i);
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
