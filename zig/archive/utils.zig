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

pub fn parseNumbers(allocator: std.mem.Allocator, comptime T: type, input: []const u8) !std.ArrayList(T) {
    var array: std.ArrayList(T) = std.ArrayList(T).init(allocator);
    errdefer array.deinit();

    var it = splitByChar(input, ' ');

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

pub fn arraify(allocator: std.mem.Allocator, input: []const u8) ![][]const u8 {
    var map = std.ArrayList([]const u8).init(allocator);

    var it = splitByChar(input, '\n');
    while (it.next()) |line| try map.append(line);

    return map.toOwnedSlice();
}
