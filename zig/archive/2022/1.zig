const std = @import("std");
const aoc = @import("aoc");
const expectEqual = aoc.expectEqual;
const Allocator = std.mem.Allocator;

pub const log_level: std.log.Level = .info; // always print info level messages and above (std.log.info is fast enough for our purposes)
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input = try aoc.readFile(allocator);
    defer allocator.free(input);

    const answer = try solve(input, allocator);
    std.log.info("Part 1: {d}", .{answer.part_1});
    std.log.info("Part 2: {d}", .{answer.part_2});
}

const Solution = aoc.Solution(usize, usize);

fn solve(input: []const u8, allocator: std.mem.Allocator) !Solution {
    var elvesIt = std.mem.split(u8, input, "\n\n");
    var allElfCalories: std.ArrayList(usize) = std.ArrayList(usize).init(allocator);
    // defer allElfCalories.deinit();
    while (elvesIt.next()) |elf| {
        if (elf.len == 0) continue;
        var elfCalories: usize = 0;
        var itemIt = std.mem.split(u8, elf, "\n");
        while (itemIt.next()) |item| {
            if (item.len == 0) continue;
            // try stdout.print("item: {s}\n", .{item});
            const calories = try std.fmt.parseUnsigned(usize, item, 10);
            elfCalories += calories;
            // try stdout.print("calories: {d}\n", .{calories});
        }
        try allElfCalories.append(elfCalories);
    }

    var ownedCalories = try allElfCalories.toOwnedSlice();
    std.sort.sort(usize, ownedCalories, {}, std.sort.desc(usize));
    defer allocator.free(ownedCalories);
    const topThreeCalories = ownedCalories[0] + ownedCalories[1] + ownedCalories[2];

    return Solution{ .part_1 = ownedCalories[0], .part_2 = topThreeCalories };
}

const test_input =
    \\1000
    \\2000
    \\3000
    \\
    \\4000
    \\
    \\5000
    \\6000
    \\
    \\7000
    \\8000
    \\9000
    \\
    \\10000
;

test "Part 1" {
    const allocator = std.testing.allocator;
    try expectEqual(24000, (try solve(test_input, allocator)).part_1);
}

test "Part 2" {
    const allocator = std.testing.allocator;
    try expectEqual(45000, (try solve(test_input, allocator)).part_2);
}
