// TODO: solve without brute-forcing, but with proper ranges
const std = @import("std");
const utils = @import("utils");

const Solution = struct {
    p1: usize,
    p2: usize,
};

const Range = struct { beg: usize, end: usize };
const RangeDest = struct { range: Range, dest: usize };

const SeedsList = std.ArrayList(usize);
const MappingList = std.ArrayList(RangeDest);
const mapCount = 7;

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !Solution {
    var seeds = SeedsList.init(allocator);
    defer seeds.deinit();
    var maps: []MappingList = try allocator.alloc(MappingList, mapCount);
    defer allocator.free(maps);
    defer for (0..maps.len) |idx| maps[idx].deinit();

    var blocksIt = std.mem.split(u8, input, "\n\n");

    const seedsBlock = blocksIt.next() orelse return utils.AocError.InputParseProblem;
    var sbIt = std.mem.splitScalar(u8, seedsBlock, ':');
    _ = sbIt.next() orelse return utils.AocError.InputParseProblem; // skip text
    var seedsList = sbIt.next() orelse return utils.AocError.InputParseProblem;
    seedsList = std.mem.trimLeft(u8, seedsList, " ");
    var seedsListIt = std.mem.splitScalar(u8, seedsList, ' ');
    while (seedsListIt.next()) |numberText| {
        const number = try std.fmt.parseUnsigned(usize, numberText, 10);
        try seeds.append(number);
    }

    for (0..maps.len) |idx| {
        maps[idx] = MappingList.init(allocator);

        const mapBlock = blocksIt.next() orelse return utils.AocError.InputParseProblem;
        var mapInnerIt = std.mem.splitScalar(u8, mapBlock, '\n');
        _ = mapInnerIt.next() orelse return utils.AocError.InputParseProblem; // skip text
        while (mapInnerIt.next()) |mapLineText| {
            if (mapLineText.len == 0) continue;
            // std.debug.print("line: {s}\n", .{mapLineText});
            var numbersIt = std.mem.splitScalar(u8, mapLineText, ' ');
            const endText = numbersIt.next() orelse return utils.AocError.InputParseProblem;
            const startText = numbersIt.next() orelse return utils.AocError.InputParseProblem;
            const rangeText = numbersIt.next() orelse return utils.AocError.InputParseProblem;
            const endNum = try std.fmt.parseUnsigned(usize, endText, 10);
            const startNum = try std.fmt.parseUnsigned(usize, startText, 10);
            const rangeNum = try std.fmt.parseUnsigned(usize, rangeText, 10);

            try maps[idx].append(.{ .range = .{ .beg = startNum, .end = startNum + rangeNum }, .dest = endNum });
        }
    }

    var minLocation: usize = std.math.maxInt(usize);
    for (seeds.items) |number| {
        var currentValue: usize = number;
        for (0..maps.len) |idx| {
            currentValue = for (maps[idx].items) |rangeDest| {
                if (currentValue >= rangeDest.range.beg and
                    currentValue <= rangeDest.range.end)
                {
                    // std.debug.print("cur: {d}, beg: {d}\n", .{ currentValue, rangeDest.range.beg });
                    const diff = currentValue - rangeDest.range.beg;
                    break rangeDest.dest + diff;
                }
            } else currentValue;
            // std.debug.print("cur: {d}, new: {d}\n", .{ currentValue, newValue });
        }
        // std.debug.print("seed: {d}, location: {d}\n", .{ seed.number, currentValue });
        minLocation = @min(minLocation, currentValue);
    }

    var wIt = std.mem.window(usize, seeds.items, 2, 2);
    var sMinLocation: usize = std.math.maxInt(usize);
    while (wIt.next()) |pair| {
        const beg = pair[0];
        const range = pair[1];
        for (beg..beg + range) |number| {
            var currentValue: usize = number;
            for (0..maps.len) |idx| {
                currentValue = for (maps[idx].items) |rangeDest| {
                    if (currentValue >= rangeDest.range.beg and
                        currentValue <= rangeDest.range.end)
                    {
                        // std.debug.print("cur: {d}, beg: {d}\n", .{ currentValue, rangeDest.range.beg });
                        const diff = currentValue - rangeDest.range.beg;
                        break rangeDest.dest + diff;
                    }
                } else currentValue;
                // std.debug.print("cur: {d}, new: {d}\n", .{ currentValue, newValue });
            }
            // std.debug.print("seed: {d}, location: {d}\n", .{ seed.number, currentValue });
            sMinLocation = @min(sMinLocation, currentValue);
        }
    }

    return .{ .p1 = minLocation, .p2 = sMinLocation };
}

const test_input =
    \\seeds: 79 14 55 13
    \\
    \\seed-to-soil map:
    \\50 98 2
    \\52 50 48
    \\
    \\soil-to-fertilizer map:
    \\0 15 37
    \\37 52 2
    \\39 0 15
    \\
    \\fertilizer-to-water map:
    \\49 53 8
    \\0 11 42
    \\42 0 7
    \\57 7 4
    \\
    \\water-to-light map:
    \\88 18 7
    \\18 25 70
    \\
    \\light-to-temperature map:
    \\45 77 23
    \\81 45 19
    \\68 64 13
    \\
    \\temperature-to-humidity map:
    \\0 69 1
    \\1 0 69
    \\
    \\humidity-to-location map:
    \\60 56 37
    \\56 93 4
;

test "examples" {
    const results = try solve(std.testing.allocator, test_input);
    try std.testing.expectEqual(@as(usize, 35), results.p1);
    try std.testing.expectEqual(@as(usize, 46), results.p2);
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
