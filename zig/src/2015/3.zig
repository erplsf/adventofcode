const std = @import("std");
const aoc = @import("aoc");
const expectEqual = aoc.expectEqual;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input = try aoc.readFile(allocator);
    defer allocator.free(input);

    const answer = try solve(allocator, input);
    std.log.info("Santa delivered: {d}", .{answer.part_1});
    std.log.info("Santa + Robo-Santa delivered: {d}", .{answer.part_2});
}

const Solution = aoc.Solution(usize, usize);

const Coords = struct {
    x: isize,
    y: isize,
};

pub fn Walker() type {
    return struct {
        allocator: std.mem.Allocator,
        position: Coords,
        field: std.AutoHashMap(Coords, void),

        const Self = @This();

        pub fn init(allocator: std.mem.Allocator) Self {
            return .{
                .position = .{.x = 0, .y = 0},
                .allocator = allocator,
                .field = std.AutoHashMap(Coords, void).init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.field.deinit();
        }

        pub fn recordPosition(self: *Self) !void {
            try self.field.put(self.position, {});
        }

        pub fn visitedCount(self: Self) usize {
            return self.field.count();
        }
    };
}

fn solve(allocator: std.mem.Allocator, input: []const u8) !Solution {
    var part_1: usize = 0;
    var part_2: usize = 0;

    var santa = Walker().init(allocator);
    defer santa.deinit();
    try santa.recordPosition();
    for (input) |char| {
        switch(char) {
            '>' => santa.position.x += 1,
            '<' => santa.position.x -= 1,
            '^' => santa.position.y += 1,
            'v' => santa.position.y -= 1,
            else => return aoc.AocError.InputParseProblem,
        }
        try santa.recordPosition();
    }

    part_1 += santa.visitedCount();

    var newSanta = Walker().init(allocator);
    defer newSanta.deinit();
    var roboSanta = Walker().init(allocator);
    defer roboSanta.deinit();

    // HACK: why this needs to be an array of pointers? if it's a regular array of Walker(), it leaks memory
    var walkers: [2]*Walker() = undefined;
    walkers[0] = &newSanta;
    walkers[1] = &roboSanta;
    var santaIndex: u1 = 0; // we only need to store 0 or 1 as an index

    for (walkers) |walker| {
        try walker.recordPosition();
    }

    for (input) |char| {
        switch(char) {
            '>' => walkers[santaIndex].position.x += 1,
            '<' => walkers[santaIndex].position.x -= 1,
            '^' => walkers[santaIndex].position.y += 1,
            'v' => walkers[santaIndex].position.y -= 1,
            else => return aoc.AocError.InputParseProblem,
        }
        try walkers[santaIndex].recordPosition();

        santaIndex +%= 1; // wrapping addition
    }

    part_2 += (walkers[0].visitedCount() + walkers[1].visitedCount());
    part_2 -= 1;

    return Solution{.part_1 = part_1, .part_2 = part_2};
}

test "Part 1" {
    const allocator = std.testing.allocator;
    try expectEqual(2, (solve(allocator, ">") catch unreachable).part_1);
    try expectEqual(4, (solve(allocator, "^>v<") catch unreachable).part_1);
    try expectEqual(2, (solve(allocator, "^v^v^v^v^v") catch unreachable).part_1);
}

test "Part 2" {
    const allocator = std.testing.allocator;
    try expectEqual(3, (solve(allocator, "^v") catch unreachable).part_2);
    try expectEqual(3, (solve(allocator, "^>v<") catch unreachable).part_2);
    try expectEqual(11, (solve(allocator, "^v^v^v^v^v") catch unreachable).part_2);
}
