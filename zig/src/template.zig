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

const Solution = aoc.Solution(void, void);

fn solve(input: []const u8) !Solution {
    _ = input;
    return Solution{.part_1 = {}, .part_2 = {}};
}

test "Part 1" {
}

test "Part 2" {
}
