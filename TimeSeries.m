classdef TimeSeries < matlab.mixin.Copyable

% TimeSeries class
% 
% Handle object that stores time series data to be used in DSGE, VAR/BVAR, and
% other empirical  explorations
%
% Created: June 1, 2017
% Copyright 2017-2023 Vasco Curdia
    
    properties
% Source Location of source csv file (used to load the data)
        Source
        
% Values matrix with all data values
        Values

% TimeIdx list of dates in data sample
        TimeIdx

% Variables object
%   Variable names need to be matched to observable variable names in 
%   the DSGE model.
        Var = Variables;

% SampleStart Date in which the likelihood starts counting
%   Prior periods are considered to be pre-sample to calibrate the 
%   Kalman Filter but not counting towards the likelihood value.
        SampleStart
        
% TickLabels (optional) array of ticks to show in plots
        TickLabels
    end

    properties (SetAccess=protected)
        %TimeStart Date of first period in sample
        TimeStart
        %TimeEnd Date of last period in sample
        TimeEnd
        %T number of periods in sample
        T
        %NPreSample number of pre-sample periods
        NPreSample
        %NVar number of variables in sample
        NVar
    end
    
    methods
        function obj = TimeSeries(fn)
            if nargin>0
                fprintf('Loading data from:\n%s\n',fn)
                obj.Source = fn;
                raw = importdata(obj.Source);
                keyboard
                obj.Var = {raw.textdata{1,2:end}};
                obj.Values = [...
                    raw.data;
                    NaN(size(raw.textdata,1)-1-size(raw.data,1),obj.NVar)];
                obj.TimeIdx = raw.textdata(2:end,1)';
            end
        end
        
        function set.Var(obj,Var)
            if ~isempty(obj.Var)
                [tf,idx] = ismember(Var,obj.Var);
                if ~all(tf)
                    error('Variables not found in data.')
                end
                obj.Values = obj.Values(:,idx);
            end
            obj.Var = Var;
            obj.NVar = length(Var);
        end
        
        function set.TimeIdx(obj,tid)
            if length(tid)==2
                tid = timeidx(tid{:});
            end
            if ~isempty(obj.TimeIdx)
                obj.Values = obj.Values(ismember(obj.TimeIdx,tid),:);
            end
            obj.TimeIdx = tid;
            obj.T = length(tid);
            obj.TimeStart = tid{1};
            obj.TimeEnd = tid{end};
            if isempty(obj.SampleStart) ...
                    || ~ismember(obj.SampleStart,obj.TimeIdx)
                obj.SampleStart = obj.TimeStart;
            end
        end
        
        function set.SampleStart(obj,t)
            if ~ismember(t,obj.TimeIdx)
                error('Requested SampleStart out of data scope.')
            end
            obj.SampleStart = t;
            obj.NPreSample = find(ismember(obj.TimeIdx,obj.SampleStart))-1;
        end
        
        function set.TickLabels(obj,tList)
            obj.TickLabels = tList(ismember(tList,obj.TimeIdx));
        end
        
    end %methods
    
end %class


