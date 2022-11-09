const std = @import("std");
const aoc = @import("aoc");
const expectEqual = aoc.expectEqual;
const Allocator = std.mem.Allocator;

pub const log_level: std.log.Level = .info; // always print info level messages and above (std.log.info is fast enough for our purposes)
// const stdout = std.io.getStdOut.writer();

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

fn solve(input: []const u8) Solution {
    _ = input;
    return Solution{ .part_1 = 0, .part_2 = 0 };
}

test "Part 1" {
    try expectEqual(0, solve("").part_1);
}

test "Part 2" {
    try expectEqual(0, solve("").part_2);
}
