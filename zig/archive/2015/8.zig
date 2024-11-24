const std = @import("std");
const aoc = @import("aoc");
const expectEqual = aoc.expectEqual;

pub const log_level: std.log.Level = .info; // always print info level messages and above (std.log.info is fast enough for our purposes)

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input = try aoc.readFile(allocator);
    defer allocator.free(input);

    const answer = try solve(input);
    std.log.info("Part 1: {d}", .{answer.part_1});
    std.log.info("Part 2: {d}", .{answer.part_2});
}

const Solution = aoc.Solution(usize, usize);

fn solve(input: []const u8) !Solution {
    var code: usize = 0;
    var char: usize = 0;
    var enc: usize = 0;

    var it = std.mem.split(u8, input, "\n");
    while (it.next()) |line| {
        if (line.len == 0) break;
        var c = count(line);
        code += c.code;
        char += c.char;
        enc += c.enc;
    }

    return Solution{ .part_1 = code - char, .part_2 = enc - code };
}

const Count = struct {
    code: usize,
    char: usize,
    enc: usize,
};

fn count(input: []const u8) Count {
    var i: usize = 0;
    var cc: usize = 0;
    var enc: usize = 0;

    while (i < input.len) {
        if (input[i] == '\\') {
            if (input[i + 1] == '"' or
                input[i + 1] == '\\')
            { // cc + 1, i + 2
                i += 2;
                enc += 4;
            } else if (input[i + 1] == 'x') { // cc + 1, i + 4
                i += 4;
                enc += 5;
            }
        } else {
            i += 1;
            enc += 1;
        }
        cc += 1;
    }
    cc -= 2; // to account for opening and closing quotes
    enc += 4; // to account for opening and closing quotes
    return .{ .code = input.len, .char = cc, .enc = enc };
}

test "Part 1" {
    var res = count("\"\"");
    try expectEqual(2, res.code);
    try expectEqual(0, res.char);

    res = count("\"abc\"");
    try expectEqual(5, res.code);
    try expectEqual(3, res.char);

    res = count("\"aaa\\\"aaa\"");
    try expectEqual(10, res.code);
    try expectEqual(7, res.char);

    res = count("\"\\x27\"");
    try expectEqual(6, res.code);
    try expectEqual(1, res.char);
}

test "Part 2" {
    var res = count("\"\"");
    try expectEqual(6, res.enc);

    res = count("\"abc\"");
    try expectEqual(9, res.enc);

    res = count("\"aaa\\\"aaa\"");
    try expectEqual(16, res.enc);

    res = count("\"\\x27\"");
    try expectEqual(11, res.enc);
}
