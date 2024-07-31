const std = @import("std");
const aoc = @import("aoc");
const expectEqual = aoc.expectEqual;
const assert = std.testing.assert;
const Allocator = std.mem.Allocator;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit()) @panic("memory leak!");
    const allocator = gpa.allocator();

    const input = try aoc.readFile(allocator);
    defer allocator.free(input);

    const answer = try solve(allocator, input);
    defer allocator.free(answer.part_1);
    defer allocator.free(answer.part_2);

    aoc.print("Part 1: {s}\n", .{answer.part_1});
    aoc.print("Part 2: {s}\n", .{answer.part_2});
}

const Stack = std.atomic.Stack([]const u8);
const List = std.TailQueue(*Stack.Node);
const Solution = aoc.Solution([]const u8, []const u8);

fn solve(allocator: Allocator, input: []const u8) !Solution {
    var partsIt = std.mem.split(u8, input, "\n\n");
    var stackChunk = partsIt.next().?;
    var stackChunkIt = std.mem.splitBackwards(u8, stackChunk, "\n");
    var numLine = stackChunkIt.next().?;

    var stackCount: usize = 0;
    numLine = std.mem.trim(u8, numLine, " ");
    var numLineIt = std.mem.split(u8, numLine, "   "); // three spaces between numbers
    while (numLineIt.next() != null) : (stackCount += 1) {}

    var stacks: []Stack = try allocator.alloc(Stack, stackCount);
    for (stacks) |*stack| stack.* = Stack.init();
    defer allocator.free(stacks);
    defer {
        for (stacks) |*stack| {
            while (stack.pop()) |node| {
                allocator.destroy(node);
            }
        }
    }

    var stacksTwo: []Stack = try allocator.alloc(Stack, stackCount);
    for (stacksTwo) |*stack| stack.* = Stack.init();
    defer allocator.free(stacksTwo);
    defer {
        for (stacksTwo) |*stack| {
            while (stack.pop()) |node| {
                allocator.destroy(node);
            }
        }
    }

    while (stackChunkIt.next()) |level| {
        var levelIt = std.mem.split(u8, level, " ");
        var stackIndex: usize = 0;
        var zlCount: usize = 0;
        while (levelIt.next()) |item| {
            if (item.len == 0) { // whitespace, ignore it, and increase the counter
                // aoc.prtintErr("zl: {s}\n", .{item});
                zlCount += 1;
                if (zlCount == 4) {
                    stackIndex += 1;
                    zlCount = 0;
                }
            } else {
                var trimmedItem = std.mem.trim(u8, item, "[]");
                const node = try allocator.create(Stack.Node);
                node.* = Stack.Node{
                    .next = undefined,
                    .data = trimmedItem,
                };
                stacks[stackIndex].push(node);

                const nodeTwo = try allocator.create(Stack.Node);
                nodeTwo.* = Stack.Node{
                    .next = undefined,
                    .data = trimmedItem,
                };
                stacksTwo[stackIndex].push(nodeTwo);
                // aoc.prtintErr("item: {s}, stackIndex: {d}\n", .{ trimmedItem, stackIndex });
                stackIndex += 1;
            }
        }
        // aoc.prtintErr("line!\n", .{});
    }

    var movesChunk = partsIt.next().?;
    var movesChunkIt = std.mem.split(u8, movesChunk, "\n");

    while (movesChunkIt.next()) |moveLine| {
        if (moveLine.len == 0) continue;
        // aoc.prtintErr("moveLine: {s}\n", .{moveLine});
        const move = try parseMove(moveLine);
        // aoc.prtintErr("parsedMove: {?}\n", .{move});
        try executeMove(allocator, stacks, move, Order.Same);
        try executeMove(allocator, stacksTwo, move, Order.Reverse);
    }

    const word = try buildWord(allocator, stacks);
    // aoc.prtintErr("stack: {any}\n", .{stacksTwo});
    const secondWord = try buildWord(allocator, stacksTwo);

    return Solution{ .part_1 = word, .part_2 = secondWord };
}

const Move = struct {
    count: usize,
    from: usize,
    to: usize,
};

fn parseMove(line: []const u8) !Move {
    var lineIt = std.mem.split(u8, line, " ");
    var itCounter: usize = 0;
    var move: Move = undefined;
    while (lineIt.next()) |part| : (itCounter += 1) {
        if (itCounter == 1) { // count
            var number = try std.fmt.parseUnsigned(u8, part, 10);
            move.count = number;
        } else if (itCounter == 3) { // from
            var number = try std.fmt.parseUnsigned(u8, part, 10);
            move.from = number - 1; // 0-based indexing
        } else if (itCounter == 5) { // to
            var number = try std.fmt.parseUnsigned(u8, part, 10);
            move.to = number - 1; // 0-based indexing
        }
    }
    return move;
}

const Order = enum {
    Same,
    Reverse,
};

fn executeMove(allocator: Allocator, stacks: []Stack, move: Move, order: Order) !void {
    var moveCount: usize = 0;
    var list: []*Stack.Node = try allocator.alloc(*Stack.Node, move.count);
    defer allocator.free(list);

    while (moveCount < move.count) : (moveCount += 1) {
        const node = stacks[move.from].pop().?;
        list[moveCount] = node;
    }

    moveCount = 0;
    while (moveCount < move.count) : (moveCount += 1) {
        const node = switch (order) {
            Order.Same => list[moveCount],
            Order.Reverse => list[move.count - moveCount - 1],
        };
        stacks[move.to].push(node);
    }
}

fn buildWord(allocator: Allocator, stacks: []Stack) ![]const u8 {
    var word: []const u8 = "";
    for (stacks) |*stack| {
        const node = stack.pop().?;
        // aoc.prtintErr("node: {?}\n", .{node});
        defer allocator.destroy(node);

        const newWord = try std.fmt.allocPrint(allocator, "{s}{s}", .{ word, node.data });
        allocator.free(word);

        word = newWord;
    }
    return word;
}

const testing_input =
    \\    [D]
    \\[N] [C]
    \\[Z] [M] [P]
    \\ 1   2   3
    \\
    \\move 1 from 2 to 1
    \\move 3 from 1 to 3
    \\move 2 from 2 to 1
    \\move 1 from 1 to 2
;

test "Part 1" {
    const allocator = std.testing.allocator;
    const answer = try solve(allocator, testing_input);
    defer allocator.free(answer.part_1);
    defer allocator.free(answer.part_2);
    try std.testing.expectEqualStrings("CMZ", answer.part_1);
}

test "Part 2" {
    const allocator = std.testing.allocator;
    const answer = try solve(allocator, testing_input);
    defer allocator.free(answer.part_1);
    defer allocator.free(answer.part_2);
    try std.testing.expectEqualStrings("MCD", answer.part_2);
}
