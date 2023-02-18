const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const libymfm = b.addStaticLibrary("libymfm", null);
    libymfm.setTarget(target);
    libymfm.setBuildMode(mode);
    libymfm.linkLibCpp();
    libymfm.addIncludePath("./src/libymfm/");
    libymfm.addCSourceFiles(&.{
        "./src/libymfm/ymfm_misc.cpp",
        "./src/lbymfm/ymfm_opl.cpp",
        "./src/lbymfm/ymfm_opm.cpp",
        "./src/lbymfm/ymfm_opn.cpp",  
        "./src/lbymfm/ymfm_opq.cpp", 
        "./src/lbymfm/ymfm_opz.cpp", 
        "./src/lbymfm/ymfm_adpcm.cpp", 
        "./src/lbymfm/ymfm_pcm.cpp", 
        "./src/lbymfm/ymfm_ssg.cpp"
    }, &.{
        "-std=c++14",
    });

    const exe = b.addExecutable("main", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();   
    exe.addIncludePath("src");
    exe.addLibraryPath("src");
    exe.linkLibrary(libymfm); 

}