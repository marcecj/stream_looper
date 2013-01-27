declare name        "Rapid Looper";
declare version     "0.1";
declare author      "Marc Joliet";
declare license     "MIT";
declare copyright   "(c)Marc Joliet 2013";

// constants
x0 = 0.0;
N  = 2<<14;

// helper functions
lp(c) = (+ : *(c)) ~ *(1-c);

// UI control elements
P  = vslider("Period", N, 1, N, 1):int;
S  = vslider("Start", 1, 1, N, 1):-(1):lp(0.5):int;
sliders = hgroup("", P, S);

// write and read pointer
nx = +(1) ~ %(N) : -(1);
ny(P,S) = +(1) ~ %(min(N,P)) : -(1) : +(S) : %(N);

mytable = _,sliders : (N+1, x0, nx, _, ny : rwtable);

process = mytable, mytable;
