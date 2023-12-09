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

const Direction = enum {
    Forwards,
    Backwards,
};

const Mode = enum {
    Simple,
    Complex,
};

pub fn findNumber(comptime mode: Mode, comptime direction: Direction, input: []const u8) usize {
    const searchFn = if (comptime direction == .Forwards) std.mem.indexOfAny else std.mem.lastIndexOfAny;
    if (comptime mode == .Simple) {
        const maybeIndex = searchFn(u8, input, "123456789");
        if (maybeIndex) |i|
            return std.fmt.parseUnsigned(usize, input[i .. i + 1], 10) catch unreachable
        else
            return 0;
    } else {
        // std.debug.print("searching in: {s}\n", .{input});
        const wordSearchFn = if (comptime direction == .Forwards) std.mem.indexOf else std.mem.lastIndexOf;
        const maybeDigitIndex = searchFn(u8, input, "123456789");
        const fillValue = if (comptime direction == .Forwards) std.math.maxInt(usize) else std.math.minInt(usize);
        const op = if (comptime direction == .Forwards) std.builtin.ReduceOp.Min else std.builtin.ReduceOp.Max;
        var is: [words.len]usize = [_]usize{fillValue} ** words.len;
        for (words, 0..) |word, i| { // NOTE: maybe inline it?
            const maybeWordIndex = wordSearchFn(u8, input, word);
            if (maybeWordIndex) |index| is[i] = index;
        }
        const v: @Vector(words.len, usize) = is;
        const wI = @reduce(op, v);
        const wNumber: usize = for (is, 1..) |i, n| {
            if (i == wI) break n;
        } else fillValue;
        if (maybeDigitIndex) |dI| {
            const i = if (comptime direction == .Forwards)
                @min(dI, wI)
            else
                @max(dI, wI);

            if (i == wI) {
                if (wI == fillValue) return std.fmt.parseUnsigned(usize, input[dI .. dI + 1], 10) catch unreachable else return wNumber;
            } else {
                return std.fmt.parseUnsigned(usize, input[dI .. dI + 1], 10) catch unreachable;
            }
        }
        if (wI == fillValue) return 0 else return wNumber;
    }
}

pub fn parseLine(line: []const u8) struct { usize, usize } {
    const p1fn = findNumber(.Simple, .Forwards, line);
    const p1sn = findNumber(.Simple, .Backwards, line);

    // std.debug.print("{d} <- {s} -> {d}\n", .{ p1fn, line, p1sn });

    const p2fn = findNumber(.Complex, .Forwards, line);
    const p2sn = findNumber(.Complex, .Backwards, line);

    // std.debug.print("{d} <- {s} -> {d}\n", .{ p2fn, line, p2sn });

    return .{ p1fn * 10 + p1sn, p2fn * 10 + p2sn };
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

test "Part 2" {
    const input =
        \\two1nine
        \\eightwothree
        \\abcone2threexyz
        \\xtwone3four
        \\4nineeightseven2
        \\zoneight234
        \\7pqrstsixteen
    ;

    try std.testing.expectEqual(@as(usize, 281), solve(input).p2);
}

test "freak tests" {
    // const input =
    //     \\threeight
    //     \\sevenine
    //     \\oneight
    //     \\zoneight234
    // ;

    try std.testing.expectEqual(@as(usize, 0), solve("threeight").p1);
    try std.testing.expectEqual(@as(usize, 38), solve("threeight").p2);
    try std.testing.expectEqual(@as(usize, 88), solve("threight").p2);

    try std.testing.expectEqual(@as(usize, 0), solve("sevenine").p1);
    try std.testing.expectEqual(@as(usize, 79), solve("sevenine").p2);

    try std.testing.expectEqual(@as(usize, 0), solve("oneight").p1);
    try std.testing.expectEqual(@as(usize, 18), solve("oneight").p2);

    try std.testing.expectEqual(@as(usize, 33), solve("3kbklxmh").p2);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const buffer = try utils.readFile(allocator);
    defer allocator.free(buffer);
    const s = solve(buffer);

    std.debug.print("Part 1: {d}\n", .{s.p1});
    std.debug.print("Part 2: {d}\n", .{s.p2});
}
