const std = @import("std");

pub const AocError = error{
    NoArgumentProvided,
    InputParseProblem,
};

pub fn readFile(allocator: std.mem.Allocator) ![]u8 {
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

pub fn anyOf(comptime T: type, one: T, candidates: []const T) bool {
    for (candidates) |candidate| {
        if (one == candidate) return true;
    }
    return false;
}

pub inline fn splitByChar(buffer: []const u8, delimiter: u8) std.mem.SplitIterator(u8, .scalar) {
    return std.mem.splitScalar(u8, buffer, delimiter);
}
