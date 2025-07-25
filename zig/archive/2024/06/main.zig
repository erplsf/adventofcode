const std = @import("std");

const Comparison = enum { Less, Greater };

pub inline fn diff(a: usize, b: usize) usize {
    return @max(a, b) - @min(a, b);
}

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
            .Right => if (wall.pos.x > p_pos.x and wall.pos.y == p_pos.y) try matching_walls.append(allocator, wall.pos),
            .Down => if (wall.pos.y > p_pos.y and wall.pos.x == p_pos.x) try matching_walls.append(allocator, wall.pos),
            .Left => if (wall.pos.x < p_pos.x and wall.pos.y == p_pos.y) try matching_walls.append(allocator, wall.pos),
            .Up => if (wall.pos.y < p_pos.y and wall.pos.x == p_pos.x) try matching_walls.append(allocator, wall.pos),
        }
    }

    const compFn = Position.generateCompFn("x", .Less);

    if (matching_walls.items.len > 0) {
        // FIXME: would be nice to have it more generic, but it didn't work out last time: https://discord.com/channels/605571803288698900/1316103959953539153
        return switch (direction) {
            .Right, .Down => std.sort.min(Position, matching_walls.items, {}, compFn),
            .Left, .Up => std.sort.max(Position, matching_walls.items, {}, compFn),
        };
    } else {
        return null;
    }
}

pub inline fn isizyfy(v: usize) isize {
    return @as(isize, @intCast(v));
}

const Segment = struct {
    start_pos: Position,
    end_pos: Position,
    length: usize,

    pub fn distance(a: Position, b: Position) usize {
        return @max(a.x, b.x) - @min(a.x, b.x) + @max(a.y, b.y) - @min(a.y, b.y);
    }

    fn ccw(a: Position, b: Position, c: Position) bool {
        return ((isizyfy(c.y) - isizyfy(a.y)) * (isizyfy(b.x) - isizyfy(a.x))) > ((isizyfy(b.y) - isizyfy(a.y)) * (isizyfy(c.x) - isizyfy(a.x)));
    }

    pub fn intersects(a: Segment, b: Segment) bool {
        return ccw(a.start_pos, b.start_pos, b.end_pos) != ccw(a.end_pos, b.start_pos, b.end_pos) and ccw(a.start_pos, a.end_pos, b.start_pos) != ccw(a.start_pos, a.end_pos, b.end_pos);
        // const s_1: isize = @as(isize, @intCast(a.end_pos.x)) - @as(isize, @intCast(a.start_pos.x));
        // const t_1: isize = @as(isize, @intCast(b.end_pos.x)) - @as(isize, @intCast(b.start_pos.x));

        // const s_2: isize = @as(isize, @intCast(a.end_pos.y)) - @as(isize, @intCast(a.start_pos.y));
        // const t_2: isize = @as(isize, @intCast(b.end_pos.y)) - @as(isize, @intCast(b.end_pos.y));

        // // const c_1: isize = @as(isize, @intCast(b.start_pos.x)) - @as(isize, @intCast(a.start_pos.x));
        // // const c_2: isize = @as(isize, @intCast(b.start_pos.y)) - @as(isize, @intCast(a.start_pos.y));

        // const d: isize = s_1 * t_2 - t_1 * s_2;
        // if (d == 0) return false else return true;

        // // const ds: isize = c_1 * t_2 - t_1 * c_2;
        // // const dt: isize = s_1 * c_2 - c_1 * s_2;

        // // std.debug.print("s_1: {}, t_1: {}\n", .{ s_1, t_1 });
        // // std.debug.print("d: {}, ds: {}, dt: {}\n", .{ d, ds, dt });

        // // const s: f32 = @as(f32, @floatFromInt(ds)) / @as(f32, @floatFromInt(d));
        // // const t: f32 = @as(f32, @floatFromInt(dt)) / @as(f32, @floatFromInt(d));

        // // std.debug.print("s: {}, t: {}\n", .{ s, t });

        // // return false;
    }
};

fn calculateSegment(p_pos: Position, direction: Direction, w_pos: Position) Segment {
    const end_pos: Position = switch (direction) {
        .Right => .{ .x = w_pos.x - 1, .y = w_pos.y },
        .Down => .{ .x = w_pos.x, .y = w_pos.y - 1 },
        .Left => .{ .x = w_pos.x + 1, .y = w_pos.y },
        .Up => .{ .x = w_pos.x, .y = w_pos.y + 1 },
    };
    const length: usize = Segment.distance(p_pos, end_pos);
    return .{
        .start_pos = p_pos,
        .end_pos = end_pos,
        .length = length,
    };
}

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !struct { p1: usize, p2: usize } {
    var line_it = std.mem.splitScalar(u8, input, '\n');

    var walls = std.ArrayListUnmanaged(Wall){};
    defer walls.deinit(allocator);

    var segments = std.ArrayListUnmanaged(Segment){};
    defer segments.deinit(allocator);

    var y: usize = 0;
    var x: usize = 0;
    var px: usize = undefined;
    var py: usize = undefined;
    var pd: Direction = undefined;
    var mx: usize = 0;
    var my: usize = 0;
    while (line_it.next()) |line| {
        mx = line.len - 1;
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
        x = 0;
        y += 1;
    }

    my = y - 1;
    // std.debug.print("mx: {}, my: {}\n", .{ mx, my });
    // account for max

    // std.debug.print("walls: {any}\n", .{walls.items});

    var maybe_next_wall: ?Position = undefined;
    while (true) {
        maybe_next_wall = try findNextWall(allocator, .{ .x = px, .y = py }, pd, walls.items);
        const end_pos: Position = switch (pd) {
            .Right => .{ .x = mx, .y = py },
            .Down => .{ .x = px, .y = my },
            .Left => .{ .x = 0, .y = py },
            .Up => .{ .x = px, .y = 0 },
        };
        const walked_segment: Segment = if (maybe_next_wall) |wall|
            calculateSegment(.{ .x = px, .y = py }, pd, wall)
        else
            Segment{ .start_pos = .{ .x = px, .y = py }, .end_pos = end_pos, .length = Segment.distance(.{ .x = px, .y = py }, end_pos) };
        try segments.append(allocator, walked_segment);

        pd = switch (pd) {
            .Right => .Down,
            .Down => .Left,
            .Left => .Up,
            .Up => .Right,
        };
        px = walked_segment.end_pos.x;
        py = walked_segment.end_pos.y;

        if (maybe_next_wall == null) break;
    }
    std.debug.print("segments: {any}\n", .{segments.items});

    var horizontal = std.ArrayListUnmanaged(Segment){};
    defer horizontal.deinit(allocator);

    var vertical = std.ArrayListUnmanaged(Segment){};
    defer vertical.deinit(allocator);

    // for (segments.items) |segment| {
    //     total_length += segment.length;
    //     if (segment.start_pos.y == segment.end_pos.y) {
    //         try horizontal.append(allocator, segment);
    //     } else if (segment.start_pos.x == segment.end_pos.x) {
    //         try vertical.append(allocator, segment);
    //     } else unreachable;
    // }

    // for (horizontal.items) |h_segment| {
    //     for (vertical.items) |v_segment| {
    //         if (Segment.intersects(h_segment, v_segment)) {
    //             std.debug.print("a: {}, b: {}\n", .{ h_segment, v_segment });
    //             std.debug.print("intersects!\n", .{});
    //             // total_length -= 1;
    //         }
    //     }
    // }

    var set = std.AutoHashMapUnmanaged(Position, void){};
    defer set.deinit(allocator);

    for (segments.items) |segment| {
        var a: usize = undefined;
        var b: usize = undefined;

        if (segment.start_pos.y == segment.end_pos.y) {
            a = @min(segment.start_pos.x, segment.end_pos.x);
            b = @max(segment.start_pos.x, segment.end_pos.x);

            for (a..b + 1) |i| {
                try set.put(allocator, .{ .x = i, .y = segment.start_pos.y }, {});
            }
        } else if (segment.start_pos.x == segment.end_pos.x) {
            a = @min(segment.start_pos.y, segment.end_pos.y);
            b = @max(segment.start_pos.y, segment.end_pos.y);

            for (a..b + 1) |i| {
                try set.put(allocator, .{ .x = segment.start_pos.x, .y = i }, {});
            }
        } else unreachable;
    }
    const total_length: usize = set.count();

    return .{ .p1 = total_length, .p2 = 0 };
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
