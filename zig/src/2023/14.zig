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
        tiltNorth(&map, c);
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

pub fn tiltNorth(map: *[]const []u8, column: usize) void {
    var m = map.*;
    const rowCount = map.len;
    var r: usize = 0;
    var freeRow: ?usize = null;
    // std.debug.print("rowCount: {d}", .{rowCount});
    while (r < rowCount) {
        // std.debug.print("r: {d}\n", .{r});
        // std.debug.print("char {c} at [{d}][{d}]\n", .{ m[r][column], r, column });

        if (m[r][column] == '#') { // reset free space on cube-shaped rock
            // std.debug.print("found cube-rock at [{d}][{d}]\n", .{ r, column });
            freeRow = null;
            r += 1;
            continue;
        } else if (m[r][column] == '.') { // remember free space
            // std.debug.print("found free space at [{d}][{d}]\n", .{ r, column });
            if (freeRow == null) {
                freeRow = r; // only record the row the first time we see free space
            }
            r += 1;
            continue;
        } else if (m[r][column] == 'O') {
            if (freeRow) |fr| { // if there's a free row, move our rock to it
                // std.debug.print("found rock at [{d}][{d}] moving it to [{d}][{d}]\n", .{ r, column, fr, column });
                m[fr][column] = 'O'; // move the rock to free space
                m[r][column] = '.'; // mark space under rock as free
                freeRow = null; // there's no more free space, we need to search for it again
                r = fr + 1; // start searching from the next row after the one we placed our rock into
                continue;
            } else {
                r += 1;
                continue;
            }
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
