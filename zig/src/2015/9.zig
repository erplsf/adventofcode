const std = @import("std");
const aoc = @import("aoc");
const pm = @import("pm");
const Allocator = std.mem.Allocator;
const expectEqual = aoc.expectEqual;

pub const log_level: std.log.Level = .debug; // always print info level messages and above (std.log.info is fast enough for our purposes)

// HINT: use dumb permutations

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input = try aoc.readFile(allocator);
    defer allocator.free(input);

    const answer = try solve(input, allocator);
    std.log.info("Part 1: {d}", .{answer.part_1});
    std.log.info("Part 2: {d}", .{answer.part_2});
}

const Solution = aoc.Solution(usize, usize);

const Pair = struct {
    from: []const u8,
    to: []const u8,
};

const PairContext = struct {
    pub fn eqlString(a: []const u8, b: []const u8) bool {
        return std.mem.eql(u8, a, b);
    }

    pub fn hash(self: @This(), s: Pair) u64 {
        _ = self;

        var hasher = std.hash.Wyhash.init(0);
        hasher.update(s.from);
        hasher.update(s.to);

        return hasher.final();
    }
    pub fn eql(self: @This(), a: Pair, b: Pair) bool {
        _ = self;
        return eqlString(a.from, b.from) and eqlString(a.to, b.to);
    }
};

fn solve(input: []const u8, allocator: Allocator) !Solution {
    var distances = std.HashMap(Pair, usize, PairContext, 80).init(allocator);
    defer distances.deinit();

    var it = std.mem.split(u8, input, "\n");
    while (it.next()) |line| {
        if (line.len == 0) break;

        var parts = std.mem.split(u8, line, "=");
        var cities_pair = std.mem.trim(u8, parts.next().?, " ");
        var distance_string = std.mem.trim(u8, parts.next().?, " ");
        var distance = try std.fmt.parseUnsigned(usize, distance_string, 10);

        var cities_it = std.mem.split(u8, cities_pair, "to");
        var from = std.mem.trim(u8, cities_it.next().?, " ");
        var to = std.mem.trim(u8, cities_it.next().?, " ");

        // std.log.debug("{s} -> {s}: {d}", .{from, to, distance});

        try distances.put(.{.from = from, .to = to}, distance);
        try distances.put(.{.from = to, .to = from}, distance);
    }

    var pms = pm.Permutations([]const u8).init(allocator);
    defer pms.deinit();

    var cities_hash_map = std.StringHashMap(void).init(allocator);
    defer cities_hash_map.deinit();

    var kit = distances.keyIterator();
    while(kit.next()) |key| {
        try cities_hash_map.put(key.from, .{});
    }

    var cities = std.ArrayList([]const u8).init(allocator);
    defer cities.deinit();

    var khmit = cities_hash_map.keyIterator();
    while(khmit.next()) |key| {
        // std.log.debug("city: {s} ", .{key.*});
        try cities.append(key.*);
    }

    // for(cities.items) |city| {
    //     std.log.debug("city: {s} ", .{city});
    // }

    try pms.permute(cities.items);

    var min_sum: usize = std.math.maxInt(usize);
    var max_sum: usize = 0;
    for(pms.items.items) |perm| {
        var i: usize = 0;
        var sum: usize = 0;
        while(i < perm.len - 1): (i += 1) {
            // std.log.debug("{s} -> {s} ", .{perm[i], perm[i+1]});
            sum += distances.get(.{.from = perm[i], .to = perm[i+1]}).?;
        }
        if (sum < min_sum) min_sum = sum;
        if (sum > max_sum) max_sum = sum;
        // std.log.debug("distance: {d}", .{sum});
    }

    return Solution{.part_1 = min_sum, .part_2 = max_sum};
}

test "Part 1" {
    const input =
        \\London to Dublin = 464
        \\London to Belfast = 518
        \\Dublin to Belfast = 141
    ;
    var sol = try solve(input, std.testing.allocator);
    try expectEqual(605, sol.part_1);
}

test "Part 2" {
    const input =
        \\London to Dublin = 464
        \\London to Belfast = 518
        \\Dublin to Belfast = 141
    ;
    var sol = try solve(input, std.testing.allocator);
    try expectEqual(982, sol.part_2);
}
