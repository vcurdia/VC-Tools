function varargout = vcbatch(fcn,jobname,varargin)
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
    op.script = true;
    op.nargout = 0;
    op.argin = {};
    op = updateoptions(op,varargin{:});
    
    % get cluster profile
    if isempty(op.cluster)
        c = parcluster;
    else
        c = parcluster(op.cluster);
    end
    
    % store existing options
    plist = properties(c.AdditionalProperties);
    cold = struct;
    for j=1:length(plist)
        pj = plist{j};
        cold.(pj) = c.AdditionalProperties.(pj);
    end

    % set new profile options
    c.AdditionalProperties.EmailAddress = op.email;
    if ~isempty(jobname)
        c.AdditionalProperties.AdditionalSubmitArgs = [...
            c.AdditionalProperties.AdditionalSubmitArgs,...
            ' -J ',jobname];
    end
    
    % submit script
    if op.script
        job = c.batch(fcn,'Pool',op.pool,...
                      'AutoAttachFiles',false,'CurrentFolder','.');
    else
        job = c.batch(fcn,op.nargout,op.argin,'Pool',op.pool,...
                      'AutoAttachFiles',false,'CurrentFolder','.');
    end
    if ~isempty(jobname), job.Name = jobname; end
    
    % reset cluster options
    c.AdditionalProperties = updateoptions(c.AdditionalProperties,cold);
    
    if nargout>0
        varargout{1} = job;
    end
end

