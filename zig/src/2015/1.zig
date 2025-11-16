const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn main() !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
}

fn solve(allocator: Allocator, input: []const u8) !struct { usize, usize } {
    _ = allocator;
    _ = input;
    return .{ 0, 0 };
}

test {
    const allocator = std.testing.allocator;
    const p1, _ = try solve(allocator, "(())");
    try std.testing.expectEqual(p1, 0);
}
