const std = @import("std");
const utils = @import("utils");
const assert = std.debug.assert;

const Solution = struct {
    p1: usize,
    p2: usize,
};

const Step = enum {
    Left,
    Right,
};

const Pair = struct { []const u8, []const u8 };

const Network = struct {
    nodes: std.StringHashMap(Pair),

    pub fn init(allocator: std.mem.Allocator) Network {
        const nodes = std.StringHashMap(Pair).init(allocator);
        return .{
            .nodes = nodes,
        };
    }

    pub fn deinit(self: *Network) void {
        self.nodes.deinit();
    }

    pub fn move(self: *const Network, position: []const u8, step: Step) ![]const u8 {
        const node = self.nodes.get(position).?;
        return switch (step) {
            .Left => node[0],
            .Right => node[1],
        };
    }

    pub fn addNode(self: *Network, node: []const u8, pair: Pair) !void {
        try self.nodes.put(node, pair);
    }

    pub fn countStepsTillZ(self: *const Network, start_node: []const u8, instructions: []Step) !usize {
        var step_count: usize = 0;
        var current_position = start_node;
        while (current_position[2] != 'Z') : (step_count += 1) {
            const current_instruction_index = step_count % instructions.len;
            const step = instructions[current_instruction_index];

            current_position = try self.move(current_position, step);
        }
        return step_count;
    }

    pub fn gatherAllANodes(self: *const Network, allocator: std.mem.Allocator) !std.ArrayList([]const u8) {
        var nodes = std.ArrayList([]const u8).init(allocator);
        errdefer nodes.deinit();

        var key_it = self.nodes.keyIterator();
        while (key_it.next()) |key| {
            if (key.*[2] == 'A') try nodes.append(key.*);
        }

        return nodes;
    }
};

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !Solution {
    var lines_it = utils.splitByChar(input, '\n');

    var instructions = std.ArrayList(Step).init(allocator);
    defer instructions.deinit();

    var network = Network.init(allocator);
    defer network.deinit();

    const instructions_part = lines_it.next() orelse return utils.AocError.InputParseProblem;

    for (instructions_part) |instruction_char| {
        const step: Step = switch (instruction_char) {
            'L' => .Left,
            'R' => .Right,
            else => return utils.AocError.InputParseProblem,
        };

        try instructions.append(step);
    }

    _ = lines_it.next(); // skip empty line

    while (lines_it.next()) |line| {
        if (line.len == 0) continue;

        var line_it = utils.splitByChar(line, '=');
        var node_part = line_it.next() orelse return utils.AocError.InputParseProblem;
        node_part = std.mem.trimRight(u8, node_part, " ");

        var pair_part = line_it.next() orelse return utils.AocError.InputParseProblem;
        pair_part = std.mem.trim(u8, pair_part, " ()");
        // std.debug.print("pair part: {s}\n", .{pair_part});

        var pair_it = utils.splitByChar(pair_part, ',');
        const left_node = pair_it.next() orelse return utils.AocError.InputParseProblem;
        var right_node = pair_it.next() orelse return utils.AocError.InputParseProblem;
        right_node = std.mem.trimLeft(u8, right_node, " ");
        const pair = Pair{ left_node, right_node };
        // std.debug.print("node: {s}, pair: {s}, {s}\n", .{ node_part, pair[0], pair[1] });
        try network.addNode(node_part, pair);
    }

    // const step_count = try network.countStepsTillZ("AAA", instructions.items);

    var all_a_nodes = try network.gatherAllANodes(allocator);
    defer all_a_nodes.deinit();

    // std.debug.print("{s}\n", .{all_a_nodes.items});

    var step_counts = try allocator.alloc(usize, all_a_nodes.items.len);
    defer allocator.free(step_counts);

    for (0..step_counts.len) |i| {
        step_counts[i] = try network.countStepsTillZ(all_a_nodes.items[i], instructions.items);
    }

    // std.debug.print("step_counts: {any}\n", .{step_counts});

    const aaa_pos: usize = for (0..all_a_nodes.items.len) |i| {
        if (std.mem.eql(u8, all_a_nodes.items[i], "AAA")) break i;
    } else return utils.AocError.InputParseProblem;
    const aaa_step_count = step_counts[aaa_pos];

    var total_step_count: usize = step_counts[0];
    for (1..step_counts.len) |i| {
        const gcd = std.math.gcd(total_step_count, step_counts[i]);
        const lcm = total_step_count * (step_counts[i] / gcd);
        total_step_count = lcm;
    }

    return .{ .p1 = aaa_step_count, .p2 = total_step_count };
}

const test_input_one =
    \\RL
    \\
    \\AAA = (BBB, CCC)
    \\BBB = (DDD, EEE)
    \\CCC = (ZZZ, GGG)
    \\DDD = (DDD, DDD)
    \\EEE = (EEE, EEE)
    \\GGG = (GGG, GGG)
    \\ZZZ = (ZZZ, ZZZ)
;

const test_input_two =
    \\LLR
    \\
    \\AAA = (BBB, BBB)
    \\BBB = (AAA, ZZZ)
    \\ZZZ = (ZZZ, ZZZ)
;

const test_input_three =
    \\LLR
    \\
    \\AAA = (BBB, BBB)
    \\BBB = (AAA, ZZZ)
    \\ZZZ = (ZZZ, ZZZ)
;

test "examples" {
    const results_one = try solve(std.testing.allocator, test_input_one);
    try std.testing.expectEqual(@as(usize, 2), results_one.p1);
    try std.testing.expectEqual(@as(usize, 2), results_one.p2);

    const results_two = try solve(std.testing.allocator, test_input_two);
    try std.testing.expectEqual(@as(usize, 6), results_two.p1);
    try std.testing.expectEqual(@as(usize, 6), results_two.p2);
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
