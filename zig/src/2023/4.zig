const std = @import("std");
const utils = @import("utils");

const Solution = struct {
    p1: usize,
    p2: usize,
};

const GameResult = struct {
    id: usize,
    score: usize,
    matchCount: usize,
};

const Set = std.AutoHashMap(usize, void);
const CardCount = std.ArrayList(usize);

pub fn parseLine(allocator: std.mem.Allocator, line: []const u8) !GameResult {
    var gIt = std.mem.splitScalar(u8, line, ':');
    const gIdPart = gIt.next() orelse return utils.AocError.InputParseProblem;

    var gIdIt = std.mem.splitScalar(u8, gIdPart, ' ');
    var text: []const u8 = gIdIt.next().?; // skip the "Game" text
    text = gIdIt.next().?; // move to the next match
    while (text.len == 0) : (text = gIdIt.next().?) {} // skip whitespace
    // const gIdText = gIdIt.next() orelse return utils.AocError.InputParseProblem;
    const gId = try std.fmt.parseUnsigned(usize, text, 10);

    const gRoundPart = gIt.next() orelse return utils.AocError.InputParseProblem;
    // const roundPart = std.mem.trimLeft(u8, gRoundPart, " ");
    var roundIt = std.mem.splitScalar(u8, gRoundPart, '|');

    var winningNumbers = Set.init(allocator);
    var myNumbers = Set.init(allocator);
    defer winningNumbers.deinit();
    defer myNumbers.deinit();

    var winningText = roundIt.next() orelse return utils.AocError.InputParseProblem;
    winningText = std.mem.trim(u8, winningText, " ");
    var winningNumbersIt = std.mem.splitScalar(u8, winningText, ' ');
    while (winningNumbersIt.next()) |numberText| {
        if (numberText.len == 0) continue;
        const number = try std.fmt.parseUnsigned(usize, numberText, 10);
        // std.debug.print("winningNumber: {d}\n", .{number});
        try winningNumbers.put(number, {});
    }

    var myText = roundIt.next() orelse return utils.AocError.InputParseProblem;
    myText = std.mem.trim(u8, myText, " ");
    var myNumbersIt = std.mem.splitScalar(u8, myText, ' ');
    while (myNumbersIt.next()) |numberText| {
        if (numberText.len == 0) continue;
        const number = try std.fmt.parseUnsigned(usize, numberText, 10);
        // std.debug.print("myNumber: {d}\n", .{number});
        try myNumbers.put(number, {});
    }

    var matchCount: usize = 0;
    var it = myNumbers.keyIterator();
    while (it.next()) |key| {
        if (winningNumbers.get(key.*)) |_| matchCount += 1;
    }
    const score: usize = if (matchCount != 0)
        try std.math.powi(usize, 2, matchCount -| 1)
    else
        0;

    return .{
        .id = gId,
        .score = score,
        .matchCount = matchCount,
    };
}

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !Solution {
    var linesIt = std.mem.splitScalar(u8, input, '\n');
    var scoreSum: usize = 0;
    var totalCardCount: usize = 0;
    var cardCounts = CardCount.init(allocator);
    defer cardCounts.deinit();
    var cardIdx: usize = 0;
    while (linesIt.next()) |line| : (cardIdx += 1) {
        if (line.len == 0) continue;
        const gResult = try parseLine(allocator, line);
        if (cardIdx == cardCounts.items.len) {
            try cardCounts.append(1); // first time we see this card, count 1 to mark this as processed
        } else {
            cardCounts.items[cardIdx] += 1; // it already exists, add one to it
        }
        const currentCardCount = cardCounts.items[cardIdx];

        const nextIdx: usize = cardIdx + 1;
        for (nextIdx..nextIdx + gResult.matchCount) |idx| { // add counts from current wins
            if (idx == cardCounts.items.len) {
                try cardCounts.append(currentCardCount); // it doesn't exist, so set correct count straight from the get-go
            } else {
                cardCounts.items[idx] += currentCardCount; // it exists, increase its count by the correct value
            }
        }
        scoreSum += gResult.score;
    }
    for (cardCounts.items) |count| totalCardCount += count;
    return .{ .p1 = scoreSum, .p2 = totalCardCount };
}

const test_input =
    \\Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    \\Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
    \\Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
    \\Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
    \\Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
    \\Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
;

test "examples" {
    const results = try solve(std.testing.allocator, test_input);
    try std.testing.expectEqual(@as(usize, 13), results.p1);
    try std.testing.expectEqual(@as(usize, 30), results.p2);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const buffer = try utils.readFile(allocator);
    defer allocator.free(buffer);

    const s = try solve(allocator, buffer);
    std.debug.print("Part 1: {d}\n", .{s.p1});
    std.debug.print("Part 2: {d}\n", .{s.p2});
}
