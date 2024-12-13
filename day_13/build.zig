const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{ .name = "main", .root_source_file = b.path("main.zig"), .target = b.host, .optimize = optimize });

    b.installArtifact(exe);
}
