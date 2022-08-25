const std = @import("std");

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


pub fn expectEqual(expected: anytype, actual: anytype) !void {
    try std.testing.expectEqual(@as(@TypeOf(actual), expected), actual);
}

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
