function varargout = cbatch(c,fcn,npool)
% cbatch
% 
% submit batch job in c cluster
% 
% Copyright (c) 2024 by Vasco Curdia

    if nargin<2
        fcn = c;
        c = [];
    end
    if isempty(c)
        c = vcparcluster;
    end
    if isempty(fcn)
        error('function not specified')
    end
    if nargin<3 || isempty(npool)
        npool = 0;
    end

    if npool>0
        job = c.batch(fcn,0,{},'Pool',npool,'AutoAttachFiles',false,'CurrentFolder','.');
    else
        job = c.batch(fcn,0,{},'AutoAttachFiles',false,'CurrentFolder','.');
    end

    if nargout>0
        varargout{1} = job;
    end
end









