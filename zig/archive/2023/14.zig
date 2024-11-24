// TODO: ugly, think if it can be rewritten without hashmap
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

    tilt(&map, .north);
    const firstNorthTilt: usize = calcNorthLoad(map);
    tilt(&map, .west);
    tilt(&map, .south);
    tilt(&map, .east);

    var cycleMap = std.StringArrayHashMap(void).init(allocator);
    defer {
        var it = cycleMap.iterator();
        while (it.next()) |kv| allocator.free(kv.key_ptr.*);
        cycleMap.deinit();
    }
    var weightsList = std.ArrayList(usize).init(allocator);
    defer weightsList.deinit();

    weightsList.append(calcNorthLoad(map)) catch unreachable;

    const string = stringify(allocator, map);
    cycleMap.put(string, {}) catch unreachable;

    const cycleCount = 1000000000 - 1;
    var loopAt: usize = 0;
    var loopStartsAt: usize = 0;
    for (0..cycleCount) |c| {
        cycle(&map);
        const state = stringify(allocator, map);
        if (cycleMap.get(state)) |_| {
            loopStartsAt = cycleMap.getIndex(state).?;
            allocator.free(state);
            loopAt = c + 2;
            break;
        } else {
            const newWeight = calcNorthLoad(map);
            weightsList.append(newWeight) catch unreachable;
            cycleMap.put(state, {}) catch unreachable;
        }
    }
    // std.debug.print("loopAt, startsAt: {d}, {d}\n", .{ loopAt, loopStartsAt });
    // std.debug.print("len: {d}, list: {any}\n", .{ weightsList.items.len, weightsList.items });
    const loop = weightsList.items[loopStartsAt..];
    // std.debug.print("len: {d}, loop: {any}\n", .{ loop.len, loop });
    const leftoverFullLoops: usize = cycleCount - loopStartsAt;
    const leftoverLoops: usize = leftoverFullLoops % loop.len;
    const finalWeight: usize = loop[leftoverLoops];
    // std.debug.print("final weight: {d}\n", .{finalWeight});

    // printMap(map);
    // std.debug.print("\n", .{});

    return .{ .p1 = firstNorthTilt, .p2 = finalWeight };
}

pub fn stringify(allocator: std.mem.Allocator, map: []const []const u8) []u8 {
    const totalLength: usize = map.len * map[0].len;
    var string = allocator.alloc(u8, totalLength) catch unreachable;
    for (1..map.len) |r| {
        const sliceSize: usize = map[r].len;
        @memcpy(string[(r - 1) * sliceSize .. r * sliceSize], map[r]);
    }

    return string;
}

pub fn cycle(map: *[]const []u8) void {
    tilt(map, .north);
    tilt(map, .west);
    tilt(map, .south);
    tilt(map, .east);
}

pub fn calcNorthLoad(map: []const []const u8) usize {
    var northLoad: usize = 0;
    for (0..map.len) |r| {
        for (0..map[r].len) |c| {
            if (map[r][c] == 'O') northLoad += map.len - r;
        }
    }
    return northLoad;
}

pub fn printMap(map: []const []const u8) void {
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

pub fn tilt(map: *[]const []u8, comptime direction: Direction) void {
    // std.debug.print("direction: {s}\n", .{@tagName(direction)});
    var m = map.*;
    const posLimit = switch (comptime direction) {
        .north => m.len, // moving up-to-down, to the length of column
        .south => 0, // down-to-up, to zero
        .west => m[0].len, // right-to-left, to the length of the row
        .east => 0, // left-to-right, to zero
    };
    const axisLimit = switch (comptime direction) {
        .north, .south => m[0].len, // tilt up or down for each column
        .west, .east => m.len, // tilt left or right for each row
    };
    // std.debug.print("axisLimit: {d}\n", .{axisLimit});

    for (0..axisLimit) |axis| {
        var iteratedOnZero: bool = false; // HACK:TODO: ugly
        var freePos: ?usize = null;
        var i: usize = switch (comptime direction) {
            .north => 0, // start from beginning of the column
            .south => m.len - 1, // start from the end of the column
            .west => 0, // start from the beginning of the row
            .east => m[0].len - 1, // start from the end of the row
        };
        while (true) {
            if (posLimit != 0 and i == posLimit) break; // break for going left-to-right and up-to-down
            if (posLimit == 0 and i == posLimit) iteratedOnZero = true;
            // switch (comptime direction) {
            //     .north, .south => std.debug.print("objIndex: [{d}][{d}]\n", .{ i, axis }),
            //     .east, .west => std.debug.print("objIndex: [{d}][{d}]\n", .{ axis, i }),
            // }
            // std.debug.print("r: {d}\n", .{r});
            // std.debug.print("char {c} at [{d}][{d}]\n", .{ m[r][column], r, column });

            const objPos = switch (comptime direction) {
                .north, .south => &m[i][axis], // grab object in each column
                .east, .west => &m[axis][i], // grab object in each row
            };

            switch (objPos.*) {
                '#' => { // cube-shaped rock (wall)
                    freePos = null; // reset the free position, as rocks can't move past the wall
                    switch (comptime direction) {
                        .north, .west => i += 1,
                        .south, .east => i -|= 1,
                    }
                },
                '.' => { // free space
                    if (freePos == null) {
                        freePos = i; // only record the row the first time we see free space
                    }
                    switch (comptime direction) {
                        .north, .west => i += 1,
                        .south, .east => i -|= 1,
                    }
                },
                'O' => { // movable rock
                    if (freePos) |fr| { // if there's a free row, move our rock to it
                        // std.debug.print("found rock at [{d}][{d}] moving it to [{d}][{d}]\n", .{ r, column, fr, column });
                        const freeSpace = switch (comptime direction) {
                            .north, .south => &m[fr][axis],
                            .east, .west => &m[axis][fr],
                        };
                        freeSpace.* = 'O'; // move the rock to free space
                        objPos.* = '.'; // mark space under rock as free
                        freePos = null; // there's no more free space, we need to search for it again

                        switch (comptime direction) { // start searching from the next row after the one we placed our rock into
                            .north, .west => i = fr + 1,
                            .south, .east => i = fr -| 1,
                        }
                    } else {
                        switch (comptime direction) {
                            .north, .west => i += 1,
                            .south, .east => i -|= 1,
                        }
                    }
                },
                else => unreachable,
            }
            if (posLimit == 0 and i == 0 and iteratedOnZero == true) break; // break for reverse direction
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
