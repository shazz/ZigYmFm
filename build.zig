const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const libemu76489 = b.addStaticLibrary("libemu76489", null);
    libemu76489.setTarget(target);
    libemu76489.setBuildMode(mode);
    libemu76489.addIncludePath("src/libemu76489/");
    libemu76489.addCSourceFiles(&.{
        "src/libemu76489/emu76489.c",
    }, &.{
        "-Wall",
        "-std=c99"
    });

    const libemu3813 = b.addStaticLibrary("libemu3813", null);
    libemu3813.setTarget(target);
    libemu3813.setBuildMode(mode);
    libemu3813.addIncludePath("src/libemu3813/");
    libemu3813.addCSourceFiles(&.{
        "src/libemu3813/emu8950.c",
        "src/libemu3813/emuadpcm.c",
    }, &.{
        "-Wall",
        "-std=c99"
    });

    const libemu2413 = b.addStaticLibrary("libemu2413", null);
    libemu2413.setTarget(target);
    libemu2413.setBuildMode(mode);
    libemu2413.addIncludePath("src/libemu2413/");
    libemu2413.addCSourceFiles(&.{
        "src/libemu2413/emu2413.c",
    }, &.{
        "-Wall",
        "-std=c99"
    });

    const libemu2212 = b.addStaticLibrary("libemu2212", null);
    libemu2212.setTarget(target);
    libemu2212.setBuildMode(mode);
    libemu2212.addIncludePath("src/libemu2212/");
    libemu2212.addCSourceFiles(&.{
        "src/libemu2212/emu2212.c",
    }, &.{
        "-Wall",
        "-std=c99"
    });

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
        "src/libymfm/ymfmffi.cpp",
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

    exe.addIncludePath("src/libemu2212");
    exe.addLibraryPath("src/libemu2212");  
    exe.linkLibrary(libemu2212);     

    exe.addIncludePath("src/libemu2413");
    exe.addLibraryPath("src/libemu2413");  
    exe.linkLibrary(libemu2413);  

    exe.addIncludePath("src/libemu3813");
    exe.addLibraryPath("src/libemu3813");  
    exe.linkLibrary(libemu3813);  

    exe.addIncludePath("src/libemu76489");
    exe.addLibraryPath("src/libemu76489");  
    exe.linkLibrary(libemu76489);  

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);    
}