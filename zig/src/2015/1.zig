const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn main() !void {
    var alloc: std.heap.DebugAllocator(.{}) = .init;
    const allocator = alloc.allocator();
    var threaded = std.Io.Threaded.init(allocator);
    defer threaded.deinit();
    const io = threaded.io();
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    _ = args.next();
    const maybe_filepath = args.next();
    if (maybe_filepath) |filepath| {
        const file: std.fs.File = try std.fs.cwd().openFile(filepath, .{});
        defer file.close();

        var read_buffer: [4096]u8 = undefined;
        var file_reader = file.reader(io, &read_buffer);
        const reader = &file_reader.interface;

        var writer = std.Io.Writer.Allocating.init(allocator);
        defer writer.deinit();

        _ = try reader.streamRemaining(&writer.writer);

        const p1, const p2 = solve(writer.written());

        std.debug.print("Part 1: {d}\n", .{p1});
        std.debug.print("Part 2: {d}\n", .{p2});
    }
}

fn solve(input: []const u8) struct { isize, usize } {
    var level: isize = 0;
    var first_basement_entrance: usize = 0;
    for (input, 1..) |c, position| {
        switch (c) {
            '(' => level += 1,
            ')' => level -= 1,
            else => unreachable,
        }
        if (first_basement_entrance == 0 and level == -1) {
            first_basement_entrance = position;
        }
    }
    return .{ level, first_basement_entrance };
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

test "part 2" {
    {
        _, const p2 = solve(")");
        try std.testing.expectEqual(1, p2);
    }
    {
        _, const p2 = solve("()())");
        try std.testing.expectEqual(5, p2);
    }
}
