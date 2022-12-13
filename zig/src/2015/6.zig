const std = @import("std");
const aoc = @import("aoc");
const expectEqual = aoc.expectEqual;

pub const log_level: std.log.Level = .info; // always print info level messages and above (std.log.info is fast enough for our purposes)

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input = try aoc.readFile(allocator);
    defer allocator.free(input);

    const answer = try solve(input);
    std.log.info("Part 1: {d}", .{answer.part_1});
    std.log.info("Part 2: {d}", .{answer.part_2});
}

const Opcode = enum {
    TurnOn,
    Toggle,
    TurnOff,
};

const Range = struct {
    // we only need 16 bytes to store numbers up to 1024
    fromX: u16,
    fromY: u16,
    toX: u16,
    toY: u16,
};

const Instruction = struct {
    opcode: Opcode,
    range: Range,
};

pub fn Field(comptime T: type) type {
    return struct {
        const side = 1000;

        field: [side * side]T = std.mem.zeroes([side * side]T),

        const Self = @This();

        pub fn execute(self: *Self, instruction: Instruction) void {
            var yi: usize = instruction.range.fromY;
            // var iCount: usize = 0;
            while (yi <= instruction.range.toY) : (yi += 1) {
                var xi: usize = instruction.range.fromX;
                while (xi <= instruction.range.toX) : (xi += 1) {
                    const index = yi * side + xi;
                    // std.debug.print("index: {d}\n", .{index});
                    switch (instruction.opcode) {
                        .TurnOn => {
                            if (comptime T == bool) {
                                self.field[index] = true;
                            } else if (comptime T == usize) {
                                self.field[index] += 1;
                            }
                        },
                        .Toggle => {
                            if (comptime T == bool) {
                                self.field[index] = !self.field[index];
                            } else if (comptime T == usize) {
                                self.field[index] += 2;
                            }
                        },
                        .TurnOff => {
                            if (comptime T == bool) {
                                self.field[index] = false;
                            } else if (comptime T == usize) {
                                self.field[index] -|= 1; // saturating minus (min of zero)
                            }
                        },
                    }
                    // iCount += 1;
                }
                // std.debug.print("iter count: {d}\n", .{iCount});
            }
        }

        pub fn count(self: *Self) usize {
            var total: usize = 0;

            var yi: usize = 0;
            while (yi < side) : (yi += 1) {
                var xi: usize = 0;
                while (xi < side) : (xi += 1) {
                    const index = yi * side + xi;
                    total += if (T == bool) @boolToInt(self.field[index]) else self.field[index];
                    // std.debug.print("v: {b}, t: {d}\n", .{self.field[index], total});
                }
            }

            return total;
        }
    };
}

const Solution = aoc.Solution(usize, usize);

fn decode(input: []const u8) !Instruction {
    var it = std.mem.split(u8, input, " ");
    var opcode: Opcode = undefined;
    var range: Range = undefined;
    var i: usize = 0;
    while (it.next()) |part| : (i += 1) {
        switch (i) {
            0 => { // opcode part
                if (std.mem.eql(u8, part, "toggle")) {
                    opcode = .Toggle;
                } else {
                    const next_part = it.next().?;
                    if (std.mem.eql(u8, next_part, "on")) {
                        opcode = .TurnOn;
                    } else if (std.mem.eql(u8, next_part, "off")) {
                        opcode = .TurnOff;
                    } else {
                        return aoc.AocError.InputParseProblem;
                    }
                }
            },
            1, 3 => { // from range part
                var range_it = std.mem.split(u8, part, ",");
                const rangeX = try std.fmt.parseUnsigned(u16, range_it.next().?, 10);
                const rangeY = try std.fmt.parseUnsigned(u16, range_it.next().?, 10);
                if (i == 1) {
                    range.fromX = rangeX;
                    range.fromY = rangeY;
                } else { // i == 3
                    range.toX = rangeX;
                    range.toY = rangeY;
                }
            },
            2 => {}, // through part, skip it
            else => unreachable,
        }
    }
    return Instruction{ .opcode = opcode, .range = range };
}

fn solve(input: []const u8) !Solution {
    var it = std.mem.split(u8, input, "\n");
    var fieldBool = Field(bool){};
    var fieldUsize = Field(u8){};

    while (it.next()) |line| {
        if (line.len == 0) break;
        const inst = try decode(line);
        fieldBool.execute(inst);
        fieldUsize.execute(inst);
    }

    return Solution{ .part_1 = fieldBool.count(), .part_2 = fieldUsize.count() };
}

test "Part 1" {
    try expectEqual(1000 * 1000, (try solve("turn on 0,0 through 999,999")).part_1);
    try expectEqual(1000, (try solve("toggle 0,0 through 999,0")).part_1);
    try expectEqual(1000 * 1000 - 4, (try solve("turn on 0,0 through 999,999\nturn off 499,499 through 500,500")).part_1);
}

test "Part 2" {
    try expectEqual(1, (try solve("turn on 0,0 through 0,0")).part_2);
    try expectEqual(2000000, (try solve("toggle 0,0 through 999,999")).part_2);
}
