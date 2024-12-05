const std = @import("std");

const Ordering = struct {
    before: std.ArrayListUnmanaged(usize) = .{},
    after: std.ArrayListUnmanaged(usize) = .{},

    pub fn deinit(self: *Ordering, allocator: std.mem.Allocator) void {
        self.before.deinit(allocator);
        self.after.deinit(allocator);
    }
};

const Mapping = struct {
    allocator: std.mem.Allocator,
    map: std.AutoHashMapUnmanaged(usize, Ordering) = .{},

    pub fn addOrdering(self: *Mapping, rule_line: []const u8) !void {
        var parts_it = std.mem.tokenizeScalar(u8, rule_line, '|');
        const before = try std.fmt.parseUnsigned(usize, parts_it.next().?, 10);
        const after = try std.fmt.parseUnsigned(usize, parts_it.next().?, 10);

        var bOrdering = try self.getOrdering(before);
        try bOrdering.after.append(self.allocator, after);

        var aOrdering = try self.getOrdering(after);
        try aOrdering.before.append(self.allocator, before);
    }

    pub fn getOrdering(self: *Mapping, number: usize) !*Ordering {
        const entry = try self.map.getOrPutValue(self.allocator, number, .{});
        return entry.value_ptr;
    }

    pub fn checkSequence(self: *Mapping, sequence_line: []const u8) !?usize {
        var n_it = std.mem.tokenizeScalar(u8, sequence_line, ',');
        var numbers = std.ArrayListUnmanaged(usize){};
        defer numbers.deinit(self.allocator);
        while (n_it.next()) |n_text| {
            const n = try std.fmt.parseUnsigned(usize, n_text, 10);
            try numbers.append(self.allocator, n);
        }
        for (numbers.items, 0..) |n, idx| {
            const ordering = try self.getOrdering(n);
            const n_before = numbers.items[0..idx];
            const n_after = numbers.items[@min(idx + 1, numbers.items.len - 1)..numbers.items.len];

            if (std.mem.indexOfAny(usize, n_before, ordering.after.items)) |_| return null;
            if (std.mem.indexOfAny(usize, n_after, ordering.before.items)) |_| return null;
        }
        const midx = numbers.items.len / 2;
        return numbers.items[midx];
    }

    pub fn checkAndFixSequence(self: *Mapping, sequence_line: []const u8) !usize {
        var n_it = std.mem.tokenizeScalar(u8, sequence_line, ',');
        var numbers = std.ArrayListUnmanaged(usize){};
        defer numbers.deinit(self.allocator);
        while (n_it.next()) |n_text| {
            const n = try std.fmt.parseUnsigned(usize, n_text, 10);
            try numbers.append(self.allocator, n);
        }
        var valid = false;
        while (!valid) {
            std.log.debug("in valid loop!\n", .{});
            restart: for (numbers.items, 0..) |n, idx| {
                const ordering = try self.getOrdering(n);
                const n_before = numbers.items[0..idx];
                const n_after = numbers.items[@min(idx + 1, numbers.items.len - 1)..numbers.items.len];

                std.log.debug("n: {}\n", .{n});
                std.log.debug("ordering: {}\n", .{ordering});
                std.log.debug("n_before: {any}\n", .{n_before});
                std.log.debug("n_after: {any}\n", .{n_after});

                if (std.mem.indexOfAny(usize, n_before, ordering.after.items)) |pos| {
                    std.log.debug("ba swapping {} and {}\n", .{ numbers.items[idx], numbers.items[pos] });
                    std.mem.swap(usize, &numbers.items[idx], &n_before[pos]);
                    break :restart;
                }
                // FIXME: seems broken
                if (std.mem.indexOfAny(usize, n_after, ordering.before.items)) |pos| {
                    std.log.debug("ab swapping {} and {}\n", .{ numbers.items[idx], numbers.items[pos] });
                    std.mem.swap(usize, &numbers.items[idx], &n_after[pos]);
                    break :restart;
                }
            } else {
                valid = true;
            }
        }
        std.log.debug("fl: {any}\n", .{numbers.items});
        const midx = numbers.items.len / 2;
        return numbers.items[midx];
    }

    pub fn deinit(self: *Mapping) void {
        var it = self.map.valueIterator();
        while (it.next()) |v| v.deinit(self.allocator);

        self.map.deinit(self.allocator);
    }
};

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !struct { p1: usize, p2: usize } {
    var line_it = std.mem.splitScalar(u8, input, '\n');

    var parsing_rules = true;
    var parsing_sequences = false;

    var map: Mapping = .{ .allocator = allocator };
    defer map.deinit();

    var midpoint_sum: usize = 0;
    var fixed_midpoint_sum: usize = 0;
    while (line_it.next()) |line| {
        if (line.len == 0) {
            parsing_rules = false;
            parsing_sequences = true;
            continue;
        }

        if (parsing_rules) {
            try map.addOrdering(line);
            // std.log.debug("r: {s}\n", .{line});
        } else if (parsing_sequences) {
            if (try map.checkSequence(line)) |midpoint| {
                midpoint_sum += midpoint;
                // std.log.debug("valid!\n", .{});
            } else {
                std.log.debug("s: {s}\n", .{line});
                std.log.debug("not valid!\n", .{});
                const fixed_midpoint = try map.checkAndFixSequence(line);
                std.log.debug("f: {}\n", .{fixed_midpoint});
                fixed_midpoint_sum += fixed_midpoint;
            }
        }
    }

    return .{ .p1 = midpoint_sum, .p2 = fixed_midpoint_sum };
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
        \\47|53
        \\97|13
        \\97|61
        \\97|47
        \\75|29
        \\61|13
        \\75|53
        \\29|13
        \\97|29
        \\53|29
        \\61|53
        \\97|53
        \\61|29
        \\47|13
        \\75|47
        \\97|75
        \\47|61
        \\75|61
        \\47|29
        \\75|13
        \\53|13
        \\
        \\75,47,61,53,29
        \\97,61,53,29,13
        \\75,29,13
        \\75,97,47,61,53
        \\61,13,29
        \\97,13,75,29,47
    ;
    const answers = try solve(std.testing.allocator, input);
    try std.testing.expectEqual(@as(usize, 143), answers.p1);
    try std.testing.expectEqual(@as(usize, 123), answers.p2);
}
