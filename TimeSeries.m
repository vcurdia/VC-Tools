classdef TimeSeries < matlab.mixin.Copyable

% TimeSeries class
% 
% Handle object that stores time series data to be used in DSGE, VAR/BVAR, and
% other empirical  explorations
%
% Created: June 1, 2017
% Copyright 2017-2025 Vasco Curdia
    
    properties
        % Source csv filename (used to load the data)
        Source
        
        % Values matrix with all data values
        Values

        % Var Variables object
        %   Variable names need to be matched to observable variable names in 
        %   the DSGE model.
        Var = Variables;

        % Time Time object with dates in data sample
        Time

        % SampleStart Date in which the likelihood starts counting
        %   Prior periods are considered to be pre-sample to calibrate the 
        %   Kalman Filter but not counting towards the likelihood value.
        SampleStart
        
        % Ticks (optional) Time object with labels and IDs of ticks to show in plots
        Ticks
    end

    properties (SetAccess=protected)
        % NPreSample number of pre-sample periods
        NPreSample
    end
    
    methods
        function obj = TimeSeries(data)
            if nargin>0
                if isa(data,'TimeSeries')
                    obj = copy(data);
                else
                    fprintf('Loading data from:\n%s\n',data)
                    obj.Source = data;
                    raw = importdata(obj.Source);
                    obj.Var = {raw.textdata{1,2:end}};
                    obj.Values = [...
                        raw.data;
                        NaN(size(raw.textdata,1)-1-size(raw.data,1),obj.Var.N)];
                    obj.Time = raw.textdata(2:end,1)';
                    obj.SampleStart = obj.Time.Labels{1};
                end
            end
        end
        
        function set.Var(obj,v)
            if isempty(obj.Var)
                obj.Var = Variables(v);
            else
                [obj.Var,idx] = subset(obj.Var,v);
                obj.Values = obj.Values(:,idx);
            end
        end
        
        function set.Time(obj,t)
            if iscell(t)
                t = Time(t{[1,end]});
            end
            if isempty(obj.Time)
                obj.Time = t;
            else
                [tf,idx] = ismember(obj.Time,t);
                values = nan(t.N,obj.Var.N);
                values(tf,:) = obj.Values(idx(tf),:);
                obj.Time = t;
                obj.Values = values;
                if ~isempty(obj.Ticks)
                    obj.Ticks = obj.Ticks.Labels;
                end
            end
        end
        
        function set.SampleStart(obj,t)
            if ~obj.Time.ismember(t)
                error('Requested SampleStart out of data scope.')
            end
            obj.SampleStart = t;
            obj.NPreSample = find(ismember(obj.Time.Labels,obj.SampleStart))-1;
        end

        function set.Ticks(obj,t)
            obj.Ticks = subset(obj.Time,t);
        end

        function [tnan,tfnan] = getnan(obj)
            tfnan = any(isnan(obj.Values),2);
            tnan = subset(obj.Time,obj.Time.Labels(tfnan));
        end

        function varnan = getnanvar(obj)
            [tnan,tfnan] = getnan(obj);
            varnan = cell(tnan.N,1);
            for j=1:tnan.N
                varnan{j} = {obj.Var.Names{isnan(obj.Values(tnan.ID(j),:))}};
            end
        end

        function shownan(obj)
            [tnan,tfnan] = getnan(obj);
            if ~isempty(tnan)
                fprintf('Warning: NaN found.\n')
                varnan = obj.getnanvar;
                for t=1:tnan.N
                    fprintf('%s:',tnan.Labels{t})
                    fprintf(' %s',varnan{t}{:})
                    fprintf('\n')
                end
            end
        end
        
        function removenan(obj)
            [tnan,tfnan] = getnan(obj);
            if ~isempty(tnan)
                fprintf('Warning: NaN found.\n')
                if tnan.ID(1)==1
                    for jstart=1:tnan.N
                        if jstart==tnan.N || tnan.ID(jstart+1)>tnan.ID(jstart)+1
                            break
                        end
                    end
                    newstart = obj.Time.Labels{tnan.ID(jstart)+1};
                    fprintf('Corrected start date: %s\n',newstart)
                else
                    jstart = 0;
                    newstart = obj.Time.Labels{1};
                end
                if tnan.ID(end)==obj.Time.N
                    for jend=tnan.N:-1:jstart+1
                        if jend==jstart+1 || tnan.ID(jend-1)<tnan.ID(jend)-1
                            break
                        end
                    end
                    newend = obj.Time.Labels{tnan.ID(jend)-1};
                    fprintf('Corrected end date: %s\n',newend)
                else
                    jend = tnan.N+1;
                    newend = obj.Time.Labels{end};
                end
                if jend>jstart+1
                    fprintf('list of dates with NaN:\n')
                    fprintf('%s\n',obj.Time.Labels{tfnan})
                    error('NaN dates in middle of sample, cannot proceed.')
                else
                    obj.Time = {newstart,newend};
                end
            end

        end

        function y = getvalues(obj,v)
            if ~iscell(v), v = {v}; end
            [tf,idx] = obj.Var.ismember(v);
            if ~all(tf)
                error('Variables not found in data.')
            end
            y = obj.Values(:,idx);
        end
        
        function showvalues(obj,v)
            if ~iscell(v), v = {v}; end
            y = obj.getvalues(v)
            fprintf('\n%6s','')
            fprintf('  %10s',v{:})
            fprintf('\n')
            for t=1:obj.Time.N
                fprintf('%6s',obj.Time.Labels{t})
                fprintf('  %10.3f',y(t,:))
                fprintf('\n')
            end
            fprintf('\n')
        end
        
        function showstats(obj,v)
            if ~iscell(v), v = {v}; end
            s = stats(obj.getvalues(v));
            fprintf('\n%6s','')
            fprintf('  %10s',v{:})
            fprintf('\n')
            slist = fieldnames(s);
            for js=1:length(slist)
                sj = slist{js};
                fprintf('%6s',sj)
                fprintf('  %10.3f',s.(sj))
                fprintf('\n')
            end
            fprintf('\n')
        end
        
        function add(obj,v,values)
            if ~iscell(v), v = {v}; end
            nv = length(v);
            [tf,idx] = obj.Var.ismember(v);
            if any(tf)
                vnames = sprintf('%s ',v{tf});
                error('Variable(s) already present in dataset: %s',vnames)
            end
            obj.Var.add(v);
            obj.Values(:,end+(1:nv)) = values;
        end
        
    end %methods
    
end %class


