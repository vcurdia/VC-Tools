function  [F,eno]=lyapcsdvb(R,S,verbose)
%function  [F,eno]=lyapcsd(R,S)
% solves RFR'+S=F
% Will fail if R has a root that is one in absolute value.
% based on Chris Syms lyapcsd but with the option to be silent
if nargin<3,verbose=0;end
IR=eye(size(R))+R;
[F,eno]=lyapcsvb(-inv(IR),R'/IR',(IR\S)/IR',verbose);
