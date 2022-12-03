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
const ItemsSet = std.AutoHashMap(u8, void);

fn solve(input: []const u8, allocator: std.mem.Allocator) !Solution {
    var prioritySum: usize = 0;
    var lineIt = std.mem.split(u8, input, "\n");
    while (lineIt.next()) |line| {
        if (line.len == 0) continue;
        const middle = line.len / 2;

        var leftCompartment = line[0..middle];
        var leftItems = ItemsSet.init(allocator);
        defer leftItems.deinit();
        for (leftCompartment) |item| try leftItems.put(item, {});

        var rightCompartment = line[middle..];
        var rightItems = ItemsSet.init(allocator);
        defer rightItems.deinit();
        for (rightCompartment) |item| try rightItems.put(item, {});

        var leftItemsKIt = leftItems.keyIterator();
        var repeatingItem = while (leftItemsKIt.next()) |leftItem| {
            if (rightItems.contains(leftItem.*)) break leftItem.*;
        } else unreachable;
        // try stdout.print("Repeating item: {c}\n", .{repeatingItem});
        var itemPriority = calculatePriority(repeatingItem);
        prioritySum += itemPriority;
    }

    var groupPrioritySum: usize = 0;
    lineIt.reset();
    var group: [3]ItemsSet = undefined;
    {
        var i: usize = 0;
        while (i < group.len) : (i += 1) group[i] = ItemsSet.init(allocator);
    }

    var groupCount: usize = 0;
    while (true) {
        var bag = lineIt.next() orelse break;
        for (bag) |item| try group[groupCount].put(item, {});
        groupCount += 1;
        if (groupCount == 3) {
            var bagIt = group[0].keyIterator();
            var repeatingItem = while (bagIt.next()) |item| {
                if (group[1].contains(item.*) and group[2].contains(item.*)) break item.*;
            } else unreachable;
            var itemPriority = calculatePriority(repeatingItem);
            groupPrioritySum += itemPriority;

            for (group) |*groupBag| groupBag.clearAndFree();
            groupCount = 0;
        }
    }

    {
        var i: usize = 0;
        while (i < group.len) : (i += 1) group[i].deinit();
    }

    return Solution{ .part_1 = prioritySum, .part_2 = groupPrioritySum };
}

fn calculatePriority(item: u8) u8 {
    return switch (item) {
        'a'...'z' => |char| char - 96,
        'A'...'Z' => |char| char - 38,
        else => unreachable,
    };
}

const test_input =
    \\vJrwpWtwJgWrhcsFMMfFFhFp
    \\jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
    \\PmmdzqPrVvPwwTWBwg
    \\wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
    \\ttgJtRGJQctTZtZT
    \\CrZsJsPPZsGzwwsLwLmpwMDw
;

test "Part 1" {
    const allocator = std.testing.allocator;
    try expectEqual(157, (try solve(test_input, allocator)).part_1);
}

test "Part 2" {
    const allocator = std.testing.allocator;
    try expectEqual(70, (try solve(test_input, allocator)).part_2);
}
