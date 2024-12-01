const std = @import("std");

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !struct { p1: usize, p2: usize } {
    var lines_it = std.mem.tokenizeScalar(u8, input, '\n');

    var left_numbers = std.ArrayList(usize).init(allocator);
    defer left_numbers.deinit();

    var right_numbers = std.ArrayList(usize).init(allocator);
    defer right_numbers.deinit();

    var counts = std.AutoHashMap(usize, usize).init(allocator);
    defer counts.deinit();

    while (lines_it.next()) |line| {
        var parts_it = std.mem.tokenizeScalar(u8, line, ' ');

        const left_number = try std.fmt.parseUnsigned(usize, parts_it.next().?, 10);
        const right_number = try std.fmt.parseUnsigned(usize, parts_it.next().?, 10);

        const entry = try counts.getOrPutValue(right_number, 0);
        entry.value_ptr.* += 1;

        try left_numbers.append(left_number);
        try right_numbers.append(right_number);
    }

    const sort_func = std.sort.asc(usize);

    std.mem.sort(usize, left_numbers.items, {}, sort_func);
    std.mem.sort(usize, right_numbers.items, {}, sort_func);

    std.debug.assert(left_numbers.items.len == right_numbers.items.len);

    var diff_sum: usize = 0;
    var similarity_sum: usize = 0;
    for (0..left_numbers.items.len) |i| {
        const left = left_numbers.items[i];
        const right = right_numbers.items[i];

        const diff: usize = @abs(@as(isize, @intCast(left)) - @as(isize, @intCast(right)));
        diff_sum += diff;

        if (counts.getEntry(left)) |entry| {
            similarity_sum += left * entry.value_ptr.*;
        }
    }

    return .{ .p1 = diff_sum, .p2 = similarity_sum };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const path = try std.fs.realpathAlloc(allocator, args[1]);
    defer allocator.free(path);

    const file = try std.fs.openFileAbsolute(path, .{ .mode = .read_only });
    defer file.close();

    const size = (try file.stat()).size;
    const buffer = try allocator.alloc(u8, size);
    defer allocator.free(buffer);

    try file.reader().readNoEof(buffer);

    const answers = try solve(allocator, buffer);

    std.debug.print("Part 1: {d}\n", .{answers.p1});
    std.debug.print("Part 2: {d}\n", .{answers.p2});
}

test "simple test" {
    const input =
        \\3   4
        \\4   3
        \\2   5
        \\1   3
        \\3   9
        \\3   3
    ;
    const answers = try solve(std.testing.allocator, input);

    try std.testing.expectEqual(@as(usize, 11), answers.p1);
    try std.testing.expectEqual(@as(usize, 31), answers.p2);
}
