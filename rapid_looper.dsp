declare name        "Rapid Looper";
declare version     "0.1";
declare author      "Marc Joliet";
declare license     "MIT";
declare copyright   "(c)Marc Joliet 2013";

// constants
x0 = 0.0;
N  = 2<<14;

// UI control elements
P  = vslider("Period", N, 1, N, 1):int;

// write and read pointer
nx = +(1) ~ %(N) : -(1);
ny = +(1) ~ (_,(N,P:min): %) : -(1);
/* ny = +(1) ~ %(N) : -(1); */

mytable = N+1, x0, nx, _, ny : rwtable;

process = mytable, mytable;
