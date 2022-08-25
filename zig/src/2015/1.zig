const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const input = try readFile(allocator);
    defer allocator.free(input);

    const answer = try solve(input);
    std.log.info("The floor reached is: {d}", .{answer.part_1});
    std.log.info("Index when basement is reached: {d}", .{answer.part_2});
}

const Solution = struct {
    part_1: isize,
    part_2: usize,
};

const AocError = error{
    NoArgumentProvided,
    InputParseProblem,
};

fn readFile(allocator: std.mem.Allocator) ![]const u8 {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    if (args.len > 1) {
        const path = try std.fs.realpathAlloc(allocator, args[1]);
        defer allocator.free(path);

        const file = try std.fs.openFileAbsolute(path, .{});
        defer file.close();

        const size = (try file.stat()).size;
        const buffer = try allocator.alloc(u8, size);
        try file.reader().readNoEof(buffer);

        return buffer;
    }
    return AocError.NoArgumentProvided;
}

fn solve(path: []const u8) !Solution {
    var floor: isize = 0;
    var basement_index: usize = 0;
    for (path) |char, index| {
        floor += @as(isize, switch (char) {
            '(' => 1,
            ')' => -1,
            else => return AocError.InputParseProblem,
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
