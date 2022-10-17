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

    const answer = try solve(allocator, input);
    defer allocator.free(answer.part_1);
    defer allocator.free(answer.part_2);
    std.log.info("Part 1: {s}", .{answer.part_1});
    std.log.info("Part 2: {s}", .{answer.part_2});
}

const Solution = aoc.Solution([]const u8, []const u8);

const ValidationResult = struct {
    error_index: usize,
    valid: bool,
};

fn validate(input: []const u8) ValidationResult {
    var error_index = input.len - 1;

    // three increasing letters
    var r1_valid: bool = false;
    {
        var i: usize = 0;
        while(i < input.len - 3): (i += 1) {
            if (r1_valid) break;
            // std.log.info("i: {d}\n", .{i});
            if (input[i+1] > input[i] and
                    input[i+1] - input[i] == 1 and
                    input[i+2] > input[i+1] and
                    input[i+2] - input[i+1] == 1) r1_valid = true;
        }
    }

    // forbidden letters
    var r2_valid: bool = true;
    if (std.mem.indexOfAny(u8, input, "iol")) |index| {
        error_index = index;
        r2_valid = false;
    }

    // two pairs
    var r3_valid: bool = false;
    {
        var pair_count: usize = 0;
        var pair_char: u8 = undefined;
        var i: usize = 0;
        // stdout.print("s: {s}\n", .{input}) catch {};
        while(i < input.len - 1): (i += 1) {
            if (r3_valid) break;
            if (input[i] == input[i+1]) {
                // stdout.print("i: {d}, input[i]: {c}, input[i+1]: {c}\n", .{i, input[i], input[i+1]}) catch {};
                if (input[i] != pair_char) {
                    pair_count += 1;
                    pair_char = input[i];
                }
                i += 1;
            }
        }
        if (pair_count >= 2) r3_valid = true;
    }

    return .{.error_index = error_index, .valid = r1_valid and r2_valid and r3_valid};
}

fn increment(input: []u8, index: ?usize) void {
    var carry = false;
    var i = index orelse input.len-1;
    while(i > 0): (i -= 1) {
        input[i] += 1;
        if (input[i] > 122) { // ascii 'z'
            carry = true;
            input[i] = 97; // ascii 'a'
        }
        if (!carry or i == 0) break;
        carry = false;
    }
}

fn upreset(input: []u8, index: usize) void {
    increment(input, index);

    var i = index + 1;
    while(i < input.len): (i += 1) {
        input[i] = 97; // ascii 'a'
    }
}

fn makeValidPassword(allocator: Allocator, input: []const u8, skip: bool) ![]u8 {
    // std.log.info("pw: {s}", .{input});
    var in = try allocator.alloc(u8, input.len);
    std.mem.copy(u8, in, input);
    var vr = validate(in);
    if (vr.valid and !skip) return in;
    while(true) {
        // try stdout.print("pw: {s}\n", .{in});
        if(vr.error_index != in.len - 1) {
            // try stdout.print("set!\n", .{});
            upreset(in, vr.error_index);
        }
        else
            increment(in, null);
        vr = validate(in);
        if (vr.valid) break;
    }
    return in;
}

fn solve(allocator: Allocator, input: []const u8) !Solution {
    var newPw = try makeValidPassword(allocator, std.mem.trim(u8, input, "\n"), false);
    var anotherPw = try makeValidPassword(allocator, newPw, true);

    return Solution{.part_1 = newPw, .part_2 = anotherPw};
}

test "Part 1" {
    const allocator = std.testing.allocator;
    try expectEqual(.{.valid = false, .error_index = 1}, validate("hijklmmn"));
    try expectEqual(.{.valid = false, .error_index = 7}, validate("abbceffg"));
    try expectEqual(.{.valid = false, .error_index = 7}, validate("abbcegjk"));
    try expectEqual(.{.valid = true, .error_index = 7}, validate("abcdffaa"));

    var pw = "abcdefgh";
    var newPw = try makeValidPassword(allocator, pw, false);
    try expectEqual(.{.valid = true, .error_index = 7}, validate(newPw));
    try std.testing.expectEqualStrings("abcdffaa", newPw);
    allocator.free(newPw);

    pw = "ghijklmn";
    newPw = try makeValidPassword(allocator, pw, false);
    defer allocator.free(newPw);
    try expectEqual(.{.valid = true, .error_index = 7}, validate(newPw));
    try std.testing.expectEqualStrings("ghjaabcc", newPw);
}

test "Part 2" {}
