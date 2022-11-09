const std = @import("std");
const SinglyLinkedList = std.SinglyLinkedList;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const aoc = @import("aoc");
const expectEqual = aoc.expectEqual;

// TODO: refactor the struct to hold a slice
pub fn Permutations(comptime T: type) type {
    return struct {
        allocator: Allocator,
        items: ArrayList([]T),

        const Self = @This();

        pub fn init(allocator: Allocator) Self {
            return .{
                .allocator = allocator,
                .items = ArrayList([]T).init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            for (self.items.items) |item| {
                self.allocator.free(item);
            }
            self.items.deinit();
        }

        pub fn permute(self: *Self, items: []const T) !void {
            var clone = try copy(T, self.allocator, items);
            defer self.allocator.free(clone);

            var c = try ArrayList(usize).initCapacity(self.allocator, items.len);
            defer c.deinit();

            try self.items.ensureTotalCapacityPrecise(factorial(items.len));

            { // separate block so we can reuse the i later
                var i: usize = 0;
                while (i < items.len) : (i += 1) {
                    try c.append(0);
                }
            }

            var op: usize = 0; // output pointer
            try self.items.append(try copy(T, self.allocator, clone)); // first permutation is the original array
            op += 1;

            var i: usize = 1; // our stack pointer
            while (i < items.len) {
                if (c.items[i] < i) {
                    if (i % 2 == 0) {
                        swap(T, clone, 0, i);
                    } else {
                        swap(T, clone, c.items[i], i);
                    }
                    try self.items.append(try copy(T, self.allocator, clone));
                    op += 1;
                    c.items[i] += 1;
                    i = 1;
                } else {
                    c.items[i] = 0;
                    i += 1;
                }
            }
        }
    };
}

inline fn swap(comptime T: type, items: []T, from: usize, to: usize) void {
    std.debug.assert(from < items.len);
    std.debug.assert(to < items.len);

    var temp: T = items[to];
    items[to] = items[from];
    items[from] = temp;
}

inline fn copy(comptime T: type, allocator: Allocator, source: []const T) ![]T {
    var new = try allocator.alloc(T, source.len);
    std.mem.copy(T, new, source);
    return new;
}

pub fn factorial(n: u64) u64 { // TODO: quite a hack, rewrite
    var result: u64 = 1;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        result *= i;
    }
    return result;
}

test {
    const allocator = std.testing.allocator;
    var items: [3]usize = .{ 1, 2, 3 };

    var pms = Permutations(usize).init(allocator);
    defer pms.deinit();

    try pms.permute(&items);

    try std.testing.expectEqualSlices(usize, &[_]usize{ 1, 2, 3 }, &items); // original is unmodified
    try std.testing.expect(&items != pms.items.items[0].ptr); // original is different from the first array
    try expectEqual(6, pms.items.items.len); // we have six permutations from three items

    try std.testing.expectEqualSlices(usize, &[_]usize{ 1, 2, 3 }, pms.items.items[0]);
    try std.testing.expectEqualSlices(usize, &[_]usize{ 2, 1, 3 }, pms.items.items[1]);
    try std.testing.expectEqualSlices(usize, &[_]usize{ 3, 1, 2 }, pms.items.items[2]);
    try std.testing.expectEqualSlices(usize, &[_]usize{ 1, 3, 2 }, pms.items.items[3]);
    try std.testing.expectEqualSlices(usize, &[_]usize{ 2, 3, 1 }, pms.items.items[4]);
    try std.testing.expectEqualSlices(usize, &[_]usize{ 3, 2, 1 }, pms.items.items[5]);
}

// TODO: implement a better method (with generators / iterators) - this takes forever to run.
// test {
//     const allocator = std.testing.allocator;
//     var pms = Permutations(usize).init(allocator);
//     defer pms.deinit();

//     try pms.permute(&[_]usize{1, 2, 3, 4, 5, 6, 7, 8, 9, 10});
// }
