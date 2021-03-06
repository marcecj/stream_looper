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
Rp = vslider("/h:[0]/v:Recording/h:[1]/Period [midi:ctrl 02]", N, 1, N, 1):int;
Pp = vslider("/h:[0]/v:Playback/h:[1]/Period [midi:ctrl 00]", N, 1, N, 1):int;
Rs = vslider("/h:[0]/v:Recording/h:[1]/Start [midi:ctrl 03]", 1, 1, N, 1):-(1):smooth(0.999):+(0.5):int;
Ps = vslider("/h:[0]/v:Playback/h:[1]/Start [midi:ctrl 01]", 1, 1, N, 1):-(1):smooth(0.999):+(0.5):int;
pp_graph = hbargraph("/h:[0]/v:Playback/[0]Position", 0, N);
rp_graph = hbargraph("/h:[0]/v:Recording/[0]Position", 0, N);
pause  = checkbox("[1]Pause Recording [midi:ctrl 04]");
bypass = checkbox("[2]Bypass [midi:ctrl 05]");
limit_pp_by_rp = checkbox("[3]Limit to Rec Period [midi:ctrl 06]");

diff(x) = x - x';

// Sync is 1 when either bypass or pause become unchecked, otherwise N. That is:
// when either bypass or pause is *unchecked*, their delta value is -1, which
// results in A=0 and/or B=0, which in turn makes S=0. Otherwise the bitwise-and
// yields S=1.
sync = select2(S, 1, N) with {
    A = bypass : diff : !=(-1);
    B = pause  : diff : !=(-1);
    S = A,B:&;
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
nr(P,S) = P, select2(limit_pp_by_rp, P, Rp), S : shifted_counter;

// the read/write table and its controls
pointer_displays(x,y) = y,x:pp_graph,rp_graph:cross(2);
controls = (nw(Rp,Rs), nr(Pp,Ps) : pointer_displays), _ : _,cross(2) ;
rec_table = N+1, x0, controls : rwtable;

// If the "bypass" checkbox is checked, the table is bypassed and the input
// signal is just forwarded through.
table_select = _ <: bypass, rec_table, _ : select2;

process = table_select, table_select;
