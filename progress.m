function progress(j,n,varargin)
% vcprogress
% 
% Track progress of job at step j out of n.
%
% Created: March 23, 2020
% Copyright 2020 by Vasco Curdia

    op.nblocks = 10;
    op.fid = 1;
    op = updateoptions(op,varargin{:});

    if ~mod(j,ceil(n/op.nblocks)) || j==n
        fprintf(op.fid,'completed %3.0f%%\n',j/n*100);
    end

end


