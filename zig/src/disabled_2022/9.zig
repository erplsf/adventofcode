const std = @import("std");
const aoc = @import("aoc");
const expectEqual = aoc.expectEqual;
const assert = std.testing.assert;
const Allocator = std.mem.Allocator;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit()) @panic("memory leak!");
    const allocator = gpa.allocator();

    const input = try aoc.readFile(allocator);
    defer allocator.free(input);

    const answer = try solve(allocator, input);
    aoc.print("Part 1: {d}\n", .{answer.part_1});
    aoc.print("Part 2: {d}\n", .{answer.part_2});
}

const Position = struct {
    x: isize,
    y: isize,
};

const Map = std.AutoHashMap(Position, void);

const Solution = aoc.Solution(usize, usize);

const Field = struct {
    const Self = @This();

    allocator: Allocator,
    map: Map,
    segments: []Position,

    pub fn init(allocator: Allocator, segmentCount: usize) !Self {
        const map = Map.init(allocator);
        const segments = try allocator.alloc(Position, segmentCount + 1);
        for (segments) |*segment| {
            segment.x = 0;
            segment.y = 0;
        }
        return Self{
            .allocator = allocator,
            .map = map,
            .segments = segments,
        };
    }

    pub fn deinit(self: *Self) void {
        self.map.deinit();
        self.allocator.free(self.segments);
    }

    pub fn execute(self: *Self, move: Move) !void {
        aoc.printErr("whole move: {}\n", .{move});
        var moveCount: usize = 0;
        while (moveCount < move.range) : (moveCount += 1) {
            aoc.printErr("move {d}\n", .{moveCount});
            self.segments[0] = newHeadPos(self.segments[0], move.direction); // move head
            var tailI: usize = 1;
            while (tailI < self.segments.len) : (tailI += 1) {
                if (moveTail(self.segments[tailI - 1], self.segments[tailI])) {
                    aoc.printErr("head: {}, tail: {}\n", .{ self.segments[tailI - 1], self.segments[tailI] });
                    aoc.printErr("moving tailI: {d}!\n", .{tailI});
                    self.segments[tailI] = newTailPos(self.segments[tailI - 1], self.segments[tailI], move.direction);
                }
            }

            try self.map.put(self.segments[self.segments.len - 1], {});
        }
    }

    fn newHeadPos(headPos: Position, moveDirection: Direction) Position {
        var newPosition = headPos;
        switch (moveDirection) {
            Direction.Up => newPosition.y += 1,
            Direction.Left => newPosition.x -= 1,
            Direction.Down => newPosition.y -= 1,
            Direction.Right => newPosition.x += 1,
        }
        return newPosition;
    }

    fn newTailPos(headPos: Position, tailPos: Position, moveDirection: Direction) Position {
        const xDistance = std.math.absCast(headPos.x - tailPos.x);
        const yDistance = std.math.absCast(headPos.y - tailPos.y);
        // const reverseDirection = moveDirection.reverse();
        var newTailpos = headPos;
        // if (xDistance + yDistance > 3) {
        // aoc.printErr("first branch!\n", .{});
        // switch (moveDirection) {
        //     Direction.Up => {
        //         newTailpos.y -= 1;
        //         if (headPos.x - newTailpos.x < 0) {
        //             newTailpos.x -= 1;
        //         } else {
        //             newTailpos.x += 1;
        //         }
        //     },
        //     Direction.Left => {
        //         newTailpos.x -= 1;
        //         if (headPos.y - newTailpos.y < 0) {
        //             newTailpos.y -= 1;
        //         } else {
        //             newTailpos.y += 1;
        //         }
        //     },
        //     Direction.Down => {
        //         newTailpos.y += 1;
        //         if (headPos.y - newTailpos.y < 0) {
        //             newTailpos.y += 1;
        //         } else {
        //             newTailpos.y -= 1;
        //         }
        //     },
        //     Direction.Right => {
        //         newTailpos.x += 1;
        //         if (headPos.y - newTailpos.y > 0) {
        //             newTailpos.y += 1;
        //         } else {
        //             newTailpos.y -= 1;
        //         }
        //     },
        // }
        // }
        if (xDistance > 1 or yDistance > 1 or (xDistance + yDistance > 2)) {
            switch (moveDirection) {
                Direction.Up => newTailpos.y -= 1,
                Direction.Left => newTailpos.x += 1,
                Direction.Down => newTailpos.y -= 1,
                Direction.Right => newTailpos.x += 1,
            }
        }
        return newTailpos;
    }

    fn moveTail(headPos: Position, tailPos: Position) bool {
        const xDistance = std.math.absCast(headPos.x - tailPos.x);
        const yDistance = std.math.absCast(headPos.y - tailPos.y);
        return xDistance > 1 or yDistance > 1 or (xDistance + yDistance > 2);
    }

    pub fn visitedPositions(self: Self) usize {
        return self.map.count();
    }

    pub fn visualizeVisited(self: Self) void {
        var minY: isize = 0;
        var minX: isize = 0;
        var maxY: isize = 0;
        var maxX: isize = 0;
        var it = self.map.keyIterator();
        while (it.next()) |pos| {
            if (pos.x < minX) minX = pos.x else if (pos.x > maxX) maxX = pos.x;
            if (pos.y < minY) minY = pos.y else if (pos.y > maxY) maxY = pos.y;
        }
        // const xDistance: usize = std.math.cast(usize, maxX - minX) orelse unreachable;
        // _ = xDistance;
        // const yDistance: usize = std.math.cast(usize, maxY - minY) orelse unreachable;
        // _ = yDistance;
        var y: isize = minY;
        var x: isize = minX;
        aoc.printErr("minX: {d}, maxX: {d}, minY: {d}, maxY: {d}\n", .{ minX, maxX, minY, maxY });
        while (y < maxY) : (y += 1) {
            while (x < maxX) : (x += 1) {
                const pos = Position{ .x = x, .y = y };
                const visited = self.map.get(pos).? == {};
                switch (visited) {
                    true => aoc.printErr("#", .{}),
                    false => aoc.printErr(".", .{}),
                }
            }
            aoc.printErr("\n", .{});
        }
    }
};

const Move = struct {
    direction: Direction,
    range: usize,

    pub fn parseMove(input: []const u8) !Move {
        var move: Move = undefined;
        var it = std.mem.split(u8, input, " ");
        var dirSlice = it.next().?;
        if (dirSlice.len != 1) return aoc.AocError.InputParseProblem;
        var dir = dirSlice[0];
        switch (dir) {
            'U' => move.direction = Direction.Up,
            'L' => move.direction = Direction.Left,
            'R' => move.direction = Direction.Right,
            'D' => move.direction = Direction.Down,
            else => return aoc.AocError.InputParseProblem,
        }
        move.range = try std.fmt.parseUnsigned(usize, it.next().?, 10);
        return move;
    }
};

const Direction = enum {
    Up,
    Down,
    Left,
    Right,

    pub fn reverse(self: Direction) Direction {
        return switch (self) {
            Direction.Up => Direction.Down,
            Direction.Left => Direction.Right,
            Direction.Down => Direction.Up,
            Direction.Right => Direction.Left,
        };
    }
};

fn solve(allocator: Allocator, input: []const u8) !Solution {
    var smallMap = try Field.init(allocator, 1);
    defer smallMap.deinit();

    var bigMap = try Field.init(allocator, 9);
    defer bigMap.deinit();

    var it = std.mem.split(u8, input, "\n");
    while (it.next()) |line| {
        if (line.len == 0) continue;
        // aoc.printErr("line: {s}\n", .{line});
        var move = try Move.parseMove(line);
        // aoc.printErr("{?}\n", .{move});
        try smallMap.execute(move);
        // move = try Move.parseMove(line);
        aoc.printErr("\n", .{});
        try bigMap.execute(move);
    }

    return Solution{ .part_1 = smallMap.visitedPositions(), .part_2 = bigMap.visitedPositions() };
}

const testing_input =
    \\R 4
    \\U 4
    \\L 3
    \\D 1
    \\R 4
    \\D 1
    \\L 5
    \\R 2
;

test "Part 1" {
    const allocator = std.testing.allocator;
    try expectEqual(13, (try solve(allocator, testing_input)).part_1);
}

// test "Part 2" {
//     const allocator = std.testing.allocator;
//     try expectEqual(1, (try solve(allocator, testing_input)).part_2);
// }
