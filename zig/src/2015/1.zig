const std = @import("std");

const input = @embedFile("./../../../inputs/2015/1.txt");

pub fn main() anyerror!void {
    const answer = count(input);
    std.log.info("The floor reached is: {d}", .{answer.floor});
    std.log.info("Index when basement is reached: {d}", .{answer.index});
}

const Answer = struct {
    floor: isize,
    index: usize,
};

fn count(path: []const u8) Answer {
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
    return .{.floor = floor, .index = basement_index};
}

test "description tests" {
    // Part 1
    try std.testing.expectEqual(count("(())").floor, 0);
    try std.testing.expectEqual(count("()()").floor, 0);
    try std.testing.expectEqual(count("(((").floor, 3);
    try std.testing.expectEqual(count("(()(()(").floor, 3);
    try std.testing.expectEqual(count("))(((((").floor, 3);
    try std.testing.expectEqual(count("())").floor, -1);
    try std.testing.expectEqual(count("))(").floor, -1);
    try std.testing.expectEqual(count("))(").floor, -1);
    try std.testing.expectEqual(count(")))").floor, -3);
    try std.testing.expectEqual(count(")())())").floor, -3);

    // Part 2
    try std.testing.expectEqual(count(")").index, 1);
    try std.testing.expectEqual(count("()())").index, 5);
}
