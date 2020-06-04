function job = vcbatch(fcn,jobname,varargin)
% vcbatch
% 
% submit batch job
% 
% Copyright (c) 2020 by Vasco Curdia
    
    if nargin<2 || isempty(jobname)
        jobname = '';
    end
    
    op.cluster = '';
    op.pool = 0;
    op.email = 'vasco.curdia@sf.frb.org';
    op.script = 1;
    op.nargout = 0;
    op.argin = {};
    op = updateoptions(op,varargin{:});
    
    if isempty(op.cluster)
        c = parcluster;
    else
        c = parcluster(op.cluster);
    end
    
    cold.EmailAddress = c.AdditionalProperties.EmailAddress;
    cold.AdditionalSubmitArgs = c.AdditionalProperties.AdditionalSubmitArgs;

    c.AdditionalProperties.EmailAddress = op.email;
    if ~isempty(jobname)
        c.AdditionalProperties.AdditionalSubmitArgs = [...
            c.AdditionalProperties.AdditionalSubmitArgs,...
            ' -J ',jobname];
    end
    
    if op.script
        job = c.batch(fcn,'Pool',op.pool,'AutoAttachFiles',false);
    else
        job = c.batch(fcn,op.nargout,op.argin,'Pool',op.pool,...
                      'AutoAttachFiles',false);
    end
    if ~isempty(jobname), job.Name = jobname; end
    
    c.AdditionalProperties.EmailAddress = cold.EmailAddress;
    c.AdditionalProperties.AdditionalSubmitArgs = cold.AdditionalSubmitArgs;
    
end

