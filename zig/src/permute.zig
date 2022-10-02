const std = @import("std");
const SinglyLinkedList = std.SinglyLinkedList;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const aoc = @import("aoc");
const expectEqual = aoc.expectEqual;

pub fn permutations(comptime T: type, allocator: Allocator, items: []T) !ArrayList([]T) {
    var clone = try copy(T, allocator, items);
    defer allocator.free(clone);

    var c = try ArrayList(usize).initCapacity(allocator, items.len);
    defer c.deinit();

    var output = try ArrayList([]T).initCapacity(allocator, factorial(items.len));

    { // separate block so we can reuse the i later
        var i: usize = 0;
        while (i < items.len): (i += 1) {
            try c.append(0);
        }
    }

    var op: usize = 0; // output pointer
    try output.append(try copy(T, allocator, clone)); // first permutation is the original array
    op += 1;

    var i: usize = 1; // our stack pointer
    while (i < items.len) {
        if (c.items[i] < i) {
            if (i % 2 == 0) {
                swap(T, clone, 0, i);
            } else {
                swap(T, clone, c.items[i], i);
            }
            try output.append(try copy(T, allocator, clone));
            op += 1;
            c.items[i] += 1;
            i = 1;
        } else {
            c.items[i] = 0;
            i += 1;
        }
    }

    return output;
}

inline fn swap(comptime T: type, items: []T, from: usize, to: usize) void {
    std.debug.assert(from < items.len);
    std.debug.assert(to < items.len);

    var temp: T = items[to];
    items[to] = items[from];
    items[from] = temp;
}

inline fn copy(comptime T: type, allocator: Allocator, source: []T) ![]T {
    var new = try allocator.alloc(T, source.len);
    std.mem.copy(T, new, source);
    return new;
}

pub fn factorial(n: u64) u64 { // TODO: quite a hack, rewrite
    var result: u64 = 1;
    var i: usize = 0;
    while (i < n): (i += 1) {
        result *= i;
    }
    return result;
}

test {
    const allocator = std.testing.allocator;
    var items: [3]usize = .{ 1, 2, 3 };

    var output = try permutations(usize, allocator, &items);
    try std.testing.expectEqualSlices(usize, &[_]usize{1, 2, 3}, &items); // original is unmodified
    try expectEqual(6, output.items.len); // we have six permutations from three items

    try std.testing.expectEqualSlices(usize, &[_]usize{1, 2, 3}, output.items[0]);
    try std.testing.expectEqualSlices(usize, &[_]usize{2, 1, 3}, output.items[1]);
    try std.testing.expectEqualSlices(usize, &[_]usize{3, 1, 2}, output.items[2]);
    try std.testing.expectEqualSlices(usize, &[_]usize{1, 3, 2}, output.items[3]);
    try std.testing.expectEqualSlices(usize, &[_]usize{2, 3, 1}, output.items[4]);
    try std.testing.expectEqualSlices(usize, &[_]usize{3, 2, 1}, output.items[5]);

    defer {
        for (output.items) |item| {
            allocator.free(item);
        }
        output.deinit();
    }
}
