// TODO: ugly, think if it can be rewritten without hashmap
const std = @import("std");
const builtin = @import("builtin");
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

const Position = struct {
    usize,
    usize,
}; // y, x | row, column

const Direction = enum {
    Up,
    Left,
    Down,
    Right,
};

const PseudoVector = struct {
    Position,
    Direction,
};

pub fn pvEql(a: PseudoVector, b: PseudoVector) bool {
    return a[0][0] == b[0][0] and a[0][1] == b[0][1] and a[1] == b[1];
}

const directionsCount = @typeInfo(Direction).Enum.fields.len;

const Map = []MapRow;
const MapRow = []Element;

const EnergizedMap = []EnergizedRow; // on each position, the beam can travel from one of 4 directions
const EnergizedRow = []EnergizedCell;
const EnergizedCell = [directionsCount]bool;

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !Solution {
    var lineCount = std.mem.count(u8, input, "\n");
    if (builtin.is_test) lineCount += 1; // HACK: in tests string literals do not have last line break
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

    travel(.{ .{ 0, 0 }, .Right }, map, &energizedMap);
    const p1TileCount: usize = calcEnergizedTiles(energizedMap);
    resetEnergizedMap(&energizedMap);

    var maxEnergizedTiles: usize = 0;
    // first and last rows
    for ([_]usize{ 0, map.len - 1 }) |rI| {
        for (0..map[rI].len) |cI| {
            if (rI == 0) {
                travel(.{ .{ rI, cI }, .Down }, map, &energizedMap);
            } else if (rI == map.len - 1) {
                travel(.{ .{ rI, cI }, .Up }, map, &energizedMap);
            }
            // calc tiles for current iteration
            const energizedTiles = calcEnergizedTiles(energizedMap);
            maxEnergizedTiles = @max(maxEnergizedTiles, energizedTiles);
            // reset map
            resetEnergizedMap(&energizedMap);
        }
    }

    // first and last columns
    for ([_]usize{ 0, map[0].len - 1 }) |cI| {
        for (0..map.len) |rI| {
            if (cI == 0) {
                travel(.{ .{ rI, cI }, .Right }, map, &energizedMap);
            } else if (cI == map[0].len - 1) {
                travel(.{ .{ rI, cI }, .Left }, map, &energizedMap);
            }
            // calc tiles for current iteration
            const energizedTiles = calcEnergizedTiles(energizedMap);
            maxEnergizedTiles = @max(maxEnergizedTiles, energizedTiles);
            // reset map
            resetEnergizedMap(&energizedMap);
        }
    }

    return .{ .p1 = p1TileCount, .p2 = maxEnergizedTiles };
}

pub fn calcEnergizedTiles(eMap: EnergizedMap) usize {
    var tileCount: usize = 0;
    for (eMap) |row| {
        for (row) |cell| {
            for (cell) |direction| {
                if (direction) {
                    tileCount += 1;
                    break;
                }
            }
        }
    }
    return tileCount;
}

pub fn resetEnergizedMap(eMap: *EnergizedMap) void {
    for (0..eMap.*.len) |mRI| {
        for (0..eMap.*[mRI].len) |mCI| {
            eMap.*[mRI][mCI] = [_]bool{false} ** directionsCount;
        }
    }
}

pub fn travel(pVector: PseudoVector, map: Map, energizedMap: *EnergizedMap) void {
    // std.debug.print("pVector: {?}\n", .{pVector});
    const position = pVector[0];
    const direction = pVector[1];
    const directionInt = @intFromEnum(direction);
    const r = position[0];
    const c = position[1];

    if (r >= map.len or c >= map[0].len) return;

    if (!energizedMap.*[r][c][directionInt]) {
        energizedMap.*[r][c][directionInt] = true;
    } else return;

    const cell = map[r][c];
    const nextPositions = calcNextPositions(direction, position, cell);
    const firstPosition = nextPositions[0];
    if (!pvEql(firstPosition, pVector)) travel(firstPosition, map, energizedMap);
    const maybeSecondPosition = nextPositions[1];
    if (maybeSecondPosition) |secondPosition| {
        if (!pvEql(secondPosition, pVector)) travel(secondPosition, map, energizedMap);
    }
}

pub fn calcNextPositions(direction: Direction, position: Position, cell: Element) struct { PseudoVector, ?PseudoVector } {
    const r = position[0];
    const c = position[1];

    switch (cell) {
        .Space => switch (direction) {
            .Up => return .{ .{ .{ r -| 1, c }, direction }, null },
            .Left => return .{ .{ .{ r, c -| 1 }, direction }, null },
            .Down => return .{ .{ .{ r +| 1, c }, direction }, null },
            .Right => return .{ .{ .{ r, c +| 1 }, direction }, null },
        },
        .HorizontalMirror => switch (direction) {
            .Up, .Down => return .{ .{ .{ r, c -| 1 }, .Left }, .{ .{ r, c +| 1 }, .Right } },
            .Left => return .{ .{ .{ r, c -| 1 }, direction }, null },
            .Right => return .{ .{ .{ r, c +| 1 }, direction }, null },
        },
        .VerticalMirror => switch (direction) {
            .Left, .Right => return .{ .{ .{ r -| 1, c }, .Up }, .{ .{ r +| 1, c }, .Down } },
            .Up => return .{ .{ .{ r -| 1, c }, direction }, null },
            .Down => return .{ .{ .{ r +| 1, c }, direction }, null },
        },
        .LeftDiagonalMirror => switch (direction) {
            .Up => return .{ .{ .{ r, c -| 1 }, .Left }, null },
            .Left => return .{ .{ .{ r -| 1, c }, .Up }, null },
            .Down => return .{ .{ .{ r, c +| 1 }, .Right }, null },
            .Right => return .{ .{ .{ r +| 1, c }, .Down }, null },
        },
        .RightDiagonalMirror => switch (direction) {
            .Up => return .{ .{ .{ r, c +| 1 }, .Right }, null },
            .Left => return .{ .{ .{ r +| 1, c }, .Down }, null },
            .Down => return .{ .{ .{ r, c -| 1 }, .Left }, null },
            .Right => return .{ .{ .{ r -| 1, c }, .Up }, null },
        },
    }
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
    try std.testing.expectEqual(@as(usize, 51), r.p2);
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
