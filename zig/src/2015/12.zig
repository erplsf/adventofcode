const std = @import("std");
const aoc = @import("aoc");
const expectEqual = aoc.expectEqual;
const Allocator = std.mem.Allocator;

pub const log_level: std.log.Level = .info; // always print info level messages and above (std.log.info is fast enough for our purposes)
// const stdout = std.io.getStdOut.writer();

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input = try aoc.readFile(allocator);
    defer allocator.free(input);

    const answer = try solve(allocator, input);
    std.log.info("Part 1: {d}", .{answer.part_1});
    std.log.info("Part 2: {d}", .{answer.part_2});
}

const Solution = aoc.Solution(i64, i64);

fn solve(allocator: Allocator, input: []const u8) !Solution {
    var parser = std.json.Parser.init(allocator, false);
    defer parser.deinit();

    var tree = try parser.parse(input);
    defer tree.deinit();

    var sum_p1: i64 = 0;
    walk(tree.root, process, .{&sum_p1});

    var sum_p2: i64 = 0;
    walk_p2(tree.root, process, .{&sum_p2});

    return Solution{.part_1 = sum_p1, .part_2 = sum_p2};
}

fn walk(json: std.json.Value, func: anytype, args: anytype) void {
    @call(.{}, func, .{json} ++ args);
    switch(json) {
        .Object => |obj| {
            for (obj.values()) |val| {
                walk(val, func, args);
            }
        },
        .Array => |arr| {
            for (arr.items) |val| {
                walk(val, func, args);
            }
        },
        else => {},
    }
}

fn walk_p2(json: std.json.Value, func: anytype, args: anytype) void {
    @call(.{}, func, .{json} ++ args);
    blk: {
            switch(json) {
            .Object => |obj| {
                for (obj.values()) |val| {
                    if (val == .String and
                            std.mem.eql(u8, "red", val.String)) break :blk;
                }
                for (obj.values()) |val| {
                    walk_p2(val, func, args);
                }
            },
            .Array => |arr| {
                for (arr.items) |val| {
                    walk_p2(val, func, args);
                }
            },
            else => {},
        }
    }
}

fn process(json: std.json.Value, sum: *i64) void {
    switch(json) {
        .Integer => |int| {
            sum.* += int;
        },
        else => {},
    }
}

test "Part 1" {
    const allocator = std.testing.allocator;
    try expectEqual(6, (try solve(allocator, "[1,2,3]")).part_1);
    try expectEqual(6, (try solve(allocator, "{\"a\":2,\"b\":4}")).part_1);
    try expectEqual(3, (try solve(allocator, "[[[3]]]")).part_1);
    try expectEqual(3, (try solve(allocator, "{\"a\":{\"b\":4},\"c\":-1}")).part_1);
    try expectEqual(0, (try solve(allocator, "{\"a\":[-1,1]}")).part_1);
    try expectEqual(0, (try solve(allocator, "[-1,{\"a\":1}]")).part_1);
    try expectEqual(0, (try solve(allocator, "[]")).part_1);
    try expectEqual(0, (try solve(allocator, "{}")).part_1);
}

test "Part 2" {
    const allocator = std.testing.allocator;
    try expectEqual(0, (try solve(allocator, "{}")).part_2);
}
