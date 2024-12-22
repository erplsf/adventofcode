const std = @import("std");

const IT_COUNT = 2_000;

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !struct { p1: usize, p2: usize } {
    var line_it = std.mem.tokenizeScalar(u8, input, '\n');

    var digits_array = std.ArrayListUnmanaged([]u4){};
    defer {
        for (digits_array.items) |item| {
            allocator.free(item);
        }
        digits_array.deinit(allocator);
    }

    var diff_array = std.ArrayListUnmanaged([]i5){};
    defer {
        for (diff_array.items) |item| {
            allocator.free(item);
        }
        diff_array.deinit(allocator);
    }

    var sum: usize = 0;
    while (line_it.next()) |line| {
        var digits: []u4 = try allocator.alloc(u4, IT_COUNT);
        try digits_array.append(allocator, digits);
        var result = try std.fmt.parseUnsigned(usize, line, 10);
        var rd: u4 = @as(u4, @intCast(result % 10));
        for (0..IT_COUNT) |i| {
            digits[i] = rd;
            const next_number = nextNumber(result);
            const nd: u4 = @as(u4, @intCast(next_number % 10));
            const d: i5 = @as(i5, @intCast(nd)) - @as(i5, @intCast(rd));
            _ = d; // autofix
            result = next_number;
            rd = nd;
        }
        sum += result;
    }

    return .{ .p1 = sum, .p2 = 0 };
}

fn nextNumber(number: usize) usize {
    const r1 = mixAndPrune(number, number * 64);
    const r2 = mixAndPrune(r1, r1 / 32);
    const r3 = mixAndPrune(r2, r2 * 2048);

    return r3;
}

fn mixAndPrune(number: usize, to_mix: usize) usize {
    return (number ^ to_mix) % 16777216;
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
        \\1
        \\10
        \\100
        \\2024
    ;
    const answers = try solve(std.testing.allocator, input);
    try std.testing.expectEqual(@as(usize, 37327623), answers.p1);
    try std.testing.expectEqual(@as(usize, 0), answers.p2);
}
