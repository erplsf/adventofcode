const std = @import("std");

pub fn p1(allocator: std.mem.Allocator, line: []const u8) !bool {
    const numbers = try convert_to_array(allocator, line);
    defer allocator.free(numbers);

    return is_safe(numbers);
}

pub fn is_safe(numbers: []const usize) bool {
    var i: usize = 0;
    var prev = numbers[i];
    i += 1;
    var next = numbers[i];
    i += 1;

    var positive: bool = undefined;
    var diff: isize = @as(isize, @intCast(next)) - @as(isize, @intCast(prev));

    if (diff == 0 or @abs(diff) > 3) {
        return false;
    }

    positive = std.math.sign(diff) == 1;

    // std.debug.print("fi: {}, se: {}, di: {}, si: {}\n", .{ prev, next, diff, positive });

    prev = next;

    for (numbers[i..numbers.len]) |numb| {
        next = numb;

        diff = @as(isize, @intCast(next)) - @as(isize, @intCast(prev));
        const now_positive = std.math.sign(diff) == 1;
        // std.debug.print("fi: {}, se: {}, di: {}\n", .{ prev, next, diff });
        // std.debug.print("fi: {}, se: {}, di: {}, si: {}\n", .{ prev, next, diff, now_positive });
        if (diff == 0 or @abs(diff) > 3 or positive != now_positive) {
            return false;
        }

        prev = next;
    }

    return true;
}

pub fn convert_to_array(allocator: std.mem.Allocator, line: []const u8) ![]usize {
    var array = std.ArrayListUnmanaged(usize){};
    defer array.deinit(allocator);

    var it = std.mem.tokenizeScalar(u8, line, ' ');
    while (it.next()) |num_text| {
        const num = try std.fmt.parseUnsigned(usize, num_text, 10);
        try array.append(allocator, num);
    }

    return try array.toOwnedSlice(allocator);
}

pub fn p2(allocator: std.mem.Allocator, line: []const u8) !bool {
    // std.debug.print("line: {s}\n", .{line});
    const numbers = try convert_to_array(allocator, line);
    defer allocator.free(numbers);

    if (is_safe(numbers)) {
        // std.debug.print("safe!\n", .{});
        return true;
    } else {
        const case = try allocator.alloc(usize, numbers.len - 1);
        // std.debug.print("{any}\n", .{numbers});
        defer allocator.free(case);

        for (0..numbers.len) |i| {
            copy_without_at_index(numbers, case, i);
            // std.debug.print("i: {d}, {any}\n", .{ i, case });

            if (is_safe(case)) {
                // std.debug.print("safe!\n", .{});
                return true;
            }
        }
    }

    return false;
}

pub fn copy_without_at_index(src: []const usize, dst: []usize, skip_index: usize) void {
    std.debug.assert(dst.len + 1 == src.len);

    var copied: usize = 0;
    var si: usize = 0;
    var di: usize = 0;
    while (copied < dst.len) {
        if (si == skip_index) {
            si += 1;
            continue;
        }

        dst[di] = src[si];

        si += 1;
        di += 1;
        copied += 1;
    }

    std.debug.assert(copied == dst.len);
}

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !struct { p1: usize, p2: usize } {
    var lines_it = std.mem.tokenizeScalar(u8, input, '\n');

    var safe_count: usize = 0;
    var adv_safe_count: usize = 0;
    while (lines_it.next()) |line| {
        if (try p1(allocator, line)) {
            safe_count += 1;
        }
        // std.debug.print("line: {s}\n", .{line});
        if (try p2(allocator, line)) {
            // std.debug.print("line: {s}, safe!\n", .{line});
            adv_safe_count += 1;
        }
    }

    return .{ .p1 = safe_count, .p2 = adv_safe_count };
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
    try std.testing.expectEqual(@as(usize, 4), answers.p2);
}
