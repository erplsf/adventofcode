const std = @import("std");

const Comparison = enum { Less, Greater };

const Position = struct {
    x: usize,
    y: usize,

    pub fn generateCompFn(
        comptime field: []const u8,
        comptime comp: Comparison,
    ) fn (void, Position, Position) bool {
        return struct {
            fn compare(context: void, a: Position, b: Position) bool {
                _ = context;
                return switch (comp) {
                    .Less => @field(a, field) < @field(b, field),
                    .Greater => @field(b, field) > @field(b, field),
                };
            }
        }.compare;
    }
};

const Wall = struct {
    pos: Position,
};

const Direction = enum { Up, Down, Left, Right };

fn findNextWall(allocator: std.mem.Allocator, p_pos: Position, direction: Direction, walls: []const Wall) !?Position {
    var matching_walls = std.ArrayListUnmanaged(Position){};
    defer matching_walls.deinit(allocator);

    for (walls) |wall| {
        switch (direction) {
            .Right => if (wall.pos.x > p_pos.x) try matching_walls.append(allocator, wall.pos),
            .Down => if (wall.pos.y > p_pos.y) try matching_walls.append(allocator, wall.pos),
            .Left => if (wall.pos.x < p_pos.x) try matching_walls.append(allocator, wall.pos),
            .Up => if (wall.pos.y < p_pos.y) try matching_walls.append(allocator, wall.pos),
        }
    }

    if (matching_walls.items.len > 0) {
        // FIXME: would be nice to have it more generic, but it didn't work out last time: https://discord.com/channels/605571803288698900/1316103959953539153
        return blk: switch (direction) {
            .Right => {
                const compFn = Position.generateCompFn("x", .Less);
                break :blk std.sort.min(Position, matching_walls.items, {}, compFn);
            },
            .Down => {
                const compFn = Position.generateCompFn("y", .Less);
                break :blk std.sort.min(Position, matching_walls.items, {}, compFn);
            },
            .Left => {
                const compFn = Position.generateCompFn("x", .Greater);
                break :blk std.sort.max(Position, matching_walls.items, {}, compFn);
            },
            .Up => {
                const compFn = Position.generateCompFn("y", .Greater);
                break :blk std.sort.max(Position, matching_walls.items, {}, compFn);
            },
        };
    } else {
        return null;
    }
}

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
                try walls.append(allocator, .{ .pos = .{ .x = x, .y = y } });
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

    const wall = try findNextWall(allocator, .{ .x = px, .y = py }, pd, walls.items);
    std.debug.print("wall: {?}\n", .{wall});

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
