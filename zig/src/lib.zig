const std = @import("std");

pub const AocInput = struct { year: []const u8, day: []const u8 };

pub fn getInput(alloc: *std.mem.Allocator, comptime input: AocInput) ![]const u8 {
    const args = try std.process.argsAlloc(alloc);
    var path: []const u8 = undefined;

    if (args.len == 2) {
        path = args[1];
    } else {
        std.log.err("one and only param - relative path to a base folder with inputs", .{});
        return error.NoParamProvided;
    }

    const filePath = try std.fs.path.join(alloc, &[_][]const u8{ path, input.year, input.day ++ ".txt" });
    const file = try std.fs.cwd().openFile(filePath, .{ .read = true, .write = false });
    const buf = try file.reader().readAllAlloc(alloc, std.math.maxInt(usize));

    return buf;
}
