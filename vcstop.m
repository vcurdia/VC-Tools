function vcstop(c,varargin)
% vcstop
% 
% stop machine if no running or queued jobs
% 
% Copyright (c) 2024 by Vasco Curdia

    op.states= {'running','queued'};
    op.pausetime = 30;
    op = updateoptions(op,varargin{:});

    if nargin==0 || isempty(c)
        c = parcluster;
    elseif ischar(c)
        c = parcluster(c);
    end

    fprintf('WARNING: vcstop initiated for profile %s\n',c.Profile)
    fprintf('         When all jobs finish or fail this machine will shutdown.\n')
    fprintf('         If you want to interrupt the shutdown press ctrl-c.\n')
    isrq = true;
    while isrq
        isrq = any(ismember({c.Jobs(:).State},op.states));
        if isrq
            pause(op.pausetime)
        end
    end
    !shutdown -h now

end

