const std = @import("std");
const play_libymfm = @import("ymfm2149_player.zig").play_libymfm;
const play_libemu2149 = @import("emu2149_player.zig").play_libemu2149;
const play_libemu2413 = @import("emu2413_player.zig").play_libemu2413;
const play_libemu76489 = @import("emu76489_player.zig").play_libemu76489;

pub fn main() !void {

    try play_libymfm();
    // try play_libemu2149(); 
    // try play_libemu76489();
    // try play_libemu2413();

}
