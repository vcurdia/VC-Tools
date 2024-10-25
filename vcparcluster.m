function c = vcparcluster(cname,nworkers)
% vcparcluster
% 
% save copy of default cluster profile to  make one per machine
% 
% Copyright (c) 2024 by Vasco Curdia

    ps = parallel.Settings;
    ps.Pool.AutoCreate = false;
    ps.Pool.IdleTimeout = inf;

    c = parcluster;
    
    if nargin>1
        c.NumWorkers = nworkers;
    end

    c.JobStorageLocation = checkdir([c.JobStorageLocation,'/',cname]);

    c.saveAsProfile(cname)

    % cbatch = @(x,n)c.batch(x,0,{},'Pool',n,'AutoAttachFiles',false);

end
