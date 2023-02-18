# build cpp library
zig c++ ./src/libymfm/ymfm_misc.cpp ./src/libymfm/ymfm_opl.cpp ./src/libymfm/ymfm_opm.cpp ./src/libymfm/ymfm_opn.cpp ./src/libymfm/ymfm_opq.cpp ./src/libymfm/ymfm_opz.cpp ./src/libymfm/ymfm_adpcm.cpp ./src/libymfm/ymfm_pcm.cpp ./src/libymfm/ymfm_ssg.cpp

# build zig app
zig build-exe src/main.zig -I ./src 