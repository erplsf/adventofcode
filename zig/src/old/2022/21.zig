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

const Solution = aoc.Solution(usize, usize);

const Circuit = struct {
    allocator: std.mem.Allocator,
    map: std.StringHashMap(*Expression),

    pub fn init(allocator: std.mem.Allocator) Circuit {
        return .{
            .allocator = allocator,
            .map = std.StringHashMap(*Expression).init(allocator),
        };
    }

    fn isReferenced(self: *Circuit, ptr: *Expression) bool {
        var it = self.map.valueIterator();
        while (it.next()) |exp| {
            if (exp.* == ptr) return true;
        }
        return false;
    }

    pub fn getValue(self: *const Circuit, key: []const u8) u16 {
        return self.map.get(key).?.value;
    }

    pub fn setValue(self: *Circuit, key: []const u8, val: u16) !void {
        if (self.map.contains(key)) {
            const ptr = self.map.get(key).?;
            _ = ptr.*.deinit(self.allocator, self);
            self.allocator.destroy(ptr);
        }
        var expr: *Expression = try self.allocator.create(Expression);
        expr.* = .{ .value = val };
        try self.map.put(key, expr);
    }

    pub fn deinit(self: *Circuit) void {
        while (self.map.count() > 0) {
            var it = self.map.iterator();
            while (it.next()) |entry| {
                switch (entry.value_ptr.*.*) {
                    .@"and", .@"or", .lshift, .rshift => |ie| {
                        // exp.print();
                        self.allocator.destroy(&ie[0].*);
                        self.allocator.destroy(&ie[1].*);
                    },
                    .not => |ie| {
                        self.allocator.destroy(&ie[0].*);
                    },
                    .value => {}, // we destroy it below
                    else => unreachable,
                }
                const addr = entry.key_ptr.*;
                const ptr = entry.value_ptr.*;
                _ = self.map.remove(addr);
                if (!self.isReferenced(ptr)) {
                    // std.debug.print("freeing: {*}\n", .{ptr});
                    self.allocator.destroy(ptr);
                }
                break;
            }
        }
        self.map.deinit();
    }

    pub fn buildCircuit(self: *Circuit, input: []const u8) !void {
        var it = std.mem.split(u8, input, "\n");
        while (it.next()) |line| {
            try self.parseLine(line);
        }
    }

    pub fn resolve(self: *Circuit) !void {
        var it = self.map.valueIterator();
        while (it.next()) |exp| {
            switch (exp.*.*) {
                .@"and", .@"or", .lshift, .rshift => |*ie| {
                    if (ie[0].* == Expression.name) {
                        const name = ie[0].name;
                        self.allocator.destroy(ie[0]);
                        ie[0] = self.map.get(name).?;
                    }
                    if (ie[1].* == Expression.name) {
                        const name = ie[1].name;
                        self.allocator.destroy(ie[1]);
                        ie[1] = self.map.get(name).?;
                    }
                },
                .not => |*ie| {
                    if (ie[0].* == Expression.name) {
                        const name = ie[0].name;
                        self.allocator.destroy(ie[0]);
                        ie[0] = self.map.get(name).?;
                    }
                },
                .name => {
                    const name = exp.*.*.name;
                    self.allocator.destroy(exp.*);
                    exp.* = self.map.get(name).?;
                },
                .value => {},
                // else => {
                //     std.debug.print("!!??: {?}\n", .{exp.*});
                //     unreachable;
                // },
            }
        }
    }

    pub fn eval(self: *Circuit) void {
        var it = self.map.valueIterator();
        while (it.next()) |exp| {
            _ = exp.*.eval(self.allocator, self);
        }
    }

    pub fn print(self: *const Circuit) void {
        var it = self.map.iterator();
        while (it.next()) |entry| {
            std.debug.print("{s} -> ", .{entry.key_ptr.*});
            entry.value_ptr.*.print();
            std.debug.print("\n", .{});
            // std.debug.print("{s} -> a: {?} v: {?}\n", .{entry.key_ptr.*, entry.value_ptr, entry.value_ptr.*});
        }
    }

    pub fn parseLine(self: *Circuit, line: []const u8) !void {
        if (line.len == 0) return;
        var pIt = std.mem.split(u8, line, "->");
        var left = pIt.next().?;
        var right = pIt.next().?;
        left = std.mem.trim(u8, left, " ");
        right = std.mem.trim(u8, right, " ");

        var exp: *Expression = try Expression.build(self.allocator, left);

        try self.map.put(right, exp);
    }

    const Expression = union(enum) {
        value: usize,
        @"+": [2]*Expression,
        @"-": [2]*Expression,
        @"/": [2]*Expression,
        @"*": [2]*Expression,

        pub fn print(self: *Expression) void {
            switch (self.*) {
                .@"and", .@"or", .lshift, .rshift => |ie| {
                    std.debug.print("a: {*} v: {?} | a: {*} v: {?}", .{ ie[0], ie[0].*, ie[1], ie[1].* });
                },
                .not => |ie| {
                    std.debug.print("a: {*} v: {?}", .{ ie[0], ie[0].* });
                },
                .value => {
                    std.debug.print("a: {*} v: {?}", .{ self, self.* });
                },
                .name => {
                    std.debug.print("a: {*}, v: {s}", .{ self, self.*.name });
                },
            }
        }

        pub fn eval(self: *Expression, allocator: std.mem.Allocator, circuit: *Circuit) u16 {
            // std.debug.print("evaling: ", .{});
            // self.print();
            // std.debug.print("\n", .{});
            const res = switch (self.*) {
                .@"and" => |ex| ex[0].eval(allocator, circuit) & ex[1].eval(allocator, circuit),
                .@"or" => |ex| ex[0].eval(allocator, circuit) | ex[1].eval(allocator, circuit),
                .lshift => |ex| ex[0].eval(allocator, circuit) << @intCast(u4, ex[1].eval(allocator, circuit)),
                .rshift => |ex| ex[0].eval(allocator, circuit) >> @intCast(u4, ex[1].eval(allocator, circuit)),
                .not => |ex| ~ex[0].eval(allocator, circuit),
                .value => |ex| ex, // we already covered it in a branch above
                .name => unreachable, // we should never try to call eval on an expression with string
            };
            _ = self.deinit(allocator, circuit);
            self.* = .{ .value = res }; // replace the original expression with calculated value
            return res;
        }

        fn deinit(self: *Expression, allocator: std.mem.Allocator, circuit: *Circuit) void {
            switch (self.*) {
                .@"and", .@"or", .lshift, .rshift => |ie| {
                    if (!circuit.isReferenced(ie[0])) allocator.destroy(ie[0]);
                    if (!circuit.isReferenced(ie[1])) allocator.destroy(ie[1]);
                },
                else => {}, // no need to handle other cases - they are replaced directly
            }
        }

        pub fn build(allocator: std.mem.Allocator, input: []const u8) std.mem.Allocator.Error!*Expression {
            const leftBuf = try aoc.splitBuf(allocator, u8, input, " ");
            defer allocator.free(leftBuf);

            var exp: *Expression = try allocator.create(Expression);

            switch (leftBuf.len) {
                1 => { // value
                    if (std.fmt.parseUnsigned(u16, leftBuf[0], 10)) |number| {
                        exp.* = .{ .value = number };
                    } else |_| {
                        exp.* = .{ .name = leftBuf[0] };
                    }
                },
                2 => { // not
                    const rightNotExp = try Expression.build(allocator, leftBuf[1]);
                    exp.* = .{ .not = .{rightNotExp} };
                },
                3 => { // command
                    const leftExp = try Expression.build(allocator, leftBuf[0]);
                    // var middleExp = Expression.build(leftBuf[1]);
                    const rightExp = try Expression.build(allocator, leftBuf[2]);
                    if (std.mem.eql(u8, leftBuf[1], "AND")) {
                        exp.* = .{ .@"and" = .{ leftExp, rightExp } };
                    } else if (std.mem.eql(u8, leftBuf[1], "OR")) {
                        exp.* = .{ .@"or" = .{ leftExp, rightExp } };
                    } else if (std.mem.eql(u8, leftBuf[1], "LSHIFT")) {
                        exp.* = .{ .lshift = .{ leftExp, rightExp } };
                    } else if (std.mem.eql(u8, leftBuf[1], "RSHIFT")) {
                        exp.* = .{ .rshift = .{ leftExp, rightExp } };
                    } else {
                        std.debug.print("input: {s}\n", .{leftBuf[1]});
                        unreachable;
                    }
                },
                else => unreachable,
            }

            // std.debug.print("resulting exp: {?}!\n", .{exp});
            return exp;
        }
    };
};

fn solve(allocator: std.mem.Allocator, input: []const u8) !Solution {
    var circuit_1 = Circuit.init(allocator);
    defer circuit_1.deinit();

    try circuit_1.buildCircuit(input);
    try circuit_1.resolve();
    circuit_1.eval();

    const part_1 = circuit_1.getValue("a");

    var circuit_2 = Circuit.init(allocator);
    defer circuit_2.deinit();

    try circuit_2.buildCircuit(input);
    try circuit_2.setValue("b", part_1);
    try circuit_2.resolve();
    circuit_2.eval();

    const part_2 = circuit_2.getValue("a");

    return Solution{ .part_1 = part_1, .part_2 = part_2 };
}

const testing_input =
    \\
;

test "Part 1" {
    const allocator = std.testing.allocator;
    try expectEqual(0, (try solve(allocator, testing_input)).part_1);
}

test "Part 2" {
    const allocator = std.testing.allocator;
    try expectEqual(0, (try solve(allocator, testing_input)).part_1);
}
