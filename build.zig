const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libemu76489 = b.addStaticLibrary( .{
        .name = "libemu76489",
        .target = target,
        .optimize = optimize,
    });
    libemu76489.addIncludePath("src/libemu76489/");
    libemu76489.addCSourceFiles(&.{
        "src/libemu76489/emu76489.c",
    }, &.{
        "-Wall",
        "-std=c99"
    });

    const libemu3813 = b.addStaticLibrary( .{
        .name = "libemu3813",
        .target = target,
        .optimize = optimize,
    });
    libemu3813.addIncludePath("src/libemu3813/");
    libemu3813.addCSourceFiles(&.{
        "src/libemu3813/emu8950.c",
        "src/libemu3813/emuadpcm.c",
    }, &.{
        "-Wall",
        "-std=c99"
    });

    const libemu2413 = b.addStaticLibrary( .{
        .name = "libemu2413",
        .target = target,
        .optimize = optimize,
    });
    libemu2413.addIncludePath("src/libemu2413/");
    libemu2413.linkLibC();
    libemu2413.linkSystemLibrary("m");
    libemu2413.addCSourceFiles(&.{
        "src/libemu2413/emu2413.c",
    }, &.{
        "-Wall",
        "-std=c99"        
    });

    const libemu2212 = b.addStaticLibrary( .{
        .name = "libemu2212",
        .target = target,
        .optimize = optimize,
    });
    libemu2212.addIncludePath("src/libemu2212/");
    libemu2212.addCSourceFiles(&.{
        "src/libemu2212/emu2212.c",
    }, &.{
        "-Wall",
        "-std=c99"
    });

    const libemu2149 = b.addStaticLibrary( .{
        .name = "libemu2149",
        .target = target,
        .optimize = optimize,
    });
    libemu2149.addIncludePath("src/libemu2149/");
    libemu2149.addCSourceFiles(&.{
        "src/libemu2149/emu2149.c",
    }, &.{
        "-Wall",
        "-std=c99"
    });

    const libymfm = b.addStaticLibrary( .{
        .name = "libymfm",
        .target = target,
        .optimize = optimize,
    });
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

    const exe = b.addExecutable( .{
        .name = "main",
        .root_source_file = .{
            .path = "src/main.zig",
        },        
        .target = target,
        .optimize = optimize
    });
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