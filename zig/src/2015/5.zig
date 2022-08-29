const std = @import("std");
const aoc = @import("aoc");
const expectEqual = aoc.expectEqual;

pub const log_level: std.log.Level = .info; // always print info level messages and above (std.log.info is fast enough for our purposes)

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input = try aoc.readFile(allocator);
    defer allocator.free(input);

    const answer = try solve(input);
    std.log.info("Part 1: {d}", .{answer.part_1});
    std.log.info("Part 2: {d}", .{answer.part_2});
}

const Solution = aoc.Solution(usize, usize);

const vowels = [_][]const u8{"a", "e", "i", "o", "u"};
const forbidden = [_][]const u8{"ab", "cd", "pq", "xy"};

fn niceV1(input: []const u8) bool {
    // count vowels
    var vCount: usize = 0;
    for(vowels) |vowel| {
        vCount += std.mem.count(u8, input, vowel);
    }

    var i: usize = 0;
    var double = false;
    var has_forbidden = false;
    while (i < input.len - 1): (i += 1) {
        if (input[i] == input[i+1]) double = true;
        const input_pair = input[i..i+2];
        for (forbidden) |pair| {
            // std.debug.print("input: {s}, pair: {s}\n", .{input[i..i+2], pair});
            if (std.mem.eql(u8, input_pair, pair)) has_forbidden = true;
        }
    }

    // std.debug.print("vowels: {d}, double: {}, has_forbidden: {}\n", .{vCount, double, has_forbidden});

    return (vCount >= 3) and (double) and (!has_forbidden);
}

fn niceV2(input: []const u8) bool {
    var i: usize = 0;
    var p1 = false;
    var p2 = false;

    // part 1
    while(i < input.len-1): (i += 1) {
        const pair = input[i..i+2];
        if (std.mem.indexOfPos(u8, input, i+2, pair) orelse 0 > 0) p1 = true;
    }

    // part 2
    i = 0;
    while(i < input.len-2): (i += 1) {
        if (i+2 < input.len and input[i] == input[i+2]) p2 = true;
    }

    return p1 and p2;
}

fn solve(input: []const u8) !Solution {
    var part_1: usize = 0;
    var part_2: usize = 0;

    var it = std.mem.split(u8, input, "\n");
    while (it.next()) |line| {
        if (line.len == 0) break;
        if (niceV1(line)) part_1 += 1;
        if (niceV2(line)) part_2 += 1;
    }

    return Solution{.part_1 = part_1, .part_2 = part_2};
}

test "Part 1" {
    try expectEqual(true, niceV1("ugknbfddgicrmopn"));
    try expectEqual(true, niceV1("aaa"));
    try expectEqual(false, niceV1("jchzalrnumimnmhp"));
    try expectEqual(false, niceV1("haegwjzuvuyypxyu"));
    try expectEqual(false, niceV1("dvszwmarrgswjxmb"));
}

test "Part 2" {
    try expectEqual(true, niceV2("qjhvhtzxzqqjkmpb"));
    try expectEqual(true, niceV2("xxyxx"));
    try expectEqual(false, niceV2("uurcxstgmygtbstg"));
    try expectEqual(false, niceV2("ieodomkazucvgmuy"));
}
