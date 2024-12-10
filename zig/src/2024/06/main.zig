const std = @import("std");

const Wall = struct {
    x: usize,
    y: usize,
};

const Direction = enum { Up, Down, Left, Right };

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !struct { p1: usize, p2: usize } {
    var line_it = std.mem.splitScalar(u8, input, '\n');

    var walls = std.ArrayListUnmanaged(Wall){};
    defer walls.deinit(allocator);

    var y: usize = 0;
    var x: usize = 0;
    var px: usize = undefined;
    var py: usize = undefined;
    var pd: Direction = undefined;
    while (line_it.next()) |line| {
        for (line) |char| {
            if (char == '#') {
                try walls.append(allocator, .{ .x = x, .y = y });
            } else if (char == '>' or char == 'v' or char == '<' or char == '^') {
                switch (char) {
                    '>' => pd = .Right,
                    'v' => pd = .Down,
                    '<' => pd = .Left,
                    '^' => pd = .Up,
                    else => unreachable,
                }
                px = x;
                py = y;
            }
            x += 1;
        }
        y += 1;
    }

    std.debug.print("walls: {any}\n", .{walls.items});
    return .{ .p1 = 0, .p2 = 0 };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const path = try std.fs.realpathAlloc(allocator, args[1]);
    defer allocator.free(path);

    const file = try std.fs.openFileAbsolute(path, .{ .mode = .read_only });
    defer file.close();

    const size = (try file.stat()).size;
    const buffer = try allocator.alloc(u8, size);
    defer allocator.free(buffer);

    try file.reader().readNoEof(buffer);

    const answers = try solve(allocator, buffer);

    std.debug.print("Part 1: {d}\n", .{answers.p1});
    std.debug.print("Part 2: {d}\n", .{answers.p2});
}

test "simple test" {
    const input =
        \\....#.....
        \\.........#
        \\..........
        \\..#.......
        \\.......#..
        \\..........
        \\.#..^.....
        \\........#.
        \\#.........
        \\......#...
    ;
    const answers = try solve(std.testing.allocator, input);
    try std.testing.expectEqual(@as(usize, 41), answers.p1);
    try std.testing.expectEqual(@as(usize, 0), answers.p2);
}
