const std = @import("std");
const aoc = @import("aoc");
const expectEqual = aoc.expectEqual;
const assert = std.testing.assert;
const Allocator = std.mem.Allocator;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit()) @panic("memory leak!");
    const allocator = gpa.allocator();

    const input = try aoc.readFile(allocator);
    defer allocator.free(input);

    const answer = try solve(allocator, input);
    aoc.print("Part 1: {d}\n", .{answer.part_1});
    aoc.print("Part 2: {d}\n", .{answer.part_2});
}

const Solution = aoc.Solution(usize, usize);

const List = std.ArrayList(Node);

const Node = union(enum) {
    value: usize,
    list: List,

    pub fn init(allocator: Allocator) !Node {
        return Node{ .list = List.init(allocator) };
    }

    pub fn buildNode(allocator: Allocator, line: []const u8) !Node {
        var node = Node.init(allocator);
        _ = line;
        return node;
    }

    pub fn deinit(self: Node, allocator: Allocator) void {
        if (self == Node.value) return;
        for (self.list.items) |*item| {
            item.deinit(allocator);
        }
        self.list.deinit();
    }

    pub fn compareOrder(allocator: Allocator, self: Node, other: Node) !?bool {
        if (self == Node.value and other == Node.value) {
            if (self.value < other.value) {
                return true;
            } else if (self.value > other.value) {
                return false;
            } else {
                return null;
            }
        } else if (self == Node.list and other == Node.list) {
            var i: usize = 0;
            while (i < self.list.items.len and i < other.list.items.len) : (i += 1) {
                if (compareOrder(allocator, self.list.items[i], other.list.items[i])) |result| {
                    return result;
                } else |_| {
                    unreachable;
                }
            }
            if (self.list.items.len < other.list.items.len) {
                return true;
            } else if (self.list.items.len > other.list.items.len) {
                return false;
            } else {
                return null;
            }
        } else {
            var nodeA = try upsert(allocator, self);
            defer nodeA.deinit(allocator);
            var nodeB = try upsert(allocator, other);
            defer nodeB.deinit(allocator);
            return compareOrder(allocator, nodeA, nodeB);
        }
        unreachable;
    }

    fn upsert(allocator: Allocator, node: Node) !Node {
        if (node == Node.list) return node;

        var list = List.init(allocator);
        try list.append(Node{ .value = node.value });
        return Node{ .list = list };
    }
};

fn solve(allocator: Allocator, input: []const u8) !Solution {
    var it = std.mem.split(u8, input, "\n\n");
    while (it.next()) |parts| {
        if (parts.len == 0) continue;
        var partsIt = std.mem.split(u8, parts, "\n");
        var firstNode = try Node.buildNode(allocator, partsIt.next().?);
        defer firstNode.deinit(allocator);

        var secondNode = try Node.buildNode(allocator, partsIt.next().?);
        defer secondNode.deinit(allocator);

        const rightOrder = (try Node.compareOrder(allocator, firstNode, secondNode)).?;
        _ = rightOrder;
    }
    return Solution{ .part_1 = 0, .part_2 = 0 };
}

const testing_input =
    \\[1,1,3,1,1]
    \\[1,1,5,1,1]
    \\
    \\[[1],[2,3,4]]
    \\[[1],4]
    \\
    \\[9]
    \\[[8,7,6]]
    \\
    \\[[4,4],4,4]
    \\[[4,4],4,4,4]
    \\
    \\[7,7,7,7]
    \\[7,7,7]
    \\
    \\[]
    \\[3]
    \\
    \\[[[]]]
    \\[[]]
    \\
    \\[1,[2,[3,[4,[5,6,7]]]],8,9]
    \\[1,[2,[3,[4,[5,6,0]]]],8,9]
;

test "Part 1" {
    const allocator = std.testing.allocator;
    try expectEqual(0, (try solve(allocator, testing_input)).part_1);
}

test "Part 2" {
    const allocator = std.testing.allocator;
    try expectEqual(0, (try solve(allocator, testing_input)).part_1);
}
