const std = @import("std");
const utils = @import("utils");

const Solution = struct {
    p1: usize,
    p2: usize,
};

const Box = std.StringArrayHashMap(usize);
const Boxes = [256]?Box;

pub fn solve(allocator: std.mem.Allocator, input: []const u8) Solution {
    var lIt = std.mem.splitScalar(u8, input, '\n');
    const realInput = lIt.next().?;
    var it = std.mem.splitScalar(u8, realInput, ',');
    var p1sum: usize = 0;

    var boxes: Boxes = [_]?std.StringArrayHashMap(usize){null} ** 256;
    defer {
        for (&boxes) |*maybeBox| {
            if (maybeBox.*) |*box| {
                // std.debug.print("found box to deinit!\n", .{});
                // var bIt = box.iterator();
                // while (bIt.next()) |pair| {
                //     std.debug.print("k: {any}, v: {any}\n", .{ pair.key_ptr, pair.value_ptr });
                //     allocator.destroy(pair.value_ptr); // free the value
                // }
                box.deinit();
            }
        }
    }

    while (it.next()) |cmd| {
        if (cmd.len == 0) continue;
        const value = parseCmd(allocator, cmd, &boxes);
        p1sum += value;
    }

    var p2sum: usize = 0;
    for (boxes, 1..) |maybeBox, boxIndex| {
        if (maybeBox) |box| {
            var bIt = box.iterator();
            if (bIt.len == 0) continue;
            // std.debug.print("Box {d}: ", .{boxIndex});
            var slotIndex: usize = 1;
            while (bIt.next()) |pair| {
                // std.debug.print("[{s} {d}] ", .{ pair.key_ptr.*, pair.value_ptr.* });
                p2sum += boxIndex * slotIndex * pair.value_ptr.*;
                slotIndex += 1;
            }
            // std.debug.print("\n", .{});
        }
    }

    return .{ .p1 = p1sum, .p2 = p2sum };
}

pub fn parseCmd(allocator: std.mem.Allocator, cmd: []const u8, boxes: *Boxes) usize {
    // std.debug.print("line {s}\n", .{cmd});
    const maybeTypePos = std.mem.indexOfAny(u8, cmd, "-=");
    if (maybeTypePos) |typePos| {
        const lensLabel = cmd[0..typePos];
        const boxIndex = hash(lensLabel);
        // std.debug.print("cmd: {s}, box: {d}\n", .{ cmd[0..typePos], boxIndex });

        const boxPtr: *?Box = &boxes[boxIndex];
        var maybeBox = boxPtr.*;
        if (maybeBox == null) {
            // std.debug.print("initialize box: {d}\n", .{boxIndex});
            maybeBox = std.StringArrayHashMap(usize).init(allocator);
            boxPtr.* = maybeBox;
        }
        var box: Box = maybeBox.?;
        switch (cmd[typePos]) {
            '-' => {
                _ = box.orderedRemove(lensLabel);
                boxPtr.* = box;
            },
            '=' => {
                // std.debug.print("digits? {s}\n", .{cmd[typePos + 1 ..]});
                const lensFocalLength = std.fmt.parseUnsigned(usize, cmd[typePos + 1 ..], 10) catch unreachable;
                box.put(lensLabel, lensFocalLength) catch unreachable;
                boxPtr.* = box;
            },
            else => unreachable,
        }
    }

    const p1 = hash(cmd);

    return p1;
}

pub fn hash(input: []const u8) usize {
    var value: usize = 0;

    for (input) |c| {
        value += c;
        value *= 17;
        value %= 256;
    }

    return value;
}

test "Part 1" {
    const allocator = std.testing.allocator;
    const input = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7";
    const s = solve(allocator, input);

    try std.testing.expectEqual(@as(usize, 1320), s.p1);
    try std.testing.expectEqual(@as(usize, 145), s.p2);

    // try std.testing.expectEqual(@as(usize, 52), solve(allocator, "HASH").p1);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const buffer = try utils.readFile(allocator);
    defer allocator.free(buffer);
    const s = solve(allocator, buffer);

    std.debug.print("Part 1: {d}\n", .{s.p1});
    std.debug.print("Part 2: {d}\n", .{s.p2});
}
