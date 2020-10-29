function varargout = vcbatch(fcn,varargin)
% vcbatch
% 
% submit batch job
% 
% Copyright (c) 2020 by Vasco Curdia
    
%     if nargin<2 || isempty(jobname)
%         jobname = '';
%     end
    if strcmp(class(fcn),'function_handle')
        op.jobname = func2char(fcn);
    else
        op.jobname = fcn;
    end
    op.cluster = '';
    op.pool = 0;
    op.email = 'vasco.curdia@sf.frb.org';
    op.mem = '';
    op.joboptions = '';
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
    if isempty(cold.EmailAddress) && ~isempty(op.email)
        c.AdditionalProperties.EmailAddress = op.email;
    end
    if ~isempty(op.jobname)
        c.AdditionalProperties.AdditionalSubmitArgs = [...
            c.AdditionalProperties.AdditionalSubmitArgs,...
            ' -J ',op.jobname];
    end
    if ~isempty(op.mem)
        c.AdditionalProperties.MemUsage = op.mem;
    end
    if ~isempty(op.joboptions)
        c.AdditionalProperties.AdditionalSubmitArgs = [...
            c.AdditionalProperties.AdditionalSubmitArgs,' ',op.joboptions];
    end
    
    % submit script
    if op.script
        job = c.batch(fcn,'Pool',op.pool,...
                      'AutoAttachFiles',false,'CurrentFolder','.');
    else
        job = c.batch(fcn,op.nargout,op.argin,'Pool',op.pool,...
                      'AutoAttachFiles',false,'CurrentFolder','.');
    end
    if ~isempty(op.jobname), job.Name = op.jobname; end
    
    % reset cluster options
    c.AdditionalProperties = updateoptions(c.AdditionalProperties,cold);
    
    if nargout>0
        varargout{1} = job;
    end
end









