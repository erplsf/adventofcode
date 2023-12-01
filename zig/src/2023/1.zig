const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    var buffer: []u8 = undefined;
    if (args.len > 1) {
        const path = try std.fs.realpathAlloc(allocator, args[1]);
        defer allocator.free(path);

        const file = try std.fs.openFileAbsolute(path, .{});
        defer file.close();

        const size = (try file.stat()).size;
        buffer = try allocator.alloc(u8, size);
        try file.reader().readNoEof(buffer);
    }

    var digits = std.ArrayList(usize).init(allocator);
    defer digits.deinit();

    var sum: usize = 0;

    const words: []const []const u8 = &.{
        "one",
        "two",
        "three",
        "four",
        "five",
        "six",
        "seven",
        "eight",
        "nine",
    };

    var it = std.mem.splitScalar(u8, buffer, '\n');
    while (it.next()) |line| {
        var i: usize = 0;
        var wSize: usize = 1;

        while (i + wSize <= line.len) : (wSize += 1) {
            const end = @min(i + wSize, line.len);
            const slice = line[i..end];
            // std.debug.print("i: {d}, wSize: {d}, end: {d}\n", .{ i, wSize, end });
            // std.debug.print("slice: {s}\n", .{slice});
            if (wSize == 1) {
                const digit = std.fmt.parseUnsigned(u8, slice, 10) catch 0;
                if (digit != 0) {
                    try digits.append(digit);
                    wSize = 0;
                    i += 1;
                }
            } else {
                const digit = for (words, 1..) |word, d| {
                    if (wSize < word.len) continue;
                    if (std.mem.indexOf(u8, slice, word)) |p| {
                        wSize = 0;
                        i += p + word.len - 1;
                        break d;
                    }
                } else 0;
                if (digit != 0) {
                    try digits.append(digit);
                } else {
                    const d = std.fmt.parseUnsigned(u8, slice[slice.len - 1 ..], 10) catch 0;
                    if (d != 0) {
                        try digits.append(d);
                        wSize = 0;
                        i += slice.len;
                    }
                }
            }
        }

        // while (std.mem.indexOfAny(u8, line[i..], "123456789")) |pos| {

        // var wIt = std.mem.window(u8, line[i..], 5, 1);
        // while (wIt.next()) |chunk| {
        //     std.debug.print("chunk: {s}\n", .{chunk});
        //     for (0..chunk.len) |c| {
        //         const digit = std.fmt.parseUnsigned(usize, chunk[c .. c + 1], 10) catch 0;
        //         if (digit != 0) try digits.append(digit);
        //     }
        //     for (words, 1..) |word, d| {
        //         if (chunk.len < word.len) continue;
        //         if (std.mem.indexOf(u8, chunk, word)) |_| {
        //             try digits.append(d);
        //             break;
        //         }
        //     }
        // }

        // var ii: usize = 0; // HACK: skips numbers
        // for (words, 1..) |word, d| {
        //     while (std.mem.indexOf(u8, line[i + ii .. i + pos], word)) |word_pos| {
        //         std.debug.print("FOUND {d}\n", .{d});
        //         try digits.append(d);
        //         ii += word_pos + 1;
        //     }
        // }

        // std.debug.print("pos: {d}, n: {c}\n", .{ pos, line[i + pos] });
        // const digit = try std.fmt.parseUnsigned(usize, line[i + pos .. i + pos + 1], 10);
        // try digits.append(digit);
        // i += pos + 1;
        // }

        // var wIt = std.mem.window(u8, line[i..], 5, 1);
        // while (wIt.next()) |chunk| {
        //     for (words, 1..) |word, d| {
        //         if (std.mem.indexOf(u8, chunk, word)) |_| {
        //             try digits.append(d);
        //             break;
        //         }
        //     }
        // }

        // std.mem.lastIndexOf(comptime T: type, haystack: []const T, needle: []const T)

        if (digits.items.len == 0) continue;
        std.debug.print("line: {s}, d1: {d}, d2: {d}\n", .{ line, digits.items[0], digits.items[digits.items.len - 1] });
        const number = digits.items[0] * 10 + digits.items[digits.items.len - 1];
        sum += number;
        digits.clearAndFree();
    }
    std.debug.print("sum: {d}\n", .{sum});

    allocator.free(buffer);
}
