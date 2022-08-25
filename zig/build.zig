const std = @import("std");

const solutions = [_][]const u8{
    "1",
    // "2",
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

    var tests = std.ArrayList(*std.build.LibExeObjStep).init(allocator);
    defer tests.deinit();

    for (solutions) |day| {
        const name = try std.fmt.allocPrint(allocator, "2015-{s}", .{day});
        defer allocator.free(name);
        const path = try std.fmt.allocPrint(allocator, "src/2015/{s}.zig", .{day});
        defer allocator.free(path);

        const exe = b.addExecutable(name, path);
        exe.addPackagePath("aoc", "src/aoc.zig");
        exe.setTarget(target);
        exe.setBuildMode(mode);
        exe.install();

        const run_cmd = exe.run();
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step_name = try std.fmt.allocPrint(allocator, "2015-{s}", .{day});
        defer allocator.free(run_step_name);
        const run_step = b.step(run_step_name, "Run the app");
        run_step.dependOn(&run_cmd.step);

        const exe_tests = b.addTest(path);
        exe_tests.addPackagePath("aoc", "src/aoc.zig");
        exe_tests.setTarget(target);
        exe_tests.setBuildMode(mode);
        try tests.append(exe_tests);
    }


    const test_step = b.step("test", "Run unit tests");
    for (tests.items) |exe_test| {
        test_step.dependOn(&exe_test.step);
    }
}
