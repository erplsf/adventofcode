// TODO: solve without stupid hack (manual move of J to the first position in the enum to accommodate day 2)
const std = @import("std");
const utils = @import("utils");
const assert = std.debug.assert;

const Solution = struct {
    p1: usize,
    p2: usize,
};

const Card = enum {
    @"2",
    @"3",
    @"4",
    @"5",
    @"6",
    @"7",
    @"8",
    @"9",
    T,
    J,
    Q,
    K,
    A,

    pub fn mapFromChar(char: u8) !Card {
        return switch (char) {
            '2' => Card.@"2",
            '3' => Card.@"3",
            '4' => Card.@"4",
            '5' => Card.@"5",
            '6' => Card.@"6",
            '7' => Card.@"7",
            '8' => Card.@"8",
            '9' => Card.@"9",
            'T' => Card.T,
            'J' => Card.J,
            'Q' => Card.Q,
            'K' => Card.K,
            'A' => Card.A,
            else => return utils.AocError.InputParseProblem,
        };
    }
};

const Rank = enum {
    HC,
    OP,
    TP,
    TK,
    FH,
    FoK,
    FiK,
};

test "enum_ordering" {
    try std.testing.expect(@intFromEnum(Card.@"4") < @intFromEnum(Card.K));
    try std.testing.expect(@intFromEnum(Card.A) > @intFromEnum(Card.K));

    try std.testing.expect(@intFromEnum(Rank.FiK) > @intFromEnum(Rank.HC));
    try std.testing.expect(@intFromEnum(Rank.OP) < @intFromEnum(Rank.TP));
}

const Hand = struct {
    cards: [5]Card,
    rank: Rank,
    bid: usize,

    pub fn build(input: []const u8) !Hand {
        var hand = Hand{
            .cards = undefined,
            .rank = undefined,
            .bid = undefined,
        };

        var parts_it = utils.splitByChar(input, ' ');
        const hand_text = parts_it.next() orelse return utils.AocError.InputParseProblem;
        const bid_text = parts_it.next() orelse return utils.AocError.InputParseProblem;

        for (hand_text, 0..) |char, i| hand.cards[i] = try Card.mapFromChar(char);

        hand.bid = try std.fmt.parseUnsigned(usize, bid_text, 10);

        return hand;
    }

    pub fn calculateRank(self: *const Hand, allocator: std.mem.Allocator, jokers: bool) !Rank {
        var counts = std.AutoArrayHashMap(Card, usize).init(allocator);
        defer counts.deinit();

        for (self.cards) |card| {
            const v = try counts.getOrPutValue(card, 0);
            v.value_ptr.* += 1;
        }

        const C = struct {
            values: []usize,

            pub fn lessThan(ctx: @This(), a_index: usize, b_index: usize) bool {
                return ctx.values[a_index] > ctx.values[b_index];
            }
        };

        counts.sort(C{ .values = counts.values() });

        if (jokers and counts.count() > 1) {
            if (counts.get(Card.J)) |jokers_count| {
                _ = counts.orderedRemove(Card.J);
                counts.values()[0] += jokers_count;
            }
        }

        const values = counts.values();

        switch (counts.count()) {
            1 => return Rank.FiK,
            2 => {
                switch (values[0]) {
                    4 => return Rank.FoK,
                    3 => return Rank.FH,
                    else => return utils.AocError.InputParseProblem,
                }
            },
            3 => {
                switch (values[0]) {
                    3 => return Rank.TK,
                    2 => return Rank.TP,
                    else => return utils.AocError.InputParseProblem,
                }
            },
            4 => return Rank.OP,
            5 => return Rank.HC,
            else => return utils.AocError.InputParseProblem,
        }

        // var cIt = counts.iterator();
        // while (cIt.next()) |pair| {
        //     std.debug.print("{} {}\n", .{ pair.key_ptr.*, pair.value_ptr.* });
        // }
    }
};

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !Solution {
    var lines_it = utils.splitByChar(input, '\n');
    var hands = std.ArrayList(Hand).init(allocator);
    defer hands.deinit();

    while (lines_it.next()) |line| {
        if (line.len == 0) continue;

        var hand = try Hand.build(line);
        hand.rank = try hand.calculateRank(allocator, false);
        try hands.append(hand);
        // std.debug.print("{any}\n", .{hand});
    }

    const C = struct {
        pub fn lessThan(context: void, lhs: Hand, rhs: Hand) bool {
            _ = context; // autofix
            if (@intFromEnum(lhs.rank) < @intFromEnum(rhs.rank)) return true;
            if (@intFromEnum(lhs.rank) > @intFromEnum(rhs.rank)) return false;

            for (0..5) |i| {
                if (@intFromEnum(lhs.cards[i]) < @intFromEnum(rhs.cards[i])) return true;
                if (@intFromEnum(lhs.cards[i]) > @intFromEnum(rhs.cards[i])) return false;
            }

            return false;
        }
    };

    std.sort.insertion(Hand, hands.items, {}, C.lessThan);
    // std.debug.print("{any}\n", .{hands.items});

    var winnings_p1: usize = 0;
    for (hands.items, 1..) |hand, rank| {
        winnings_p1 += hand.bid * rank;
    }

    for (hands.items) |*hand| hand.rank = try hand.calculateRank(allocator, true);
    std.sort.insertion(Hand, hands.items, {}, C.lessThan);

    var winnings_p2: usize = 0;
    for (hands.items, 1..) |hand, rank| {
        winnings_p2 += hand.bid * rank;
    }

    return .{ .p1 = winnings_p1, .p2 = winnings_p2 };
}

const test_input =
    \\32T3K 765
    \\T55J5 684
    \\KK677 28
    \\KTJJT 220
    \\QQQJA 483
;

test "examples" {
    const results = try solve(std.testing.allocator, test_input);
    try std.testing.expectEqual(@as(usize, 6440), results.p1);
    try std.testing.expectEqual(@as(usize, 5905), results.p2);
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
