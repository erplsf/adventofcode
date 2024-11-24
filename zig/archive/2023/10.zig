const std = @import("std");
const utils = @import("utils");

const Solution = struct {
    p1: isize,
    p2: isize,
};

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !Solution {
    const map = try utils.arraify(allocator, input);
    defer allocator.free(map);

    return .{ .p1 = 0, .p2 = 0 };
}

test "examples" {
    const t1 =
        \\.....
        \\.S-7.
        \\.|.|.
        \\.L-J.
        \\.....
    ;
    const r1 = try solve(std.testing.allocator, t1);
    try std.testing.expectEqual(@as(isize, 114), r1.p1);
    try std.testing.expectEqual(@as(isize, 2), r1.p2);
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
