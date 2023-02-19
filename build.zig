const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const libemu2149 = b.addStaticLibrary("libemu2149", null);
    libemu2149.setTarget(target);
    libemu2149.setBuildMode(mode);
    libemu2149.addIncludePath("src/libemu2149/");
    libemu2149.addCSourceFiles(&.{
        "src/libemu2149/emu2149.c",
    }, &.{
        "-Wall",
        "-std=c99"
    });

    const libymfm = b.addStaticLibrary("libymfm", null);
    libymfm.setTarget(target);
    libymfm.setBuildMode(mode);
    libymfm.linkLibCpp();
    libymfm.addIncludePath("src/libymfm/");
    libymfm.addCSourceFiles(&.{
        "src/libymfm/ymfm_misc.cpp",
        "src/libymfm/ymfm_opl.cpp",
        "src/libymfm/ymfm_opm.cpp",
        "src/libymfm/ymfm_opn.cpp",  
        "src/libymfm/ymfm_opq.cpp", 
        "src/libymfm/ymfm_opz.cpp", 
        "src/libymfm/ymfm_adpcm.cpp", 
        "src/libymfm/ymfm_pcm.cpp", 
        "src/libymfm/ymfm_ssg.cpp",
        "src/ymfmffi.cpp",
    }, &.{
        "-std=c++14",
    });

    const exe = b.addExecutable("main", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();   
    exe.addIncludePath("src");
    exe.addLibraryPath("src");

    exe.addIncludePath("src/libymfm");
    exe.addLibraryPath("src/libymfm");
    exe.linkLibrary(libymfm); 

    exe.addIncludePath("src/libemu2149");
    exe.addLibraryPath("src/libemu2149");  
    exe.linkLibrary(libemu2149); 

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);    
}