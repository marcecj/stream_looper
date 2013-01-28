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
P  = vslider("Period (play)", N, 1, N, 1):int;
R  = vslider("Period (rec)", N, 1, N, 1):int;
S  = vslider("Start", 1, 1, N, 1):-(1):smooth(0.999):+(0.5):int;
pause   = checkbox("Pause Recording");
bypass  = checkbox("Bypass");
sliders = hgroup("", R, P, S);

// write and read pointers
//
// When the "pause" checkbox is checked, the write pointer is set to N, which is
// outside of the read pointer range. This effectively pauses recording, i.e.
// makes the table static.
nw(R) = pause, (+(1) ~ %(R) : -(1)), N : select2;
nr(R,P,S) = +(1) ~ %(min(R,P)) : -(1) : +(S) : %(N);

// the read/write table and its controls
swap = _,_ <: !,_,_,!;
dup = _ <: _,_;
rec_table = _, sliders : _,dup,_,_ : swap,_,_,_ : (N+1, x0, nw, _, nr : rwtable);

// If the "bypass" checkbox is checked, the table is bypassed and the input
// signal is just forwarded through.
table_select = _ <: bypass, rec_table, _ : select2;

process = table_select, table_select;
