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
        %NPreSample number of pre-sample periods
        NPreSample
    end
    
    methods
        function obj = TimeSeries(fn)
            if nargin>0
                fprintf('Loading data from:\n%s\n',fn)
                obj.Source = fn;
                raw = importdata(obj.Source);
                obj.Var = {raw.textdata{1,2:end}};
                obj.Values = [...
                    raw.data;
                    NaN(size(raw.textdata,1)-1-size(raw.data,1),obj.Var.N)];
                obj.Time = raw.textdata(2:end,1)';
                obj.SampleStart = obj.Time.Labels{1};
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
            t = Time(t{[1,end]});
            if isempty(obj.Time)
                obj.Time = t;
            else
                [tf,idx] = ismember(obj.Time,t);
                if ~all(tf)
                    error('Could not find all the time periods')
                end
                obj.Time = t;
                obj.Values = obj.Values(idx,:);
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
        
    end %methods
    
end %class


