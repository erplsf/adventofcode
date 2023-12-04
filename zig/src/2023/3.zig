const std = @import("std");
const utils = @import("utils");

const Solution = struct {
    p1: usize,
    p2: usize,
};

const Symbol = struct {
    symbol: u8,
    pos: usize,
    line: usize,
};

const Number = struct {
    value: usize,
    beg: usize,
    end: usize,
    line: usize,
    checked: bool,
};

const SymbolList = std.ArrayList(Symbol);
const NumberList = std.ArrayList(Number);

pub fn parseLine(line: []const u8, lineIndex: usize, nList: *NumberList, sList: *SymbolList) !void {
    var startIndex: usize = 0;
    while (startIndex < line.len) {
        if (utils.anyOf(u8, line[startIndex], "1234567890")) {
            var endIndex: usize = startIndex + 1;
            while (endIndex < line.len and utils.anyOf(u8, line[endIndex], "1234567890")) : (endIndex += 1) {}
            const value = std.fmt.parseUnsigned(usize, line[startIndex..endIndex], 10) catch return utils.AocError.InputParseProblem;
            const number = Number{ .value = value, .beg = startIndex, .end = endIndex - 1, .line = lineIndex, .checked = false };
            try nList.append(number);
            // std.debug.print("{?}\n", .{number});
            startIndex = endIndex;
        } else {
            if (line[startIndex] != '.') {
                const symbol = Symbol{ .symbol = line[startIndex], .pos = startIndex, .line = lineIndex };
                try sList.append(symbol);
                // std.debug.print("{?}\n", .{symbol});
            }
            startIndex += 1;
        }
    }
}

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !Solution {
    var linesIt = std.mem.splitScalar(u8, input, '\n');
    var nList = NumberList.init(allocator);
    var sList = SymbolList.init(allocator);
    defer nList.deinit();
    defer sList.deinit();
    var lineIndex: usize = 0;
    while (linesIt.next()) |line| {
        if (line.len == 0) continue;
        try parseLine(line, lineIndex, &nList, &sList);
        lineIndex += 1;
    }

    var sum: usize = 0;
    var totalGearRatio: usize = 0;
    for (sList.items) |symbol| {
        var partCount: usize = 0;
        var symbGearRatio: usize = 1;
        for (nList.items) |*number| {
            if (!number.checked and
                symbol.line >= number.line -| 1 and symbol.line <= number.line + 1 and
                symbol.pos >= number.beg -| 1 and symbol.pos <= number.end + 1)
            {
                sum += number.value;
                number.checked = true;
                partCount += 1;
                if (symbol.symbol == '*') {
                    symbGearRatio *= number.value;
                }
            }
        }
        if (partCount == 2) totalGearRatio += symbGearRatio;
    }

    // std.debug.print("{d}\n", .{sum});

    return .{ .p1 = sum, .p2 = totalGearRatio };
}

const test_input =
    \\467..114..
    \\...*......
    \\..35..633.
    \\......#...
    \\617*......
    \\.....+.58.
    \\..592.....
    \\......755.
    \\...$.*....
    \\.664.598..
;

test "examples" {
    const results = try solve(std.testing.allocator, test_input);
    try std.testing.expectEqual(@as(usize, 4361), results.p1);
    try std.testing.expectEqual(@as(usize, 467835), results.p2);
}

test "smaller_example" {
    var results = try solve(std.testing.allocator, "+130...-310");
    try std.testing.expectEqual(@as(usize, 440), results.p1);
    results = try solve(std.testing.allocator, "-31");
    try std.testing.expectEqual(@as(usize, 31), results.p1);
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
