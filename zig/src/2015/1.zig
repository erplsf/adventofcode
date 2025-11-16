const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn main() !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
}

fn solve(input: []const u8) struct { isize, usize } {
    var level: isize = 0;
    for (input) |c| {
        switch (c) {
            '(' => level += 1,
            ')' => level -= 1,
            else => unreachable,
        }
    }
    return .{ level, 0 };
}

test "part 1" {
    {
        const p1, _ = solve("(())");
        try std.testing.expectEqual(0, p1);
    }
    {
        const p1, _ = solve("()()");
        try std.testing.expectEqual(0, p1);
    }
    {
        const p1, _ = solve("(((");
        try std.testing.expectEqual(3, p1);
    }
    {
        const p1, _ = solve("(()(()(");
        try std.testing.expectEqual(3, p1);
    }
    {
        const p1, _ = solve("))(((((");
        try std.testing.expectEqual(3, p1);
    }
    {
        const p1, _ = solve("))(((((");
        try std.testing.expectEqual(3, p1);
    }
    {
        const p1, _ = solve("())");
        try std.testing.expectEqual(-1, p1);
    }
    {
        const p1, _ = solve("))(");
        try std.testing.expectEqual(-1, p1);
    }
    {
        const p1, _ = solve(")))");
        try std.testing.expectEqual(-3, p1);
    }
    {
        const p1, _ = solve(")())())");
        try std.testing.expectEqual(-3, p1);
    }
}
