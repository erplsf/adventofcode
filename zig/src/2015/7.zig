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

const Solution = aoc.Solution(void, void);

const Circuit = struct {
    allocator: std.mem.Allocator,
    map: std.StringArrayHashMap(Expression),
    arr: std.ArrayList(Expression),

    pub fn init(allocator: std.mem.Allocator) Circuit {
        return .{
            .allocator = allocator,
            .map = std.StringArrayHashMap(Expression).init(allocator),
            .arr = std.ArrayList(Expression).init(allocator),
        };
    }

    pub fn deinit(self: *Circuit) void {
        for (self.map.values()) |exp| {
            switch(exp) {
                .@"and", .@"or", .lshift, .rshift => |ie| {
                    self.allocator.destroy(&ie[0].*);
                    self.allocator.destroy(&ie[1].*);
                },
                .not => |ie| {
                    self.allocator.destroy(&ie[0].*);
                },
                .value => {},
                else => unreachable,
            }
        }
        self.map.deinit();
        self.arr.deinit();
    }

    pub fn buildCircuit(self: *Circuit, input: []const u8) !void {
        var it = std.mem.split(u8, input, "\n");
        while (it.next()) |line| {
            try self.parseLine(line);
        }
    }

    pub fn resolve(self: *Circuit) !void {
        for (self.map.values()) |exp| {
            switch (exp) {
                .@"and", .@"or", .lshift, .rshift => |ie| {
                    if (ie[0].* == Expression.name) {
                        const name = ie[0].name;
                        self.allocator.destroy(&ie[0].*);
                        ie[0].* = self.map.get(name).?;
                    }
                    if (ie[1].* == Expression.name) {
                        const name = ie[1].name;
                        self.allocator.destroy(&ie[1].*);
                        ie[1].* = self.map.get(name).?;
                    }
                },
                .not => |ie| {
                    if (ie[0].* == Expression.name) {
                        const name = ie[0].name;
                        self.allocator.destroy(&ie[0].*);
                        ie[0].* = self.map.get(name).?;
                    }
                },
                .value => {},
                else => unreachable,
            }
        }
    }

    pub fn process(self: *Circuit) void {
        for (self.map.values()) |*exp| {
            _ = exp.eval(self.allocator);
        }
    }

    pub fn print(self: *const Circuit) void {
        var it = self.map.iterator();
        while (it.next()) |entry| {
            std.debug.print("{s} -> {?}\n", .{entry.key_ptr.*, entry.value_ptr});
        }
    }

    pub fn parseLine(self: *Circuit, line: []const u8) !void {
        if (line.len == 0) return;
        var pIt = std.mem.split(u8, line, "->");
        var left = pIt.next().?;
        var right = pIt.next().?;
        left = std.mem.trim(u8, left, " ");
        right = std.mem.trim(u8, right, " ");

        var exp: Expression = try Expression.build(self.allocator, left);

        try self.map.put(right, exp);
    }

    const Expression = union(enum) {
        value: u16,
        name: []const u8,
        @"and": [2]*Expression,
        @"or": [2]*Expression,
        lshift: [2]*Expression,
        rshift: [2]*Expression,
        not: [1]*Expression,

        pub fn deinit(self: *Expression, allocator: std.mem.Allocator) void {
            switch(self.*) {
                .@"and", .@"or", .lshift, .rshift => |ie| {
                    allocator.destroy(&ie[0].*);
                    allocator.destroy(&ie[1].*);
                },
                .not => |ie| {
                    allocator.destroy(&ie[0].*);
                },
                .value => {},
                else => unreachable,
            }
        }

        pub fn eval(self: *Expression, allocator: std.mem.Allocator) u16 {
            const res = switch(self.*) {
                .@"and" => |ex| ex[0].eval(allocator) & ex[1].eval(allocator),
                .@"or" => |ex| ex[0].eval(allocator) | ex[1].eval(allocator),
                .lshift => |ex| ex[0].eval(allocator) << @intCast(u4, ex[1].eval(allocator)),
                .rshift => |ex| ex[0].eval(allocator) >> @intCast(u4, ex[1].eval(allocator)),
                .not => |ex| ~ ex[0].eval(allocator),
                .value => |ex| ex, // we already covered it in a branch above
                .name => unreachable, // we should never try to call eval on an expression with string
            };
            self.deinit(allocator);
            self.* = .{ .value = res }; // replace the original expression with calculated value
            return res;
        }

        pub fn build(allocator: std.mem.Allocator, input: []const u8) std.mem.Allocator.Error!Expression {
            const leftBuf = try aoc.splitBuf(allocator, u8, input, " ");
            defer allocator.free(leftBuf);

            var exp: Expression = undefined;

            switch (leftBuf.len) {
                1 => { // value
                    if (std.fmt.parseUnsigned(u16, leftBuf[0], 10)) |number| {
                        exp = .{ .value = number };
                    } else |_| {
                        exp = .{ .name = leftBuf[0] };
                    }
                },
                2 => { // not
                    var innerExp = try allocator.create(Expression);
                    innerExp.* = try Expression.build(allocator, leftBuf[1]);
                    exp = .{ .not = .{ innerExp } };
                },
                3 => { // command
                    var leftExp = try allocator.create(Expression);
                    leftExp.* = try Expression.build(allocator, leftBuf[0]);
                    // var middleExp = Expression.build(leftBuf[1]);
                    var rightExp = try allocator.create(Expression);
                    rightExp.* = try Expression.build(allocator, leftBuf[2]);
                    if (std.mem.eql(u8, leftBuf[1], "AND")) {
                        exp = .{ .@"and" = .{ leftExp, rightExp } };
                    } else if (std.mem.eql(u8, leftBuf[1], "OR")) {
                        exp = .{ .@"or" = .{ leftExp, rightExp } };
                    } else if (std.mem.eql(u8, leftBuf[1], "LSHIFT")) {
                        exp = .{ .lshift = .{ leftExp, rightExp } };
                    } else if (std.mem.eql(u8, leftBuf[1], "RSHIFT")) {
                        exp = .{ .rshift = .{ leftExp, rightExp } };
                    } else {
                        std.debug.print("input: {s}\n", .{leftBuf[1]});
                        unreachable;
                    }
                },
                else => unreachable,
            }

            std.debug.print("resulting exp: {?}!\n", .{exp});
            return exp;
        }
    };
};

fn solve(input: []const u8) !Solution {
    _ = input;
    return Solution{.part_1 = {}, .part_2 = {}};
}

test "Part 1" {
    const circuit_input =
        \\123 -> x
        \\456 -> y
        \\x AND y -> d
        \\x OR y -> e
        \\x LSHIFT 2 -> f
        \\y RSHIFT 2 -> g
        \\NOT x -> h
        \\NOT y -> i
    ;
    var circuit = Circuit.init(std.testing.allocator);
    defer circuit.deinit();

    try circuit.buildCircuit(circuit_input);
    circuit.print();
    try circuit.resolve();
    circuit.print();
    circuit.process();
    circuit.print();
    // var e1 = Expression{ .value = 5 };
    // try expectEqual(5, e1.eval());
    // var exp = Expression{ .not = .{ &e1 } };
    // try std.testing.expect(exp == Expression.not);
    // try expectEqual(65530, exp.eval());
    // try std.testing.expect(exp == Expression.value);
}

test "Part 2" {}
