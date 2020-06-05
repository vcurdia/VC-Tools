function varargout = showjobs(c)
% showjobs
% 
% show jobs in cluster
% 
% Copyright (c) 2020 by Vasco Curdia
    
    if nargin<1 || isempty(c)
        c = parcluster;
    end
    jobs = c.Jobs;
    njobs = length(c.Jobs);
    fields = {...
        'ID',3;
        'SchedulerID',11;
        'Name',40;
        'Type',15;
        'Tasks',5;
        'State',10;
             };
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

