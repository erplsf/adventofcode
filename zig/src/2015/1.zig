const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input = try aoc.readFile(allocator);
    defer allocator.free(input);

    const answer = try solve(input);
    std.log.info("The floor reached is: {d}", .{answer.part_1});
    std.log.info("Index when basement is reached: {d}", .{answer.part_2});
}

const Solution = aoc.Solution(isize, usize);

fn solve(path: []const u8) !Solution {
    var floor: isize = 0;
    var basement_index: usize = 0;
    for (path) |char, index| {
        floor += @as(isize, switch (char) {
            '(' => 1,
            ')' => -1,
            else => return aoc.AocError.InputParseProblem,
        });
        if (floor == -1 and basement_index == 0) basement_index = (index + 1);
    }
    return Solution{.part_1 = floor, .part_2 = basement_index};
}

test "Part 1" {
    try std.testing.expectEqual((solve("(())") catch unreachable).part_1, 0);
    try std.testing.expectEqual((solve("()()") catch unreachable).part_1, 0);
    try std.testing.expectEqual((solve("(((") catch unreachable).part_1, 3);
    try std.testing.expectEqual((solve("(()(()(") catch unreachable).part_1, 3);
    try std.testing.expectEqual((solve("))(((((") catch unreachable).part_1, 3);
    try std.testing.expectEqual((solve("())") catch unreachable).part_1, -1);
    try std.testing.expectEqual((solve("))(") catch unreachable).part_1, -1);
    try std.testing.expectEqual((solve("))(") catch unreachable).part_1, -1);
    try std.testing.expectEqual((solve(")))") catch unreachable).part_1, -3);
    try std.testing.expectEqual((solve(")())())") catch unreachable).part_1, -3);
}

test "Part 2" {
    try std.testing.expectEqual((solve(")") catch unreachable).part_2, 1);
    try std.testing.expectEqual((solve("()())") catch unreachable).part_2, 5);
}
