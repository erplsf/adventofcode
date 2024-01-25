// TODO: solve without brute-forcing, but with proper ranges
const std = @import("std");
const utils = @import("utils");

const Solution = struct {
    p1: usize,
    p2: usize,
};

pub fn solve(input: []const u8) !Solution {
    var parts_it = utils.splitByChar(input, '\n');
    const times_text = parts_it.next() orelse return utils.AocError.InputParseProblem;
    const distances_text = parts_it.next() orelse return utils.AocError.InputParseProblem;
    return .{ .p1 = 0, .p2 = 0 };
}

const test_input =
    \\Time:      7  15   30
    \\Distance:  9  40  200
;

test "examples" {
    const results = try solve(test_input);
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

    const s = try solve(buffer);
    std.debug.print("Part 1: {d}\n", .{s.p1});
    std.debug.print("Part 2: {d}\n", .{s.p2});
}
