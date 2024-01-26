// TODO: solve without brute-forcing, but with proper ranges
const std = @import("std");
const utils = @import("utils");
const assert = std.debug.assert;

const Solution = struct {
    p1: usize,
    p2: usize,
};

const ValuesList = std.ArrayList(usize);

pub fn parseNumbers(allocator: std.mem.Allocator, comptime T: type, input: []const u8) !std.ArrayList(T) {
    var array: std.ArrayList(T) = std.ArrayList(T).init(allocator);

    var it = utils.splitByChar(input, ' ');

    while (it.next()) |part| {
        if (part.len == 0) continue; // to completely skip double spaces/whitespace between numbers
        const number = try std.fmt.parseInt(T, part, 10);
        try array.append(number);
    }

    return array;
}

pub fn squashNumbers(array: std.ArrayList(usize)) !usize {
    var sum: usize = 0;
    for (array.items) |elem| {
        const multiplier: usize = try std.math.powi(usize, 10, std.math.log10_int(elem) + 1);
        // std.debug.print("n: {}, m: {}\n", .{ elem, multiplier });
        sum = sum * multiplier + elem;
    }
    return sum;
}

pub fn calcWays(time: usize, distance: usize) usize {
    const time_f: f64 = @floatFromInt(time);
    const distance_f: f64 = @floatFromInt(distance);

    // time_f is b, distance_f is c
    // ax^2 + bx + c - classic formula
    // -x^2 + time_f * x - distance_f - our formula
    // d = b^2 - 4ac
    const d_sqrt = std.math.sqrt(std.math.pow(f64, time_f, 2) - 4 * distance_f);
    const x_1_f = (-time_f + d_sqrt) / -2;
    const x_2_f = (-time_f - d_sqrt) / -2;
    // std.debug.print("{} {}\n", .{ x_1_f, x_2_f });

    const x_1: usize = @as(usize, @intFromFloat(std.math.floor(x_1_f))) + 1;
    const x_2: usize = @as(usize, @intFromFloat(std.math.ceil(x_2_f))) - 1;
    const ways = x_2 - x_1 + 1;

    return ways;
}

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !Solution {
    var parts_it = utils.splitByChar(input, '\n');
    const times_line = parts_it.next() orelse return utils.AocError.InputParseProblem;
    const distances_text = parts_it.next() orelse return utils.AocError.InputParseProblem;

    var times_text_it = utils.splitByChar(times_line, ':');
    _ = times_text_it.next();
    const times_part = times_text_it.next() orelse return utils.AocError.InputParseProblem;
    var times = try parseNumbers(allocator, usize, times_part);
    defer times.deinit();

    var distances_text_it = utils.splitByChar(distances_text, ':');
    _ = distances_text_it.next();
    const distances_part = distances_text_it.next() orelse return utils.AocError.InputParseProblem;
    var distances = try parseNumbers(allocator, usize, distances_part);
    defer distances.deinit();

    // std.debug.print("{any}\n", .{times.items});
    // std.debug.print("{any}\n", .{distances.items});

    assert(times.items.len == distances.items.len);

    var margin: usize = 1;
    var i: usize = 0;
    while (i < times.items.len) : (i += 1) {
        margin *= calcWays(times.items[i], distances.items[i]);
    }

    const squashed_times = try squashNumbers(times);
    const squashed_distances = try squashNumbers(distances);
    std.debug.print("{} {}\n", .{ squashed_times, squashed_distances });

    const squashed_ways = calcWays(squashed_times, squashed_distances);

    // std.debug.print("{}\n", .{margin});

    return .{ .p1 = margin, .p2 = squashed_ways };
}

const test_input =
    \\Time:      7  15   30
    \\Distance:  9  40  200
;

test "examples" {
    const results = try solve(std.testing.allocator, test_input);
    try std.testing.expectEqual(@as(usize, 288), results.p1);
    try std.testing.expectEqual(@as(usize, 71503), results.p2);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const buffer = try utils.readFile(allocator);
    defer allocator.free(buffer);

    const s = try solve(allocator, buffer);
    std.debug.print("Part 1: {d}\n", .{s.p1});
    std.debug.print("Part 2: {d}\n", .{s.p2});
}
