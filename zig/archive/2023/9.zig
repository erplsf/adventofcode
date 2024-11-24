const std = @import("std");
const utils = @import("utils");

const Solution = struct {
    p1: isize,
    p2: isize,
};

const NumberList = std.ArrayList(isize);
const ListList = std.ArrayList(NumberList);

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !Solution {
    var lIt = std.mem.splitScalar(u8, input, '\n');
    var p1sum: isize = 0;
    var p2sum: isize = 0;
    while (lIt.next()) |line| {
        if (line.len == 0) continue;
        const t = parseLine(allocator, line);
        p1sum += t[1];
        p2sum += t[0];
    }

    return .{ .p1 = p1sum, .p2 = p2sum };
}

pub fn parseLine(allocator: std.mem.Allocator, line: []const u8) struct { isize, isize } {
    var ll = ListList.init(allocator);
    defer ll.deinit();
    defer for (ll.items) |*l| l.deinit();

    ll.append(NumberList.init(allocator)) catch unreachable;
    var nIt = std.mem.splitScalar(u8, line, ' ');
    while (nIt.next()) |nText| {
        const n = std.fmt.parseInt(isize, nText, 10) catch unreachable;
        ll.items[0].append(n) catch unreachable;
    }

    var level: usize = 0;
    outer: while (true) {
        const numbers = ll.items[level];
        ll.append(NumberList.init(allocator)) catch unreachable;
        var pIt = std.mem.window(isize, numbers.items, 2, 1);
        while (pIt.next()) |pair| {
            const diff = pair[1] - pair[0];
            ll.items[level + 1].append(diff) catch unreachable;
        }
        for (ll.items[level + 1].items) |n| {
            if (n != 0) {
                level += 1;
                continue :outer;
            }
        }
        break;
    }

    // iterate backwards over lists
    for (0..ll.items.len - 1) |offset| {
        const ri = ll.items.len - 2 - offset;
        // std.debug.print("ri {d}\n", .{ri});
        var currentList = ll.items[ri];
        const nextList = ll.items[ri + 1];
        const lastInCurrent = currentList.getLast();
        const lastInNext = nextList.getLast();
        const newLastForCurrent = lastInCurrent + lastInNext;

        const firstInCurrent = currentList.items[0];
        const firstInNext = nextList.items[0];
        const newFirstForCurrent = firstInCurrent - firstInNext;
        // std.debug.print("nn: {d}\n", .{nn});
        currentList.append(newLastForCurrent) catch unreachable;
        currentList.insert(0, newFirstForCurrent) catch unreachable;
        ll.items[ri] = currentList;
    }

    // for (ll.items) |l| {
    //     for (l.items) |n| {
    //         std.debug.print("{d} ", .{n});
    //     }
    //     std.debug.print("\n", .{});
    // }

    return .{ ll.items[0].items[0], ll.items[0].getLast() };
}

test "examples" {
    const t1 =
        \\0 3 6 9 12 15
        \\1 3 6 10 15 21
        \\10 13 16 21 30 45
    ;
    const r1 = try solve(std.testing.allocator, t1);
    try std.testing.expectEqual(@as(isize, 114), r1.p1);
    try std.testing.expectEqual(@as(isize, 2), r1.p2);
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
