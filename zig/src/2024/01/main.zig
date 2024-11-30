//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !struct { p1: usize, p2: usize } {
    _ = allocator;
    _ = input;
    return .{ .p1 = 42, .p2 = 84 };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const answers = try solve(allocator, "");

    std.debug.print("Part 1: {d}\n", .{answers.p1});
    std.debug.print("Part 2: {d}\n", .{answers.p2});
}

test "simple test" {
    const answers = try solve(std.testing.allocator, "");

    try std.testing.expectEqual(@as(usize, 42), answers.p1);
    try std.testing.expectEqual(@as(usize, 84), answers.p2);
}
