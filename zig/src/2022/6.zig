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
    var i: usize = 0;

    const windowSize = 4;
    var firstUniqueIndex = while (i < input.len - windowSize) : (i += 1) {
        const window = input[i .. i + windowSize];
        if (try uniqueSlice(allocator, u8, window)) break i + windowSize;
    } else unreachable;

    i = 0;
    const secondWindowSize = 14;
    var secondUniqueIndex = while (i < input.len - secondWindowSize) : (i += 1) {
        const window = input[i .. i + secondWindowSize];
        if (try uniqueSlice(allocator, u8, window)) break i + secondWindowSize;
    } else unreachable;

    return Solution{ .part_1 = firstUniqueIndex, .part_2 = secondUniqueIndex };
}

fn uniqueSlice(allocator: Allocator, comptime T: type, slice: []const T) !bool {
    var hash = std.AutoHashMap(T, void).init(allocator);
    defer hash.deinit();
    for (slice) |elem| {
        if (hash.contains(elem)) return false;
        try hash.put(elem, {});
    }
    return true;
}

test "Part 1" {
    const allocator = std.testing.allocator;
    try expectEqual(5, (try solve(allocator, "bvwbjplbgvbhsrlpgdmjqwftvncz")).part_1);
    try expectEqual(6, (try solve(allocator, "nppdvjthqldpwncqszvftbrmjlhg")).part_1);
    try expectEqual(10, (try solve(allocator, "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg")).part_1);
    try expectEqual(11, (try solve(allocator, "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw")).part_1);
}

test "Part 2" {
    const allocator = std.testing.allocator;
    try expectEqual(19, (try solve(allocator, "mjqjpqmgbljsphdztnvjfqwrcgsmlb")).part_2);
    try expectEqual(23, (try solve(allocator, "bvwbjplbgvbhsrlpgdmjqwftvncz")).part_2);
    try expectEqual(23, (try solve(allocator, "nppdvjthqldpwncqszvftbrmjlhg")).part_2);
    try expectEqual(29, (try solve(allocator, "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg")).part_2);
    try expectEqual(26, (try solve(allocator, "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw")).part_2);
}
