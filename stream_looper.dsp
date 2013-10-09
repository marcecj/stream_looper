declare name        "Stream Looper";
declare version     "0.1";
declare author      "Marc Joliet";
declare license     "MIT";
declare copyright   "(c)Marc Joliet 2013";

import("filter.lib");

// constants
x0 = 0.0;
N  = 2<<14;

// UI control elements
sliders = hgroup("",
    hgroup("Recording",
           (vslider("Period [midi:ctrl 02]", N, 1, N, 1):int),
           (vslider("Start [midi:ctrl 03]", 1, 1, N, 1):-(1):smooth(0.999):+(0.5):int)),
    hgroup("Playback",
           (vslider("Period [midi:ctrl 00]", N, 1, N, 1):int),
           (vslider("Start [midi:ctrl 01]", 1, 1, N, 1):-(1):smooth(0.999):+(0.5):int)));
pause  = checkbox("Pause Recording [midi:ctrl 04]");
bypass = checkbox("Bypass [midi:ctrl 05]");
limit_pp_by_rp = checkbox("Limit to Rec Period [midi:ctrl 06]");

diff(x) = x - x';

// When either bypass or pause is switched *off*, they go from 1 to 0, so that
// their delta value is -1, which results in "A|B==1".  Since using that value
// would keep the counter at 1 when the effect is *in use*, it is inverted, so
// that turning *on* bypass/pause results in S==0, and thus in sync==1.
//
// The short version: sync is 1 when either bypass or pause are unchecked,
// otherwise N.
sync = select2(S, 1, N) with {
    A = bypass : diff : ==(-1);
    B = pause  : diff : ==(-1);
    S = A,B:|:!=(1);
};

// write and read pointers
//
// When the "pause" checkbox is checked, the write pointer is set to N, which is
// outside of the read pointer range. This effectively pauses recording, i.e.
// makes the table static.
//
// To keep the read and write pointers in sync, when either the pause or bypass
// checkboxes are unchecked, "sync" is set to 1, which effectively resets the
// (shifted) counters of both nr and nw (since 1%1==0).  This makes the result
// of unchecking bypass or pause (as used in the Rumblepad UI) intuitive.
shifted_counter(P1,P2,S) = +(1) ~ %(min(min(P1,P2),sync)) : -(1) : +(S) : %(N);
nw(P,S) = pause, shifted_counter(P,P,S), N : select2;
nr(P,S) = P, select2(limit_pp_by_rp, P, (sliders:_,!,!,!)), S : shifted_counter;

// the read/write table and its controls
write_control = sliders : _,_,!,! : nw;
play_control  = sliders : !,!,_,_ : nr;
rec_table = N+1, x0, write_control, _, play_control : rwtable;

// If the "bypass" checkbox is checked, the table is bypassed and the input
// signal is just forwarded through.
table_select = _ <: bypass, rec_table, _ : select2;

process = table_select, table_select;
