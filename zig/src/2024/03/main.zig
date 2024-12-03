const std = @import("std");

const State = struct {
    name: []const u8,
    transitions: std.AutoHashMapUnmanaged(u8, *const State) = .{},
    unmatched_transition: ?*State = null,

    pub fn addTransition(self: *State, allocator: std.mem.Allocator, symbol: u8, state: *const State) !void {
        try self.transitions.put(allocator, symbol, state);
    }

    pub fn addAllTransitions(self: *State, allocator: std.mem.Allocator, symbols: []const u8, state: *const State) !void {
        for (symbols) |symbol| {
            try self.addTransition(allocator, symbol, state);
        }
    }

    pub fn nextState(self: *const State, symbol: u8) ?*const State {
        return self.transitions.get(symbol);
    }

    pub fn deinit(self: *State, allocator: std.mem.Allocator) void {
        self.transitions.deinit(allocator);
    }
};

const MachineError = error{
    MachineStuck,
};

const Match = struct {
    pos: usize,
    text: []const u8,
};

const Command = struct {
    pos: usize,
    enable: bool,
};

const Machine = struct {
    start_state: *const State,
    current_state: *const State,
    final_state: *const State,

    input: []const u8 = undefined,
    pos: usize = 0,
    start_marker: usize = 0,
    end_marker: usize = 0,

    pub fn find(self: *Machine) !?Match {
        while (self.current_state != self.final_state) {
            while (self.pos < self.input.len) {
                // std.debug.print("cs: {s}\n", .{self.current_state.name});
                if (self.current_state == self.start_state) self.start_marker = self.pos;
                if (self.current_state == self.final_state) {
                    self.current_state = self.start_state;
                    return .{
                        .pos = self.start_marker,
                        .text = self.input[self.start_marker..self.pos],
                    };
                }

                const symbol = self.input[self.pos];
                // std.debug.print("sym: \'{c}\'\n", .{symbol});
                self.pos += 1;

                if (self.current_state.nextState(symbol)) |next_state| {
                    // std.debug.print("ns: {s}\n", .{next_state.name});
                    self.current_state = next_state;
                } else {
                    if (self.current_state.unmatched_transition) |next_state| {
                        // std.debug.print("uns: {s}\n", .{next_state.name});
                        self.current_state = next_state;
                    } else {
                        return MachineError.MachineStuck;
                    }
                }
            }
            return null;
        }
        return null;
    }
};

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !struct { p1: usize, p2: usize } {
    // std.debug.print("new\n", .{});
    var ss = State{ .name = "start" };
    defer ss.deinit(allocator);
    ss.unmatched_transition = &ss;

    var m = State{ .name = "m", .unmatched_transition = &ss };
    try ss.addTransition(allocator, 'm', &m);
    defer m.deinit(allocator);

    var u = State{ .name = "u", .unmatched_transition = &ss };
    try m.addTransition(allocator, 'u', &u);
    defer u.deinit(allocator);

    var l = State{ .name = "l", .unmatched_transition = &ss };
    try u.addTransition(allocator, 'l', &l);
    defer l.deinit(allocator);

    var ob = State{ .name = "opening_bracket", .unmatched_transition = &ss };
    try l.addTransition(allocator, '(', &ob);
    defer ob.deinit(allocator);

    var fst_number = State{ .name = "first_number", .unmatched_transition = &ss };
    try ob.addAllTransitions(allocator, "123456789", &fst_number);
    try fst_number.addAllTransitions(allocator, "1234567890", &fst_number);
    defer fst_number.deinit(allocator);

    var comma = State{ .name = "comma", .unmatched_transition = &ss };
    try fst_number.addTransition(allocator, ',', &comma);
    defer comma.deinit(allocator);

    var snd_number = State{ .name = "second_number", .unmatched_transition = &ss };
    try comma.addAllTransitions(allocator, "123456789", &snd_number);
    try snd_number.addAllTransitions(allocator, "1234567890", &snd_number);
    defer snd_number.deinit(allocator);

    var closing_bracket = State{ .name = "closing_bracket", .unmatched_transition = &ss };
    try snd_number.addTransition(allocator, ')', &closing_bracket);
    defer closing_bracket.deinit(allocator);

    var mul_machine = Machine{ .start_state = &ss, .current_state = &ss, .final_state = &closing_bracket };
    mul_machine.input = input;

    var dss = State{ .name = "start" };
    defer dss.deinit(allocator);
    dss.unmatched_transition = &dss;

    var d = State{ .name = "d", .unmatched_transition = &dss };
    try dss.addTransition(allocator, 'd', &d);
    defer d.deinit(allocator);

    var o = State{ .name = "o", .unmatched_transition = &dss };
    try d.addTransition(allocator, 'o', &o);
    defer o.deinit(allocator);

    var dob = State{ .name = "opening_bracket", .unmatched_transition = &dss };
    try o.addTransition(allocator, '(', &dob);
    defer dob.deinit(allocator);

    var dcb = State{ .name = "closing_bracket", .unmatched_transition = &dss };
    try dob.addTransition(allocator, ')', &dcb);
    defer dcb.deinit(allocator);

    var n = State{ .name = "n", .unmatched_transition = &dss };
    try o.addTransition(allocator, 'n', &n);
    defer n.deinit(allocator);

    var apostrophe = State{ .name = "apostrophe", .unmatched_transition = &dss };
    try n.addTransition(allocator, '\'', &apostrophe);
    defer apostrophe.deinit(allocator);

    var t = State{ .name = "t", .unmatched_transition = &dss };
    try apostrophe.addTransition(allocator, 't', &t);
    try t.addTransition(allocator, '(', &dob);
    defer t.deinit(allocator);

    var do_or_dont_machine = Machine{ .start_state = &dss, .current_state = &dss, .final_state = &dcb };
    do_or_dont_machine.input = input;

    var commands = std.ArrayListUnmanaged(Command){};
    defer commands.deinit(allocator);

    while (try do_or_dont_machine.find()) |match| {
        var enable: bool = undefined;
        if (std.mem.eql(u8, match.text, "do()")) {
            enable = true;
        } else if (std.mem.eql(u8, match.text, "don't()")) {
            enable = false;
        } else {
            @panic("unknown state received!");
        }
        try commands.append(allocator, .{ .pos = match.pos, .enable = enable });
    }
    // std.debug.print("{any}\n", .{commands.items});

    var sum: usize = 0;
    var second_sum: usize = 0;
    while (try mul_machine.find()) |match| {
        // std.debug.print("match: {s}\n", .{match.text});
        const numbers_with_comma = match.text[4 .. match.text.len - 1];
        var it = std.mem.splitScalar(u8, numbers_with_comma, ',');
        const fst = try std.fmt.parseUnsigned(usize, it.next().?, 10);
        const snd = try std.fmt.parseUnsigned(usize, it.next().?, 10);
        const res = fst * snd;
        sum += res;

        // std.debug.print("pos: {}\n", .{match.pos});
        if (is_command_enabled(match.pos, commands.items)) {
            // std.debug.print("enabled: {s}\n", .{match.text});
            second_sum += res;
        }
    }

    return .{ .p1 = sum, .p2 = second_sum };
}

pub fn is_command_enabled(pos: usize, command_slice: []const Command) bool {
    for (0..command_slice.len) |i| {
        if (pos > command_slice[command_slice.len - i - 1].pos) {
            return command_slice[command_slice.len - i - 1].enable;
        }
    }
    return true;
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
    var answers = try solve(std.testing.allocator, "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))");
    try std.testing.expectEqual(@as(usize, 161), answers.p1);
    try std.testing.expectEqual(@as(usize, 161), answers.p2);

    answers = try solve(std.testing.allocator, "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))");
    try std.testing.expectEqual(@as(usize, 161), answers.p1);
    try std.testing.expectEqual(@as(usize, 48), answers.p2);
}
