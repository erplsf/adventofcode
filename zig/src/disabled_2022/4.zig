const std = @import("std");
const aoc = @import("aoc");
const expectEqual = aoc.expectEqual;
const Allocator = std.mem.Allocator;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit()) @panic("memory leak!");
    const allocator = gpa.allocator();

    const input = try aoc.readFile(allocator);
    defer allocator.free(input);

    const answer = try solve(input, allocator);
    aoc.print("Part 1: {d}\n", .{answer.part_1});
    aoc.print("Part 2: {d}\n", .{answer.part_2});
}

const Solution = aoc.Solution(usize, usize);

fn solve(input: []const u8, allocator: std.mem.Allocator) !Solution {
    _ = allocator;
    var lineIt = std.mem.split(u8, input, "\n");

    var containsCount: usize = 0;
    var overlapsCount: usize = 0;
    var pair: [2][2]usize = undefined;
    while (lineIt.next()) |line| {
        if (line.len == 0) continue;
        var elfIt = std.mem.split(u8, line, ",");
        var firstElf = elfIt.next().?;
        var secondElf = elfIt.next().?;

        var fElfIt = std.mem.split(u8, firstElf, "-");
        pair[0][0] = try std.fmt.parseUnsigned(usize, fElfIt.next().?, 10);
        pair[0][1] = try std.fmt.parseUnsigned(usize, fElfIt.next().?, 10);

        var sElfIt = std.mem.split(u8, secondElf, "-");
        pair[1][0] = try std.fmt.parseUnsigned(usize, sElfIt.next().?, 10);
        pair[1][1] = try std.fmt.parseUnsigned(usize, sElfIt.next().?, 10);

        // try stderr.print("first: {d}-{d}, second: {d}-{d}\n", .{ pair[0][0], pair[0][1], pair[1][0], pair[1][1] });

        var lowerIndex: usize = if (pair[0][0] < pair[1][0]) 0 else 1;
        var nextIndex = (lowerIndex + 1) % 2;

        var contains = if (pair[0][0] == pair[1][0] or pair[0][1] == pair[1][1]) true else blk: {
            if (pair[lowerIndex][1] >= pair[nextIndex][1]) break :blk true else break :blk false;
        };

        var overlaps = if (contains) true else blk: {
            if (pair[lowerIndex][1] >= pair[nextIndex][0]) break :blk true else break :blk false;
        };

        if (contains) containsCount += 1;
        if (overlaps) overlapsCount += 1;
    }

    return Solution{ .part_1 = containsCount, .part_2 = overlapsCount };
}

const test_input =
    \\2-4,6-8
    \\2-3,4-5
    \\5-7,7-9
    \\2-8,3-7
    \\6-6,4-6
    \\2-6,4-8
;

test "Part 1" {
    const allocator = std.testing.allocator;
    try expectEqual(2, (try solve(test_input, allocator)).part_1);
}

test "Part 2" {
    const allocator = std.testing.allocator;
    try expectEqual(4, (try solve(test_input, allocator)).part_2);
}
