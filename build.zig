const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    // This creates a "module", which represents a collection of source files alongside
    // some compilation options, such as optimization mode and linked system libraries.
    // Every executable or library we compile will be based on one or more modules.
    const lib_mod = b.createModule(.{
        // `root_source_file` is the Zig "entry point" of the module. If a module
        // only contains e.g. external object files, you can make this `null`.
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = b.path("lib/calculator.zig"),
        .target = target,
        .optimize = optimize,
        .pic = true,
    });

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "zig-calculator",
        .root_module = lib_mod,
    });

    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.installArtifact(lib);

    // --- Build the C Executable ---
    const exe = b.addExecutable(.{
        .name = "main_c_executable",
        .target = target,
        .optimize = optimize,
        .link_libc = true, // This will link the libc it's similar to exe.linkSystemLibrary("c");
    });
    // Add the C source file
    exe.addCSourceFile(.{ .file = b.path("src/main.c"), .flags = &.{} });
    // Explicitly link the C standard library (needed for stdio.h etc.)
    // exe.linkSystemLibrary("c");
    // Link the Zig library we just built
    exe.linkLibrary(lib);
    // Tell the C compiler where to find our header file
    exe.addIncludePath(b.path("./inc/"));
    // Also install the header file alongside the library

    // Add a binary to the ./zig-out/bin
    b.installArtifact(exe);

    // --- Add a step to run the C executable ---
    const run_cmd = b.addRunArtifact(exe);
    // This step means `zig build run` will execute the C program.
    const run_step = b.step("run", "Run the C application");
    run_step.dependOn(&run_cmd.step);

    // Make the `run` step the default, so `zig build` alone builds and runs.
    b.getInstallStep().dependOn(run_step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const lib_unit_tests = b.addTest(.{
        .root_module = lib_mod,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
