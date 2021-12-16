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
  uint version;
  uint type_id;
  uint l_type_id;
  uint sub_length;
  uint sub_count;
  variant<u_long, vector<packet>> data;
  u_long value; // stores final computed value
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

uint decode(const string &input, uint start, uint length) {
  return stoul(input.substr(start, length), nullptr, 2);
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
    pkt.value = stoul(out, nullptr, 2);
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
    // switch (pkt.type_id) {
    //   cases
    // }
  };

  return make_pair(pkt, i);
}

u_long sov(const packet &pkt) { // sum of versions
  u_long sum = 0;
  sum += pkt.version;
  if (auto val = get_if<vector<packet>>(&pkt.data))
    sum += accumulate(val->begin(), val->end(), 0,
                      [](u_long acc, packet pkt) { return acc + sov(pkt); });
  return sum;
}

auto solve(string input) {
  auto [pkt, read] = parse_packet(input);

  return make_pair(sov(pkt), 0);
}

suite tests = [] {
  test("example") = [] {
    pair<packet, uint> pair;
    packet pkt;
    // simplest case
    pair = parse_packet("D2FE28");
    pkt = pair.first;
    expect(pkt.version == 6_i);
    expect(pkt.type_id == 4_i);
    expect(get<u_long>(pkt.data) == 2021_i);

    // sub type 0
    pair = parse_packet("38006F45291200");
    pkt = pair.first;
    expect(pkt.version == 1_i);
    expect(pkt.type_id == 6_i);
    expect(pkt.l_type_id == 0_i);
    expect(pkt.sub_length == 27_i);
    expect(get<vector<packet>>(pkt.data).size() == 2);
    expect(get<u_long>(get<vector<packet>>(pkt.data)[0].data) == 10_i);
    expect(get<u_long>(get<vector<packet>>(pkt.data)[1].data) == 20_i);

    // sub type 1
    pair = parse_packet("EE00D40C823060");
    pkt = pair.first;
    expect(pkt.version == 7_i);
    expect(pkt.type_id == 3_i);
    expect(pkt.l_type_id == 1_i);
    expect(pkt.sub_count == 3_i);
    expect(get<vector<packet>>(pkt.data).size() == 3);
    expect(get<u_long>(get<vector<packet>>(pkt.data)[0].data) == 1_i);
    expect(get<u_long>(get<vector<packet>>(pkt.data)[1].data) == 2_i);
    expect(get<u_long>(get<vector<packet>>(pkt.data)[2].data) == 3_i);

    // sums
    pair = parse_packet("8A004A801A8002F478");
    pkt = pair.first;
    expect(sov(pkt) == 16_i);

    pair = parse_packet("620080001611562C8802118E34");
    pkt = pair.first;
    expect(sov(pkt) == 12_i);

    pair = parse_packet("C0015000016115A2E0802F182340");
    pkt = pair.first;
    expect(sov(pkt) == 23_i);

    pair = parse_packet("A0016C880162017C3686B18A3D4780");
    pkt = pair.first;
    expect(sov(pkt) == 31_i);
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
