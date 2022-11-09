const std = @import("std");
const Allocator = std.mem.Allocator;

const aoc = @import("aoc");
const expectEqual = aoc.expectEqual;

pub fn UGraph(comptime V: type) type {
    return struct {
        distances: std.ArrayList(usize),
        map: std.StringArrayHashMap(V),

        const Self = @This();

        const Error = error{KeyNotFound};

        pub fn init(allocator: Allocator) Self {
            return .{
                .distances = std.ArrayList(usize).init(allocator),
                .map = std.StringArrayHashMap(V).init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.distances.deinit();
            self.map.deinit();
        }

        inline fn convertIndex(self: *const Self, x: usize, y: usize) usize {
            return self.map.count() * x + y;
        }

        inline fn convertIndexWithSize(size: usize, x: usize, y: usize) usize {
            return size * x + y;
        }

        pub fn insert(self: *Self, key: []const u8, value: V) !void {
            if (self.map.contains(key)) return;

            const prevCount = self.map.count();
            try self.map.put(key, value);
            const count = self.map.count();
            try self.distances.appendNTimes(0, count * 2 - 1);

            // TODO: check if this doesn't overwrite existing values on paper
            var i: usize = 0;
            while (i < prevCount) : (i += 1) {
                var j: usize = 0;
                while (j < prevCount) : (j += 1) {
                    if (i == j) continue;
                    const pIndex = Self.convertIndexWithSize(prevCount, i, j);
                    const nIndex = self.convertIndex(i, j);
                    self.distances.items[nIndex] = self.distances.items[pIndex];
                }
            }
        }

        pub fn setDistance(self: *Self, from: []const u8, to: []const u8, distance: usize) !void {
            const fIndex = self.map.getIndex(from) orelse return Error.KeyNotFound;
            const tIndex = self.map.getIndex(to) orelse return Error.KeyNotFound;

            var index = self.convertIndex(fIndex, tIndex);
            self.distances.items[index] = distance;

            index = self.convertIndex(tIndex, fIndex);
            self.distances.items[index] = distance;
        }

        pub fn getDistance(self: *const Self, from: []const u8, to: []const u8) !usize {
            const fIndex = self.map.getIndex(from) orelse return Error.KeyNotFound;
            const tIndex = self.map.getIndex(to) orelse return Error.KeyNotFound;

            var index = self.convertIndex(fIndex, tIndex);
            return self.distances.items[index];
        }
    };
}

test {
    const allocator = std.testing.allocator;
    var graph = UGraph(void).init(allocator);
    defer graph.deinit();

    try graph.insert("Hamburg", {});
    try expectEqual(0, try graph.getDistance("Hamburg", "Hamburg"));
    try expectEqual(1, graph.map.count());
    try expectEqual(1, graph.distances.items.len);

    try graph.insert("Berlin", {});
    try expectEqual(2, graph.map.count());
    try expectEqual(4, graph.distances.items.len);

    try graph.setDistance("Hamburg", "Berlin", 100);
    try expectEqual(100, try graph.getDistance("Hamburg", "Berlin"));
    try expectEqual(100, try graph.getDistance("Berlin", "Hamburg"));

    try graph.insert("Frankfurt", {});
    // will this still work? TODO: check on paper
    try expectEqual(100, try graph.getDistance("Hamburg", "Berlin"));
    try expectEqual(100, try graph.getDistance("Berlin", "Hamburg"));
    try expectEqual(3, graph.map.count());
    try expectEqual(9, graph.distances.items.len);
}
