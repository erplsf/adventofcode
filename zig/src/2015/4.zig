const std = @import("std");
const aoc = @import("aoc");
const expectEqual = aoc.expectEqual;

const Md5 = std.crypto.hash.Md5;

pub const log_level: std.log.Level = .info; // always print info level messages and above (std.log.info is fast enough for our purposes)

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var input = try aoc.readFile(allocator);
    defer allocator.free(input);
    input = std.mem.trimRight(u8, input, "\n");

    std.log.info("Input is: {s}", .{input});

    const part_1 = try solve(input, 5);
    std.log.info("Part 1: {d}", .{part_1});

    const part_2 = try solve(input, 6);
    std.log.info("Part 2: {d}", .{part_2});
}

fn solve(input: []const u8, comptime zeroes: usize) !usize {
    var hash: [Md5.digest_length]u8 = undefined;
    var string: [Md5.digest_length * 2]u8 = undefined; // where we'll store our input string (optimization to not allocate memory)
    var hex: [Md5.digest_length * 2]u8 = undefined; // double so we can fit our hex string (hex digest is 16, printable string is 32)
    var number: usize = 1;

    while(true) {
        const written = try std.fmt.bufPrint(&string, "{s}{d}", .{input, number});
        Md5.hash(written, &hash, .{});
        _ = try std.fmt.bufPrint(&hex, "{s}", .{std.fmt.fmtSliceHexLower(&hash)});
        if (std.mem.startsWith(u8, &hex, "0" ** zeroes)) return number;
        number += 1;
    }
}

test "Part 1" {
    try expectEqual(609043, (solve("abcdef", 5) catch unreachable));
    try expectEqual(1048970, (solve("pqrstuv", 5) catch unreachable));
}

// test "Part 2" {}
