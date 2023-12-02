const std = @import("std");
const utils = @import("utils");

const Solution = struct {
    p1: usize,
    p2: usize,
};

const GameResult = struct {
    id: usize,
    possible: bool,
    power: usize,
};

const Colors = enum {
    red,
    green,
    blue,
};

const limits: [@typeInfo(Colors).Enum.fields.len]usize = [_]usize{ 12, 13, 14 };

pub fn parseLine(line: []const u8) !GameResult {
    var gIt = std.mem.splitScalar(u8, line, ':');
    const gIdPart = gIt.next() orelse return utils.AocError.InputParseProblem;

    var gIdIt = std.mem.splitScalar(u8, gIdPart, ' ');
    _ = gIdIt.next(); // skip the "Game" text
    const gIdText = gIdIt.next() orelse return utils.AocError.InputParseProblem;
    const gId = try std.fmt.parseUnsigned(usize, gIdText, 10);

    const gRoundPart = gIt.next() orelse return utils.AocError.InputParseProblem;
    // const roundPart = std.mem.trimLeft(u8, gRoundPart, " ");
    var roundIt = std.mem.splitScalar(u8, gRoundPart, ';');

    var maxGameColorCounts: [@typeInfo(Colors).Enum.fields.len]usize = [_]usize{ 0, 0, 0 }; // HACK: ugly
    var minGameColorCounts: [@typeInfo(Colors).Enum.fields.len]usize = [_]usize{ std.math.maxInt(usize), std.math.maxInt(usize), std.math.maxInt(usize) }; // HACK: ugly
    while (roundIt.next()) |roundText| {
        if (roundText.len == 0) continue;
        var colorsIt = std.mem.splitScalar(u8, roundText, ',');
        while (colorsIt.next()) |colorText| {
            if (colorText.len == 0) continue;
            const ctTrimmed = std.mem.trimLeft(u8, colorText, " ");
            var colorIt = std.mem.splitScalar(u8, ctTrimmed, ' ');
            const colorCountText = colorIt.next() orelse return utils.AocError.InputParseProblem;
            const colorCount = try std.fmt.parseUnsigned(usize, colorCountText, 10);

            const colorNameText = colorIt.next() orelse return utils.AocError.InputParseProblem;
            const color = std.meta.stringToEnum(Colors, colorNameText) orelse return utils.AocError.InputParseProblem;

            const colorId = @intFromEnum(color);
            maxGameColorCounts[colorId] = @max(maxGameColorCounts[colorId], colorCount);
            minGameColorCounts[colorId] = @min(minGameColorCounts[colorId], colorCount);
        }
    }

    var possible: bool = true;
    for (maxGameColorCounts, 0..) |countedAmount, id| {
        if (countedAmount > limits[id]) {
            possible = false;
            break;
        }
    }

    var power: usize = 1;
    // std.debug.print("{any}\n", .{maxGameColorCounts});
    for (maxGameColorCounts) |count| {
        power *= count;
    }

    return .{ .id = gId, .possible = possible, .power = power };
}

pub fn solve(input: []const u8) !Solution {
    var linesIt = std.mem.splitScalar(u8, input, '\n');
    var pSum: usize = 0;
    var powers: usize = 0;
    while (linesIt.next()) |line| {
        if (line.len == 0) continue;
        const gResult = try parseLine(line);
        // std.debug.print("{?}\n", .{gResult});
        if (gResult.possible) pSum += gResult.id;
        powers += gResult.power;
    }
    return .{ .p1 = pSum, .p2 = powers };
}

const test_input =
    \\Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
    \\Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
    \\Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
    \\Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
    \\Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
;

test "examples" {
    const results = try solve(test_input);
    try std.testing.expectEqual(@as(usize, 8), results.p1);
    try std.testing.expectEqual(@as(usize, 2286), results.p2);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const buffer = try utils.readFile(allocator);
    defer allocator.free(buffer);

    const s = try solve(buffer);
    std.debug.print("Part 1: {d}\n", .{s.p1});
    std.debug.print("Part 2: {d}\n", .{s.p2});
}
