// FIXME: terribly slow
const std = @import("std");
const aoc = @import("aoc");
const Allocator = std.mem.Allocator;
const expectEqual = aoc.expectEqual;

pub const log_level: std.log.Level = .info; // always print info level messages and above (std.log.info is fast enough for our purposes)

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input = try aoc.readFile(allocator);
    defer allocator.free(input);

    const answer = try solve(input, allocator);
    std.log.info("Part 1: {d}", .{answer.part_1});
    std.log.info("Part 2: {d}", .{answer.part_2});
}

const Solution = aoc.Solution(usize, usize);

fn count(input: []const u8, allocator: Allocator) ![]const u8 {
    var numbers = std.ArrayList(usize).init(allocator);
    defer numbers.deinit();

    var counts = std.ArrayList(usize).init(allocator);
    defer counts.deinit();

    var digit_index: usize = 0;
    var current_digit: usize = try std.fmt.parseUnsigned(usize, input[0..1], 10);
    try numbers.append(current_digit);
    try counts.append(1);

    {
        var i: usize = 1;
        while(i < input.len): (i += 1) {
            var digit: usize = try std.fmt.parseUnsigned(usize, input[i..i+1], 10);

            if (digit != current_digit) {
                current_digit = digit;
                try numbers.append(digit);
                try counts.append(0);
                digit_index += 1;
            }

            counts.items[digit_index] += 1;
        }
    }

    std.debug.assert(numbers.items.len == counts.items.len); // lengths must be the same

    var result = std.ArrayList(u8).init(allocator);
    defer result.deinit();

    var i: usize = 0;
    while(i < numbers.items.len): (i += 1) {
        // std.log.info("digit: {d} -> count: {d}", .{numbers.items[i], counts.items[i]});
        var c = try std.fmt.allocPrint(allocator, "{d}", .{counts.items[i]});
        defer allocator.free(c);
        var n = try std.fmt.allocPrint(allocator, "{d}", .{numbers.items[i]});
        defer allocator.free(n);
        try result.appendSlice(c);
        try result.appendSlice(n);
    }

    return result.toOwnedSlice();
}

fn solve(input: []const u8, allocator: Allocator) !Solution {
    var result = std.mem.trim(u8, input, "\n");
    var i: usize = 0;
    var p1_len: usize = 0;
    var p2_len: usize = 0;
    while(i < 40): (i += 1) {
        // std.log.info("iter: {d}, res: {s}", .{i, result});
        result = try count(result, allocator);
        // defer allocator.free(result);
        p1_len = result.len;
    }

    while(i < 50): (i += 1) {
        // std.log.info("iter: {d}, res: {s}", .{i, result});
        result = try count(result, allocator);
        // defer allocator.free(result);
        p2_len = result.len;
    }

    return Solution{.part_1 = p1_len, .part_2 = p2_len};
}

test "Part 1" {
    const allocator = std.testing.allocator;
    try count("1211", allocator);
}

test "Part 2" {}
