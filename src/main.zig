const std = @import("std");
const ymfm = @cImport({
    @cInclude("./libymfm.h");
});


pub fn main() !void {

    const stdout = std.io.getStdOut().writer();

    const clock: u32 = 8000;
    // var res: u32 = ymfm.ymfm_add_chip(ymfm.chip_type.CHIP_YM2149, clock);
    var res: u32 = ymfm.ymfm_add_chip(1, clock);

    try stdout.print("Rssult, {}\n", .{res});
}

