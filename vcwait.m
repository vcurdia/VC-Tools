function varargout = vcwait(c,varargin)
% vcwait
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

    jobs = showjobs(c);
    fprintf('Waiting for jobs in profile %s to complete or fail.\n',c.Profile)
    isrq = true;
    while isrq
        isrq = any(ismember({c.Jobs(:).State},op.states));
        if isrq
            pause(op.pausetime)
        end
    end
    % !shutdown -h now
    jobs = showjobs(c);
    if nargout>0
        varargout{1} = jobs;
    end
end

