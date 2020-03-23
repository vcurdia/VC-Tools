function progress(j,n,nblocks)
% vcprogress
% 
% Track progress of job at step j out of n.
%
% Created: March 23, 2020
% Copyright 2020 by Vasco Curdia

    if nargin<3 || isempty(nblocks)
        nblocks = 10;
    end
    if ~mod(j,ceil(n/nblocks)) || j==n
        fprintf('completed %3.0f%%\n',j/n*100)
    end

end
