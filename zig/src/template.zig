const std = @import("std");
const aoc = @import("aoc");
const expectEqual = aoc.expectEqual;
const assert = std.testing.assert;
const Allocator = std.mem.Allocator;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit()) @panic("memory leak!");
    const allocator = gpa.allocator();

    const input = try aoc.readFile(allocator);
    defer allocator.free(input);

    const answer = try solve(allocator, input);
    aoc.print("Part 1: {d}\n", .{answer.part_1});
    aoc.print("Part 2: {d}\n", .{answer.part_2});
}

const Solution = aoc.Solution(usize, usize);

fn solve(allocator: Allocator, input: []const u8) !Solution {
    _ = allocator;
    _ = input;
    return Solution{ .part_1 = 0, .part_2 = 0 };
}

const testing_input =
    \\
;

test "Part 1" {
    const allocator = std.testing.allocator;
    try expectEqual(0, (try solve(allocator, testing_input)).part_1);
}

test "Part 2" {
    const allocator = std.testing.allocator;
    try expectEqual(0, (try solve(allocator, testing_input)).part_1);
}
