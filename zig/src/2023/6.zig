// TODO: solve without brute-forcing, but with proper ranges
const std = @import("std");
const utils = @import("utils");

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

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !Solution {
    var parts_it = utils.splitByChar(input, '\n');
    const times_line = parts_it.next() orelse return utils.AocError.InputParseProblem;
    const distances_text = parts_it.next() orelse return utils.AocError.InputParseProblem;
    _ = distances_text; // autofix
    var times_text_it = utils.splitByChar(times_line, ':');
    _ = times_text_it.next();
    const times_part = times_text_it.next() orelse return utils.AocError.InputParseProblem;

    var times = try parseNumbers(allocator, usize, times_part);
    defer times.deinit();

    std.debug.print("{any}\n", .{times.items});

    return .{ .p1 = 0, .p2 = 0 };
}

const test_input =
    \\Time:      7  15   30
    \\Distance:  9  40  200
;

test "examples" {
    const results = try solve(std.testing.allocator, test_input);
    try std.testing.expectEqual(@as(usize, 288), results.p1);
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
