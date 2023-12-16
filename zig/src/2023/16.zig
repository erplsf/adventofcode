// TODO: ugly, think if it can be rewritten without hashmap
const std = @import("std");
const utils = @import("utils");

const Solution = struct {
    p1: usize,
    p2: usize,
};

const Element = enum {
    Space,
    VerticalMirror,
    HorizontalMirror,
    LeftDiagonalMirror,
    RightDiagonalMirror,
};

const Direction = enum {
    Up,
    Left,
    Down,
    East,
};

const directionsCount = @typeInfo(Direction).Enum.fields.len;

const Map = []MapRow;
const MapRow = []Element;

const EnergizedMap = []EnergizedRow; // on each position, the beam can travel from one of 4 directions
const EnergizedRow = []EnergizedCell;
const EnergizedCell = [directionsCount]bool;

const Position = struct {
    usize,
    usize,
}; // y, x | row, column

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !Solution {
    const lineCount = std.mem.count(u8, input, "\n") + 1;
    var map: Map = try allocator.alloc(MapRow, lineCount);
    defer allocator.free(map);

    {
        var lIt = std.mem.splitScalar(u8, input, '\n');
        var rI: usize = 0;
        while (lIt.next()) |line| : (rI += 1) {
            if (line.len == 0) continue;
            map[rI] = try allocator.alloc(Element, line.len);
            for (line, 0..) |c, cI| {
                const elem: Element = switch (c) {
                    '.' => .Space,
                    '|' => .VerticalMirror,
                    '-' => .HorizontalMirror,
                    '\\' => .LeftDiagonalMirror,
                    '/' => .RightDiagonalMirror,
                    else => return utils.AocError.InputParseProblem,
                };
                map[rI][cI] = elem;
            }
        }
    }
    // TODO: assert all rows have the same length!
    defer for (map) |row| allocator.free(row);

    var energizedMap: EnergizedMap = try allocator.alloc(EnergizedRow, lineCount);
    defer allocator.free(energizedMap);
    for (0..energizedMap.len) |rI| {
        energizedMap[rI] = try allocator.alloc(EnergizedCell, map[rI].len);
        for (0..energizedMap[rI].len) |cI| {
            energizedMap[rI][cI] = [_]bool{false} ** directionsCount;
        }
    }
    defer for (energizedMap) |row| allocator.free(row);

    travel(.{ 0, 0 }, &map, &energizedMap);

    return .{ .p1 = 0, .p2 = 0 };
}

pub fn travel(position: Position, map: *Map, energizedMap: *EnergizedMap) void {
    _ = position;
    _ = map;
    _ = energizedMap;
}

test "examples" {
    const example =
        \\.|...\....
        \\|.-.\.....
        \\.....|-...
        \\........|.
        \\..........
        \\.........\
        \\..../.\\..
        \\.-.-/..|..
        \\.|....-|.\
        \\..//.|....
    ;
    const r = try solve(std.testing.allocator, example);
    try std.testing.expectEqual(@as(usize, 46), r.p1);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const buffer = try utils.readFile(allocator);
    defer allocator.free(buffer);

    const s = try solve(allocator, buffer);
    std.debug.print("Part 1: {d}\n", .{s.p1});
    std.debug.print("Part 2: {d}\n", .{s.p2});
}
