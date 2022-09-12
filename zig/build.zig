const std = @import("std");

const Solution = struct {
    year: u16,
    day: u8,
    solution_name: []const u8,
    solution_test_name: []const u8,
    relative_path: []const u8,
};

pub fn build(b: *std.build.Builder) anyerror!void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var solutions = std.ArrayList(Solution).init(allocator);
    defer {
        for (solutions.items) |solution| {
            allocator.free(solution.solution_name);
            allocator.free(solution.relative_path);
            allocator.free(solution.solution_test_name);
        }
        solutions.deinit();
    }

    var tests = std.ArrayList(*std.build.LibExeObjStep).init(allocator);
    defer tests.deinit();

    var dir = try std.fs.cwd().openDir("src", .{.iterate = true});
    defer dir.close();

    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        // std.debug.print("name: {s} kind: {}\n", .{entry.name, entry.kind});
        if (entry.kind == .Directory) {
            // entry is a year
            const year_dir_path = try std.fmt.allocPrint(allocator, "src/{s}", .{entry.name});
            defer allocator.free(year_dir_path);

            const year_dir_realpath = try std.fs.realpathAlloc(allocator, year_dir_path);
            defer allocator.free(year_dir_realpath);

            var year_dir = try std.fs.openDirAbsolute(year_dir_realpath, .{.iterate = true});
            defer year_dir.close();

            var year_iter = year_dir.iterate();
            while (try year_iter.next()) |day_entry| {
                if (day_entry.kind == .File) {
                    const year = try std.fmt.parseUnsigned(u16, entry.name, 10);
                    const day_part = std.mem.trimRight(u8, day_entry.name, ".zig");
                    const day = try std.fmt.parseUnsigned(u8, day_part, 10);
                    const solution_name = try std.fmt.allocPrint(allocator, "{s}-{s}", .{entry.name, day_part});
                    const solution_test_name = try std.fmt.allocPrint(allocator, "{s}-{s}-test", .{entry.name, day_part});
                    const path = try std.fmt.allocPrint(allocator, "src/{s}/{s}", .{entry.name, day_entry.name});
                    try solutions.append(.{
                        .year = year,
                        .day = day,
                        .solution_name = solution_name,
                        .solution_test_name = solution_test_name,
                        .relative_path = path,
                    });
                }
            }
        }
    }

    for (solutions.items) |solution| {
        // std.debug.print("{d} {d} {s} {s}\n", solution);
        const exe = b.addExecutable(solution.solution_name, solution.relative_path);

        exe.addPackagePath("aoc", "src/aoc.zig");
        exe.setTarget(target);
        exe.setBuildMode(mode);
        exe.install();

        const run_cmd = exe.run();
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step(solution.solution_name, solution.solution_name);
        run_step.dependOn(&run_cmd.step);

        const exe_tests = b.addTest(solution.relative_path);
        exe_tests.addPackagePath("aoc", "src/aoc.zig");
        exe_tests.setTarget(target);
        exe_tests.setBuildMode(mode);

        const one_test_step = b.step(solution.solution_test_name, "Run unit tests");
        one_test_step.dependOn(&exe_tests.step);
        try tests.append(exe_tests);
    }

    const test_step = b.step("test", "Run unit tests");
    for (tests.items) |exe_test| {
        test_step.dependOn(&exe_test.step);
    }

    // undirected graph tests
    const ug_test = b.addTest("src/ug.zig");
    ug_test.addPackagePath("aoc", "src/aoc.zig");
    ug_test.setTarget(target);
    ug_test.setBuildMode(mode);

    const ug_test_step = b.step("ug-test", "Run UG tests");
    ug_test_step.dependOn(&ug_test.step);
}
