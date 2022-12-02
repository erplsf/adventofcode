const std = @import("std");
const aoc = @import("aoc");
const expectEqual = aoc.expectEqual;
const Allocator = std.mem.Allocator;

pub const log_level: std.log.Level = .info; // always print info level messages and above (std.log.info is fast enough for our purposes)
const stdout = std.io.getStdOut().writer();

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

const Move = enum {
    Rock,
    Paper,
    Scissors,
};

const Plan = struct {
    me: Move,
    opponent: Move,
};

fn solve(input: []const u8, allocator: std.mem.Allocator) !Solution {
    _ = allocator;
    var it = std.mem.split(u8, input, "\n");
    var simpleTotalScore: usize = 0;
    var totalScore: usize = 0;
    while (it.next()) |line| {
        if (line.len == 0) continue;
        const simplePlan = try parseLine(line);
        const simpleRoundScore = try calculateScore(simplePlan);
        const adjustedPlan = adjustPlan(simplePlan);
        const adjustedRoundScore = try calculateScore(adjustedPlan);
        simpleTotalScore += simpleRoundScore;
        totalScore += adjustedRoundScore;
    }
    return Solution{ .part_1 = simpleTotalScore, .part_2 = totalScore };
}

fn parseLine(line: []const u8) !Plan {
    var it = std.mem.split(u8, line, " ");

    var opponent_move_char = it.next().?;
    var opponent_move: Move = undefined;

    if (std.mem.eql(u8, opponent_move_char, "A")) {
        opponent_move = Move.Rock;
    } else if (std.mem.eql(u8, opponent_move_char, "B")) {
        opponent_move = Move.Paper;
    } else if (std.mem.eql(u8, opponent_move_char, "C")) {
        opponent_move = Move.Scissors;
    } else {
        return aoc.AocError.InputParseProblem;
    }

    var my_move_char = it.next().?;
    var my_move: Move = undefined;

    if (std.mem.eql(u8, my_move_char, "X")) {
        my_move = Move.Rock;
    } else if (std.mem.eql(u8, my_move_char, "Y")) {
        my_move = Move.Paper;
    } else if (std.mem.eql(u8, my_move_char, "Z")) {
        my_move = Move.Scissors;
    } else {
        return aoc.AocError.InputParseProblem;
    }

    return Plan{ .me = my_move, .opponent = opponent_move };
}

fn calculateScore(plan: Plan) !usize {
    var score: usize = 0;

    switch (plan.me) {
        Move.Rock => score += 1,
        Move.Paper => score += 2,
        Move.Scissors => score += 3,
    }

    if (std.meta.eql(plan, .{ .me = Move.Rock, .opponent = Move.Scissors }) or std.meta.eql(plan, .{ .me = Move.Paper, .opponent = Move.Rock }) or std.meta.eql(plan, .{ .me = Move.Scissors, .opponent = Move.Paper })) {
        score += 6;
    } // win
    else if (std.meta.eql(plan, .{ .me = Move.Rock, .opponent = Move.Rock }) or std.meta.eql(plan, .{ .me = Move.Paper, .opponent = Move.Paper }) or std.meta.eql(plan, .{ .me = Move.Scissors, .opponent = Move.Scissors })) {
        score += 3;
    } // tie
    else if (std.meta.eql(plan, .{ .me = Move.Rock, .opponent = Move.Paper }) or std.meta.eql(plan, .{ .me = Move.Paper, .opponent = Move.Scissors }) or std.meta.eql(plan, .{ .me = Move.Scissors, .opponent = Move.Rock })) {
        score += 0;
    } // loose
    else {
        unreachable;
    }

    return score;
}

fn adjustPlan(plan: Plan) Plan {
    // x - rock - loose
    // y - paper - draw
    // z - scissors - win

    return switch (plan.me) {
        Move.Rock => // loose
        switch (plan.opponent) {
            Move.Rock => |move| .{ .me = Move.Scissors, .opponent = move },
            Move.Paper => |move| .{ .me = Move.Rock, .opponent = move },
            Move.Scissors => |move| .{ .me = Move.Paper, .opponent = move },
        },
        Move.Paper => // draw
        switch (plan.opponent) {
            Move.Rock => |move| .{ .me = move, .opponent = move },
            Move.Paper => |move| .{ .me = move, .opponent = move },
            Move.Scissors => |move| .{ .me = move, .opponent = move },
        },
        Move.Scissors => // win
        switch (plan.opponent) {
            Move.Rock => |move| .{ .me = Move.Paper, .opponent = move },
            Move.Paper => |move| .{ .me = Move.Scissors, .opponent = move },
            Move.Scissors => |move| .{ .me = Move.Rock, .opponent = move },
        },
    };
}

const test_input =
    \\A Y
    \\B X
    \\C Z
;

test "Part 1" {
    const allocator = std.testing.allocator;
    try expectEqual(15, (try solve(test_input, allocator)).part_1);
}

test "Part 2" {
    const allocator = std.testing.allocator;
    try expectEqual(12, (try solve(test_input, allocator)).part_2);
}
