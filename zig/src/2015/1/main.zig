const std = @import("std");
const lib = @import("lib");

const aoc = .{ .year = "2015", .day = "1" };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = &gpa.allocator;

    const input = try lib.getInput(alloc, aoc);
    defer alloc.free(input);

    var floor: i32 = 0;
    var index: u32 = 0;
    var stop = false;

    for (input) |c| {
        if (c == '(') {
            floor += 1;
        } else if (c == ')') {
            floor -= 1;
        }
        index += 1;
        if (floor == -1 and !stop) {
            stop = true;
            std.log.info("{d}", .{index});
        }
    }

    std.log.info("{d}", .{floor});
}
