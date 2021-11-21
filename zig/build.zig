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
        std.debug.print("found: {s}\n", .{entry.path});
        if (std.mem.endsWith(u8, entry.path, "main.zig")) {
            std.debug.print("building: {s}\n", .{entry.path});

            const fullPath = try std.fmt.allocPrint(alloc, "{s}{s}", .{ base, entry.path });
            const exe = b.addExecutable("main", fullPath);
            alloc.free(fullPath);

            var iter = std.mem.split(u8, entry.path, "/");
            while(iter.next()) |part| {
                std.debug.print("part: {s}\n", .{part});
            }

            exe.setTarget(target);
            exe.setBuildMode(mode);

            exe.override_dest_dir = .{ .custom = "bin/2015/" };

            // std.debug.print("{s}", .{step});
            // std.debug.print("{s}", .{dir});

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
