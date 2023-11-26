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

const Solution = aoc.Solution(isize, usize);

const Opcode = union(enum) {
    addx: isize,
    noop: void,

    pub fn parse(line: []const u8) !Opcode {
        var it = std.mem.split(u8, line, " ");
        var opcode = it.next().?;
        if (std.mem.eql(u8, opcode, "noop")) {
            return Opcode{ .noop = {} };
        } else if (std.mem.eql(u8, opcode, "addx")) {
            const valueStr = it.next().?;
            const value = try std.fmt.parseInt(isize, valueStr, 10);
            return Opcode{ .addx = value };
        } else {
            return aoc.AocError.InputParseProblem;
        }
    }
};

const ValuesList = std.ArrayList(isize);
const PixelsList = std.ArrayList(u8);
const Screen = std.ArrayList(PixelsList);

const VM = struct {
    cycle: usize = 1,
    x: isize = 1,

    allocator: Allocator,
    breakpoints: []const usize,
    recordedValues: ValuesList,
    screen: Screen,

    const Self = @This();

    pub fn init(allocator: Allocator, breakpoints: []const usize) Self {
        return Self{
            .allocator = allocator,
            .breakpoints = breakpoints,
            .recordedValues = ValuesList.init(allocator),
            .screen = Screen.init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.recordedValues.deinit();
        for (self.screen.items) |*line| {
            line.deinit();
        }
        self.screen.deinit();
    }

    pub fn execute(self: *Self, opcode: Opcode) !void {
        switch (opcode) {
            Opcode.addx => |value| {
                try self.tick();
                try self.tick();
                self.x += value;
            },
            Opcode.noop => {
                try self.tick();
            },
        }
    }

    pub fn tracesSum(self: *const Self) isize {
        var sum: isize = 0;
        for (self.recordedValues.items) |rv| {
            sum += rv;
        }
        return sum;
    }

    pub fn drawScreen(self: *const Self) void {
        for (self.screen.items) |line| {
            for (line.items) |pixel| {
                aoc.printErr("{c}", .{pixel});
            }
            aoc.printErr("\n", .{});
        }
    }

    fn tick(self: *Self) !void {
        for (self.breakpoints) |cycle| {
            if (self.cycle == cycle) {
                try self.record();
            }
        }
        try self.draw();
        self.cycle += 1;
    }

    fn lineNum(cycle: usize) usize {
        return cycle / 40;
    }

    fn draw(self: *Self) !void {
        const i = lineNum(self.cycle - 1);
        if (self.screen.items.len < i + 1) {
            try self.screen.append(PixelsList.init(self.allocator));
        }
        const normalizedCycle = (self.cycle - 1) % 40;
        const diff = self.x - std.math.cast(isize, normalizedCycle).?;
        // aoc.printErr("lineI: {d}, cycle: {d}, x: {d}, diff: {d}\n", .{ i, normalizedCycle, self.x, diff });
        switch (diff) {
            -1, 0, 1 => try self.screen.items[i].append('#'),
            else => try self.screen.items[i].append('.'),
        }
    }

    fn record(self: *Self) !void {
        try self.recordedValues.append(self.x * std.math.cast(isize, self.cycle).?);
    }
};

fn solve(allocator: Allocator, input: []const u8) !Solution {
    const breakpoints = &[_]usize{ 20, 60, 100, 140, 180, 220 };
    var vm = VM.init(allocator, breakpoints);
    defer vm.deinit();

    var it = std.mem.split(u8, input, "\n");
    while (it.next()) |line| {
        if (line.len == 0) continue;
        const opcode = try Opcode.parse(line);
        try vm.execute(opcode);
    }

    vm.drawScreen();

    return Solution{ .part_1 = vm.tracesSum(), .part_2 = 0 };
}

const testing_input =
    \\addx 15
    \\addx -11
    \\addx 6
    \\addx -3
    \\addx 5
    \\addx -1
    \\addx -8
    \\addx 13
    \\addx 4
    \\noop
    \\addx -1
    \\addx 5
    \\addx -1
    \\addx 5
    \\addx -1
    \\addx 5
    \\addx -1
    \\addx 5
    \\addx -1
    \\addx -35
    \\addx 1
    \\addx 24
    \\addx -19
    \\addx 1
    \\addx 16
    \\addx -11
    \\noop
    \\noop
    \\addx 21
    \\addx -15
    \\noop
    \\noop
    \\addx -3
    \\addx 9
    \\addx 1
    \\addx -3
    \\addx 8
    \\addx 1
    \\addx 5
    \\noop
    \\noop
    \\noop
    \\noop
    \\noop
    \\addx -36
    \\noop
    \\addx 1
    \\addx 7
    \\noop
    \\noop
    \\noop
    \\addx 2
    \\addx 6
    \\noop
    \\noop
    \\noop
    \\noop
    \\noop
    \\addx 1
    \\noop
    \\noop
    \\addx 7
    \\addx 1
    \\noop
    \\addx -13
    \\addx 13
    \\addx 7
    \\noop
    \\addx 1
    \\addx -33
    \\noop
    \\noop
    \\noop
    \\addx 2
    \\noop
    \\noop
    \\noop
    \\addx 8
    \\noop
    \\addx -1
    \\addx 2
    \\addx 1
    \\noop
    \\addx 17
    \\addx -9
    \\addx 1
    \\addx 1
    \\addx -3
    \\addx 11
    \\noop
    \\noop
    \\addx 1
    \\noop
    \\addx 1
    \\noop
    \\noop
    \\addx -13
    \\addx -19
    \\addx 1
    \\addx 3
    \\addx 26
    \\addx -30
    \\addx 12
    \\addx -1
    \\addx 3
    \\addx 1
    \\noop
    \\noop
    \\noop
    \\addx -9
    \\addx 18
    \\addx 1
    \\addx 2
    \\noop
    \\noop
    \\addx 9
    \\noop
    \\noop
    \\noop
    \\addx -1
    \\addx 2
    \\addx -37
    \\addx 1
    \\addx 3
    \\noop
    \\addx 15
    \\addx -21
    \\addx 22
    \\addx -6
    \\addx 1
    \\noop
    \\addx 2
    \\addx 1
    \\noop
    \\addx -10
    \\noop
    \\noop
    \\addx 20
    \\addx 1
    \\addx 2
    \\addx 2
    \\addx -6
    \\addx -11
    \\noop
    \\noop
    \\noop
;

test "Part 1" {
    const allocator = std.testing.allocator;
    try expectEqual(13140, (try solve(allocator, testing_input)).part_1);
}

// test "Part 2" {
//     const allocator = std.testing.allocator;
//     try expectEqual(0, (try solve(allocator, testing_input)).part_1);
// }
