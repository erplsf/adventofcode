const std = @import("std");

const stdout = std.io.getStdOut().writer();
const stderr = std.io.getStdErr().writer();

pub fn Solution(comptime p1_type: type, comptime p2_type: type) type {
    return struct {
        part_1: p1_type,
        part_2: p2_type,
    };
}

pub const AocError = error{
    NoArgumentProvided,
    InputParseProblem,
};

/// Because usual interface is not nice to use. See https://github.com/ziglang/zig/issues/4437 for reference.
pub fn expectEqual(expected: anytype, actual: anytype) !void {
    try std.testing.expectEqual(@as(@TypeOf(actual), expected), actual);
}

/// Caller is expected to call allocator.free() on a returned slice!
pub fn readFile(allocator: std.mem.Allocator) ![]const u8 {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    if (args.len > 1) {
        const path = try std.fs.realpathAlloc(allocator, args[1]);
        defer allocator.free(path);

        const file = try std.fs.openFileAbsolute(path, .{});
        defer file.close();

        const size = (try file.stat()).size;
        const buffer = try allocator.alloc(u8, size);
        try file.reader().readNoEof(buffer);

        return buffer;
    }
    return AocError.NoArgumentProvided;
}

pub fn splitBuf(allocator: std.mem.Allocator, comptime T: type, input: []const T, delim: []const T) ![][]const T {
    var it = std.mem.split(T, input, delim);
    var len: usize = 0;
    while (it.next() != null) {
        len += 1;
    }
    var buf = try std.ArrayList([]const u8).initCapacity(allocator, len);
    it = std.mem.split(T, input, delim);
    while (it.next()) |item| {
        try buf.append(item);
    }
    return buf.items;
}

pub fn print(comptime format: []const u8, args: anytype) void {
    stdout.print(format, args) catch unreachable;
}

pub fn prtintErr(comptime format: []const u8, args: anytype) void {
    stderr.print(format, args) catch unreachable;
}
