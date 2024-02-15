function varargout = showjobs(c,varargin)
% showjobs
% 
% show jobs in cluster
% 
% Copyright (c) 2020-2024 by Vasco Curdia

    op.name = '';
    op.state = '';
    op.tasks = [];
    op = updateoptions(op,varargin{:});

    %% load jobs and apply filter
    if nargin==0 || isempty(c)
        c = parcluster;
    elseif ischar(c)
        c = parcluster(c);
    end
    jobs = c.Jobs;
    njobs = length(jobs);
    idx = true(1,length(jobs));
    for j=1:njobs
        if idx(j) && ~isempty(op.name)
            idx(j) = any(strfind(jobs(j).Name,op.name));
        end
        if idx(j) && ~isempty(op.state)
            idx(j) = any(strfind(jobs(j).State,op.state));
        end
        if idx(j) && ~isempty(op.tasks)
            idx(j) = any(ismember(length(jobs(j).Tasks),op.tasks));
        end
    end
    jobs = jobs(idx);
    njobs = length(jobs);
    
    %% show jobs
    fprintf('Jobs from cluster profile %s\n',c.Profile)
    namelength = max(5,max(cellfun('length',{jobs(:).Name})));
    fields = {...
        'ID',3;
        'SchedulerID',11;
        'Name',namelength; %30
        'Type',11;
        'Tasks',5;
        'State',10;
             };
    if ~isempty(strfind(version,'R2018a')), fields(2,:) = []; end
    nfields = size(fields,1);
    fprintf('%3s','');
    for jf=1:nfields
        fprintf(['  %',int2str(fields{jf,2}),'s'],fields{jf,1});
    end
    fprintf('\n');
    for jj=1:njobs
        fprintf('%3.0f',jj);
        for jf=1:nfields
            fj = fields{jf,1};
            if strcmp(fj,'SchedulerID')
                list = unique({jobs(jj).Tasks(:).SchedulerID});
                txt = sprintf(',%s',list{:});
                fprintf(['  %',int2str(fields{jf,2}),'s'],txt(2:end));
            elseif strcmp(fj,'NumWorkers')
                list = unique(jobs(jj).NumWorkersRange);
                txt = sprintf('-%i',list(:));
                fprintf(['  %',int2str(fields{jf,2}),'s'],txt(2:end));
            elseif strcmp(fj,'Tasks')
                fprintf(['  %',int2str(fields{jf,2}),'i'],length(jobs(jj).Tasks));
            elseif ismember(fj,{'Name','Type','State'})
                fprintf(['  %',int2str(fields{jf,2}),'s'],jobs(jj).(fj));
            else
                fprintf(['  %',int2str(fields{jf,2}),'i'],jobs(jj).(fj));
            end
        end
        fprintf('\n');
    end
    fprintf('\n');
    
    if nargout>0
        varargout{1} = jobs;
    end
end

