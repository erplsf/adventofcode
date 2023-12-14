const std = @import("std");
const utils = @import("utils");

const Solution = struct {
    p1: usize,
    p2: usize,
};

pub fn solve(allocator: std.mem.Allocator, input: []u8) !Solution {
    var lIt = std.mem.splitScalar(u8, input, '\n');
    var lList = std.ArrayList([]u8).init(allocator);
    defer lList.deinit();

    while (lIt.next()) |const_line| {
        if (const_line.len == 0) continue;
        // HACK: next two lines discard the const'ness of the pointer but it's fine, because I control the input/memory passed in and can modify it
        const off = @intFromPtr(const_line.ptr) - @intFromPtr(input.ptr);
        const mut = input[off..][0..const_line.len];
        lList.append(mut) catch unreachable;
    }
    // TODO: assert it's a square map

    var map: []const []u8 = lList.toOwnedSlice() catch unreachable;
    defer allocator.free(map);

    // printMap(map);
    // std.debug.print("\n", .{});

    const colCount: usize = map[0].len;
    for (0..colCount) |c| {
        // std.debug.print("c: {d}\n", .{c});
        tilt(&map, c, .north);
    }

    // printMap(map);
    // std.debug.print("\n", .{});

    var totalLoad: usize = 0;
    for (0..map.len) |r| {
        for (0..map[r].len) |c| {
            if (map[r][c] == 'O') totalLoad += map.len - r;
        }
    }

    return .{ .p1 = totalLoad, .p2 = 0 };
}

pub fn printMap(map: []const []u8) void {
    for (0..map.len) |r| {
        for (0..map[r].len) |c| {
            std.debug.print("{c}", .{map[r][c]});
        }
        std.debug.print("\n", .{});
    }
}

const Direction = enum {
    north, // up
    west, // left
    south, // down
    east, // right
};

pub fn tilt(map: *[]const []u8, axis: usize, comptime direction: Direction) void {
    var m = map.*;
    const posLimit = switch (comptime direction) {
        .north => m.len, // moving up-to-down, to the length of column
        .south => 0, // down-to-up, to zero
        .west => 0, // right-to-left, to zero
        .east => m[0].len, // left-to-right, to the length of row
    };
    var i: usize = switch (comptime direction) {
        .north => 0, // start from beginning of the column
        .south => m.len - 1, // start from the end of the column
        .west => m[0].len - 1, // start from the end of the row
        .east => 0, // start from the end ofthe row
    };
    const step: i2 = switch (comptime direction) {
        .north => 1, // moving down
        .south => -1, // moving up
        .west => -1, // moving left
        .east => 1, // moving right
    };
    var freePos: ?usize = null;
    // std.debug.print("rowCount: {d}", .{rowCount});
    while (i != posLimit) {
        // std.debug.print("r: {d}\n", .{r});
        // std.debug.print("char {c} at [{d}][{d}]\n", .{ m[r][column], r, column });

        const obj = m[i][axis];

        switch (obj) {
            '#' => { // cube-shaped rock (wall)
                freePos = null; // reset the free position, as rocks can't move past the wall
                i += step;
            },
            '.' => { // free space
                if (freePos == null) {
                    freePos = i; // only record the row the first time we see free space
                }
                i += step;
            },
            'O' => { // movable rock
                if (freePos) |fr| { // if there's a free row, move our rock to it
                    // std.debug.print("found rock at [{d}][{d}] moving it to [{d}][{d}]\n", .{ r, column, fr, column });
                    m[fr][axis] = 'O'; // move the rock to free space
                    m[i][axis] = '.'; // mark space under rock as free
                    freePos = null; // there's no more free space, we need to search for it again
                    i = fr + step; // start searching from the next row after the one we placed our rock into
                } else {
                    i += step;
                }
            },
            else => unreachable,
        }
    }
}

test "examples" {
    var t1 = (
        \\O....#....
        \\O.OO#....#
        \\.....##...
        \\OO.#O....O
        \\.O.....O#.
        \\O.#..O.#.#
        \\..O..#O..O
        \\.......O..
        \\#....###..
        \\#OO..#....
    ).*;
    const mt1: []u8 = &t1;
    const r1 = try solve(std.testing.allocator, mt1);
    try std.testing.expectEqual(@as(usize, 136), r1.p1);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const buffer = try utils.readFile(allocator);
    defer allocator.free(buffer);

    const s = try solve(allocator, buffer);
    std.debug.print("Part 1: {d}\n", .{s.p1});
    std.debug.print("Part 2: {d}\n", .{s.p2});
}
