const std = @import("std");

const files = &[_][]const u8{
    "2024/01",
    "2024/02",
    "2024/03",
};

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    inline for (files) |path| {
        // TODO: make exetubale names a comptime calculated slice
        const exe_name = b.allocator.dupe(u8, path) catch @panic("OOM");
        defer b.allocator.free(exe_name);

        std.mem.replaceScalar(u8, exe_name, '/', '-');
        const exe = b.addExecutable(.{
            .name = exe_name,
            .root_source_file = b.path("src/" ++ path ++ "/main.zig"),
            .target = target,
            .optimize = optimize,
        });

        // const exe = b.addExecutable(.{
        //     .name = "zig",
        //     .root_source_file = b.path("src/main.zig"),
        //     .target = target,
        //     .optimize = optimize,
        // });

        // This declares intent for the executable to be installed into the
        // standard location when the user invokes the "install" step (the default
        // step when running `zig build`).

        b.installArtifact(exe);

        // This *creates* a Run step in the build graph, to be executed when another
        // step is evaluated that depends on it. The next line below will establish
        // such a dependency.

        const run_cmd = b.addRunArtifact(exe);

        // By making the run step depend on the install step, it will be run from the
        // installation directory rather than directly from within the cache directory.
        // This is not necessary, however, if the application depends on other installed
        // files, this ensures they will be present and in the expected location.
        run_cmd.step.dependOn(b.getInstallStep());

        // This allows the user to pass arguments to the application in the build
        // command itself, like this: `zig build run -- arg1 arg2 etc`
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        // This creates a build step. It will be visible in the `zig build --help` menu,
        // and can be selected like this: `zig build run`
        // This will evaluate the `run` step rather than the default, which is "install".
        const run_step = b.step(exe.name, "Run solution for the specified day");

        run_step.dependOn(&run_cmd.step);

        const exe_unit_tests = b.addTest(.{
            .root_source_file = b.path("src/" ++ path ++ "/main.zig"),
            .target = target,
            .optimize = optimize,
        });

        const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

        // Similar to creating the run step earlier, this exposes a `test` step to
        // the `zig build --help` menu, providing a way for the user to request
        // running the unit tests.

        const test_name = std.mem.concat(b.allocator, u8, &.{ "test ", exe_name }) catch @panic("OOM");
        const test_step = b.step(test_name, "Run unit tests");

        test_step.dependOn(&run_exe_unit_tests.step);
    }
}
