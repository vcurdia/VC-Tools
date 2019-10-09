function [A,B,Q,Z] = qzdiv_ordqz(stake,A,B,Q,Z)
%function [A,B,Q,Z] = qzdiv_ordqz(stake,A,B,Q,Z)
%
% find unstable roots
% taken from qzdiv.m by Christopher A. Sims
root = abs([diag(A) diag(B)]);
root(:,1) = root(:,1)-(root(:,1)<1.e-13).*(root(:,1)+root(:,2));
root(:,2) = root(:,2)./root(:,1);

unstab = (root(:,2) > stake | root(:,2) < -.1);

% qzdiv.m by CAS also returns ordered V, but this does not.
[A,B,Q,Z] = ordqz(A,B,Q,Z,~unstab);