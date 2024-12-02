const std = @import("std");

pub fn p1(line: []const u8) !bool {
    // std.debug.print("line: {s}\n", .{line});
    var parts_it = std.mem.tokenizeScalar(u8, line, ' ');

    var prev = try std.fmt.parseUnsigned(usize, parts_it.next().?, 10);
    var next = try std.fmt.parseUnsigned(usize, parts_it.next().?, 10);

    var positive: bool = undefined;

    var diff: isize = @as(isize, @intCast(next)) - @as(isize, @intCast(prev));
    if (diff == 0 or @abs(diff) > 3) {
        return false; // no difference, or difference is too big, this is unsafe line, skip it
    }

    positive = std.math.sign(diff) == 1;

    // std.debug.print("fi: {}, se: {}, di: {}, si: {}\n", .{ prev, next, diff, positive });

    prev = next;
    while (parts_it.next()) |part| {
        next = try std.fmt.parseUnsigned(usize, part, 10);

        diff = @as(isize, @intCast(next)) - @as(isize, @intCast(prev));
        const now_positive = std.math.sign(diff) == 1;
        // std.debug.print("fi: {}, se: {}, di: {}, si: {}\n", .{ prev, next, diff, now_positive });
        if (diff == 0 or @abs(diff) > 3 or positive != now_positive) {
            return false;
        }

        prev = next;
    }

    return true;
}

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !struct { p1: usize, p2: usize } {
    _ = allocator;
    var lines_it = std.mem.tokenizeScalar(u8, input, '\n');

    var safe_count: usize = 0;
    while (lines_it.next()) |line| {
        if (try p1(line)) {
            safe_count += 1;
        }
    }

    return .{ .p1 = safe_count, .p2 = 0 };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const path = try std.fs.realpathAlloc(allocator, args[1]);
    defer allocator.free(path);

    const file = try std.fs.openFileAbsolute(path, .{ .mode = .read_only });
    defer file.close();

    const size = (try file.stat()).size;
    const buffer = try allocator.alloc(u8, size);
    defer allocator.free(buffer);

    try file.reader().readNoEof(buffer);

    const answers = try solve(allocator, buffer);

    std.debug.print("Part 1: {d}\n", .{answers.p1});
    std.debug.print("Part 2: {d}\n", .{answers.p2});
}

test "simple test" {
    const input =
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\1 3 6 7 9
    ;
    const answers = try solve(std.testing.allocator, input);

    try std.testing.expectEqual(@as(usize, 2), answers.p1);
    // try std.testing.expectEqual(@as(usize, 31), answers.p2);
}
