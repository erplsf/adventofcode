const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = &gpa.allocator;

    defer { // NOTE: remove check after finishing
        const leaked = gpa.deinit();
        if (leaked) std.testing.expect(false) catch @panic("TEST FAIL"); //fail test; can't try in defer as defer is executed after we return
    }

    const base = "src/";
    const opts = .{ .access_sub_paths = true, .iterate = true, .no_follow = true };
    const src = try std.fs.cwd().openDir(base, opts);

    var walker = try src.walk(alloc);
    defer walker.deinit();

    while (try walker.next()) |entry| {
        if (std.mem.endsWith(u8, entry.path, "main.zig")) {
            std.debug.print("building: {s}\n", .{entry.path});

            const fullPath = try std.fmt.allocPrint(alloc, "{s}{s}", .{ base, entry.path });
            const exe = b.addExecutable("main", fullPath);
            alloc.free(fullPath);

            exe.setTarget(target);
            exe.setBuildMode(mode);

            const dir = try exe.install_step;
            std.debug.print("{s}\n", .{dir});

            exe.install();
        }
    }

    // const exe = b.addExecutable("zig", "src/main.zig");
    // exe.setTarget(target);
    // exe.setBuildMode(mode);
    // exe.install();

    // const run_cmd = exe.run();
    // run_cmd.step.dependOn(b.getInstallStep());
    // if (b.args) |args| {
    //     run_cmd.addArgs(args);
    // }

    // const run_step = b.step("run", "Run the app");
    // run_step.dependOn(&run_cmd.step);
}
