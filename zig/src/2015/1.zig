const std = @import("std");

// TODO: switch to reading file from a file
const input = @embedFile("./../../../inputs/2015/1.txt");

pub fn main() !void {
    const answer = solve(input);
    std.log.info("The floor reached is: {d}", .{answer.part_1});
    std.log.info("Index when basement is reached: {d}", .{answer.part_2});
}

const Solution = struct {
    part_1: isize,
    part_2: usize,
};

fn solve(path: []const u8) Solution {
    var floor: isize = 0;
    var basement_index: usize = 0;
    for (path) |char, index| {
        floor += @as(isize, switch (char) {
            '(' => 1,
            ')' => -1,
            else => unreachable,
        });
        if (floor == -1 and basement_index == 0) basement_index = (index + 1);
    }
    return .{.part_1 = floor, .part_2 = basement_index};
}

test "Part 1" {
    try std.testing.expectEqual(solve("(())").part_1, 0);
    try std.testing.expectEqual(solve("()()").part_1, 0);
    try std.testing.expectEqual(solve("(((").part_1, 3);
    try std.testing.expectEqual(solve("(()(()(").part_1, 3);
    try std.testing.expectEqual(solve("))(((((").part_1, 3);
    try std.testing.expectEqual(solve("())").part_1, -1);
    try std.testing.expectEqual(solve("))(").part_1, -1);
    try std.testing.expectEqual(solve("))(").part_1, -1);
    try std.testing.expectEqual(solve(")))").part_1, -3);
    try std.testing.expectEqual(solve(")())())").part_1, -3);
}

test "Part 2" {
    try std.testing.expectEqual(solve(")").part_2, 1);
    try std.testing.expectEqual(solve("()())").part_2, 5);
}
