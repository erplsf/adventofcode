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

    // defer { // NOTE: remove check after finishing // TODO: fix the memory leak
    //     const leaked = gpa.deinit();
    //     if (leaked) std.testing.expect(false) catch @panic("TEST FAIL"); //fail test; can't try in defer as defer is executed after we return
    // }

    const base = "src/";
    const opts = .{ .access_sub_paths = true, .iterate = true, .no_follow = true };
    const src = try std.fs.cwd().openDir(base, opts);

    var walker = try src.walk(alloc);
    defer walker.deinit();

    while (try walker.next()) |entry| {
        // std.debug.print("found: {s}\n", .{entry.path});
        if (std.mem.endsWith(u8, entry.path, "main.zig")) {
            var valid = true;
            var iter = std.mem.split(u8, entry.path, "/");
            var i: u8 = 0;
            var exe_path: []const u8 = undefined;
            var free_path = false;
            var exe_name: []const u8 = undefined;
            var free_name = false;

            while (iter.next()) |part| {
                // std.debug.print("part: {s}\n", .{part});
                if (i == 0) { // TODO: use switch
                    exe_path = try std.fmt.allocPrint(alloc, "bin/{s}", .{part});
                    free_path = true;
                }
                if (i == 1) {
                    exe_name = try std.fmt.allocPrint(alloc, "{s}", .{part});
                    free_name = true;
                }
                if (i == 2 and !std.mem.eql(u8, "main.zig", part)) {
                    valid = false;
                }
                i += 1;
                // TODO: add all but last parts to the final path
            }

            if (valid) {
                std.debug.print("building: {s}/{s} -> {s}/{s}/{s}\n", .{ "src", entry.path, "zig-out", exe_path, exe_name });
                // std.debug.print("{s}\n", .{ exe_path });
                // std.debug.print("{s}\n", .{ exe_name });
                const fullPath = try std.fmt.allocPrint(alloc, "{s}{s}", .{ base, entry.path });
                const exe = b.addExecutable(exe_name, fullPath);
                alloc.free(fullPath);

                exe.addPackagePath("lib", "src/lib.zig");

                exe.override_dest_dir = .{ .custom = exe_path };

                exe.setTarget(target);
                exe.setBuildMode(mode);

                exe.install();
            }

            // if (free_path) {
            //     alloc.free(exe_path); // TODO: fix the memory leak
            // }
            // if (free_name ) {
            //     alloc.free(exe_name);
            // }
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
