// TODO: refactor to search correctly from beginning and end
const std = @import("std");
const utils = @import("utils");

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

const Solution = struct {
    p1: usize,
    p2: usize,
};

pub fn solve(input: []const u8) Solution {
    var lIt = std.mem.splitScalar(u8, input, '\n');
    var p1sum: usize = 0;
    var p2sum: usize = 0;
    while (lIt.next()) |line| {
        if (line.len == 0) continue;
        const t = parseLine(line);
        p1sum += t[0];
        p2sum += t[1];
    }

    return .{ .p1 = p1sum, .p2 = p2sum };
}

const searchForwards = std.mem.indexOfAny;
const searchBackwards = std.mem.lastIndexOfAny;

const Direction = enum {
    Forwards,
    Backwards,
};

pub fn findNumber(comptime direction: Direction, input: []const u8) usize {
    const searchFn = if (comptime direction == .Forwards) searchForwards else searchBackwards;
    const i = searchFn(u8, input, "123456789").?;
    return std.fmt.parseUnsigned(usize, input[i .. i + 1], 10) catch unreachable;
}

pub fn parseLine(line: []const u8) struct { usize, usize } {
    const p1fn = findNumber(.Forwards, line);
    const p2fn = findNumber(.Backwards, line);

    return .{ p1fn * 10 + p2fn, 0 };
}

test "Part 1" {
    const input =
        \\1abc2
        \\pqr3stu8vwx
        \\a1b2c3d4e5f
        \\treb7uchet
    ;

    try std.testing.expectEqual(@as(usize, 142), solve(input).p1);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const buffer = try utils.readFile(allocator);

    var digits = std.ArrayList(usize).init(allocator);
    defer digits.deinit();

    var sum: usize = 0;

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

        if (digits.items.len == 0) continue;
        std.debug.print("line: {s}, d1: {d}, d2: {d}\n", .{ line, digits.items[0], digits.items[digits.items.len - 1] });
        const number = digits.items[0] * 10 + digits.items[digits.items.len - 1];
        sum += number;
        digits.clearAndFree();
    }
    std.debug.print("sum: {d}\n", .{sum});

    allocator.free(buffer);
}
