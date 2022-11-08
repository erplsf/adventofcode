const std = @import("std");
const aoc = @import("aoc");
const expectEqual = aoc.expectEqual;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input = try aoc.readFile(allocator);
    defer allocator.free(input);

    const answer = try outerSolve(input);
    std.log.info("Total square feet of wrapping paper: {d}", .{answer.part_1});
    std.log.info("Total feet of ribbon: {d}", .{answer.part_2});
}

const Solution = aoc.Solution(usize, usize);

fn outerSolve(input: []const u8) !Solution {
    var it = std.mem.split(u8, input, "\n");

    var total_part_1: usize = 0;
    var total_part_2: usize = 0;

    while(it.next()) |line| {
        if (line.len == 0) break;
        const solution = try solve(line);
        total_part_1 += solution.part_1;
        total_part_2 += solution.part_2;
    }

    return Solution{.part_1 = total_part_1, .part_2 = total_part_2};
}

fn solve(input: []const u8) !Solution {
    var it = std.mem.split(u8, input, "x");
    var parts: [3]usize = undefined;

    var i: usize = 0;
    while (it.next()) |part| {
        const number = try std.fmt.parseUnsigned(usize, part, 10);
        parts[i] = number;
        i += 1;
    }

    std.sort.sort(usize, &parts, {}, comptime std.sort.asc(usize));

    const alw = parts[0] * parts[1];
    const awh = parts[1] * parts[2];
    const ahl = parts[0] * parts[2];

    var part_1 = (2 * alw) + (2 * awh) + (2 * ahl) + @min(alw, @min(awh, ahl));
    var part_2 = (2 * parts[0]) + (2 * parts[1]) + (parts[0] * parts[1] * parts[2]);

    return Solution{.part_1 = part_1, .part_2 = part_2};
}

test "Part 1" {
    try expectEqual(58, (solve("2x3x4") catch unreachable).part_1);
    try expectEqual(43, (solve("1x1x10") catch unreachable).part_1);
}

test "Part 2" {
    try expectEqual(34, (solve("2x3x4") catch unreachable).part_2);
    try expectEqual(14, (solve("1x1x10") catch unreachable).part_2);
}
