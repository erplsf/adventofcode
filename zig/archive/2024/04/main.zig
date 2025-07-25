const std = @import("std");

const word = "XMAS";
const mword = "MAS";

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !struct { p1: usize, p2: usize } {
    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    var rows: usize = 0;
    var cols: usize = 0;
    var first_run = true;
    while (line_it.next()) |line| : (rows += 1) {
        if (first_run) {
            first_run = false;
            cols = line.len;
        }
    }

    line_it.reset();

    var map: [][]u8 = undefined;
    map = try allocator.alloc([]u8, rows);
    {
        var ri: usize = 0;
        while (line_it.next()) |line| : (ri += 1) {
            map[ri] = try allocator.alloc(u8, cols);
            for (line, 0..) |char, ci| map[ri][ci] = char;
        }
    }

    defer {
        for (map) |row| allocator.free(row);
        allocator.free(map);
    }

    // for (map) |row| {
    //     std.debug.print("{s}\n", .{row});
    // }

    var word_count: usize = 0;
    var mword_count: usize = 0;
    const map_slice = try allocator.alloc(u8, word.len);
    defer allocator.free(map_slice);
    const mmap_slice = try allocator.alloc(u8, mword.len);
    defer allocator.free(mmap_slice);
    for (map, 0..) |row, ri| {
        for (row, 0..) |ch, ci| {
            // part 1
            if (ch == 'X') {
                // left-to-right
                const ltr = row.len - ci >= word.len;
                // right-to-left
                const rtl = ci >= word.len - 1;
                // top-to-down
                const ttd = map.len - ri >= word.len;
                // down-to-top
                const dtt = ri >= word.len - 1;
                if (ltr) {
                    // straight check
                    if (std.mem.eql(u8, map[ri][ci .. ci + word.len], word)) word_count += 1;
                }
                if (rtl) {
                    // copy in reverse order
                    @memcpy(map_slice, &[4]u8{
                        map[ri][ci],
                        map[ri][ci - 1],
                        map[ri][ci - 2],
                        map[ri][ci - 3],
                    });
                    if (std.mem.eql(u8, map_slice, word)) word_count += 1;
                }
                if (ttd) {
                    // copy top down
                    @memcpy(map_slice, &[4]u8{
                        map[ri][ci],
                        map[ri + 1][ci],
                        map[ri + 2][ci],
                        map[ri + 3][ci],
                    });
                    if (std.mem.eql(u8, map_slice, word)) word_count += 1;
                }
                if (dtt) {
                    // copy down top
                    @memcpy(map_slice, &[4]u8{
                        map[ri][ci],
                        map[ri - 1][ci],
                        map[ri - 2][ci],
                        map[ri - 3][ci],
                    });
                    if (std.mem.eql(u8, map_slice, word)) word_count += 1;
                }
                // east-south diagonal (both ltr and ttd)
                if (ltr and ttd) {
                    @memcpy(map_slice, &[4]u8{
                        map[ri][ci],
                        map[ri + 1][ci + 1],
                        map[ri + 2][ci + 2],
                        map[ri + 3][ci + 3],
                    });
                    if (std.mem.eql(u8, map_slice, word)) word_count += 1;
                }
                // west-south diagonal (both rtl and ttd)
                if (rtl and ttd) {
                    @memcpy(map_slice, &[4]u8{
                        map[ri][ci],
                        map[ri + 1][ci - 1],
                        map[ri + 2][ci - 2],
                        map[ri + 3][ci - 3],
                    });
                    if (std.mem.eql(u8, map_slice, word)) word_count += 1;
                }
                // east-north diagonal (both ltr and dtt)
                if (ltr and dtt) {
                    @memcpy(map_slice, &[4]u8{
                        map[ri][ci],
                        map[ri - 1][ci + 1],
                        map[ri - 2][ci + 2],
                        map[ri - 3][ci + 3],
                    });
                    if (std.mem.eql(u8, map_slice, word)) word_count += 1;
                }
                // west-north diagonal (both ltr and dtt)
                if (rtl and dtt) {
                    @memcpy(map_slice, &[4]u8{
                        map[ri][ci],
                        map[ri - 1][ci - 1],
                        map[ri - 2][ci - 2],
                        map[ri - 3][ci - 3],
                    });
                    if (std.mem.eql(u8, map_slice, word)) word_count += 1;
                }
            }
            // part 2
            if (ch == 'M' or ch == 'S') {
                // left-to-right
                const ltr = row.len - ci >= mword.len;
                // right-to-left
                // const rtl = ci >= mword.len - 1;
                // top-to-down
                const ttd = map.len - ri >= mword.len;
                // down-to-top
                // const dtt = ri >= mword.len - 1;
                // east-south diagonal (both ltr and ttd)
                // TODO: combine all cases into a square?
                // FIXME: it counts duplicates
                if (ch == 'M') {
                    if (ltr and ttd) {
                        if (map[ri + 1][ci + 1] == 'A' and map[ri + 2][ci + 2] == 'S') {
                            if (map[ri][ci + 2] == 'M' and map[ri + 2][ci] == 'S') { // M - M
                                mword_count += 1;
                            } else if (map[ri + 2][ci] == 'M' and map[ri][ci + 2] == 'S') { // M |v M
                                mword_count += 1;
                            }
                        }
                    }
                } else if (ch == 'S') {
                    if (ltr and ttd) {
                        if (map[ri + 1][ci + 1] == 'A' and map[ri + 2][ci + 2] == 'M') {
                            if (map[ri][ci + 2] == 'M' and map[ri + 2][ci] == 'S') { // M |v M
                                mword_count += 1;
                            } else if (map[ri + 2][ci] == 'M' and map[ri][ci + 2] == 'S') { // M - M
                                mword_count += 1;
                            }
                        }
                    }
                }
            }
        }
    }

    return .{ .p1 = word_count, .p2 = mword_count };
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
        \\MMMSXXMASM
        \\MSAMXMSMSA
        \\AMXSXMAAMM
        \\MSAMASMSMX
        \\XMASAMXAMM
        \\XXAMMXXAMA
        \\SMSMSASXSS
        \\SAXAMASAAA
        \\MAMMMXMMMM
        \\MXMXAXMASX
    ;
    const answers = try solve(std.testing.allocator, input);
    try std.testing.expectEqual(@as(usize, 18), answers.p1);
    try std.testing.expectEqual(@as(usize, 9), answers.p2);
}
