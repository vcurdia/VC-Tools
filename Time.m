classdef Time < matlab.mixin.Copyable

% Time class
% 
% Handle object that stores time informattion for TimeSeries objects, and other empirical explorations
%
%
% Convention used:
% Dates in format of '####q#' or '####m##' for quarterly and monthly data,
% respectively. For monthly frequency, for single digit periods they can be show
% up in Start and End as either # or ## (e.g. 1 or 01) but the index
% will be in the format ##.
%
% Created: June 2, 2023
% Copyright 2023 Vasco Curdia
    
    properties

        % Start Date of first period in object
        Start

        % End Date of last period in object
        End
        
        % Labels List of Time labels
        Labels

    end

    properties (SetAccess=protected)
        % ID Array of time identifiers
        ID
        % N number of periods in sample
        N
        % Frequency monthly (m) or quarterly (q)
        Frequency
        % NPeriods number of periods in one year
        NPeriods
        % NPeriodsStr size of string for period identifier
        NPeriodsStr
    end
    
    methods
        function obj = Time(TimeStart,TimeEnd)
            if nargin>0
                obj.Start = TimeStart;
                obj.End = TimeEnd;
                
                %% Find frequency
                if ismember('q',obj.Start)
                    obj.Frequency = 'q';
                    obj.NPeriods = 4;
                    obj.NPeriodsStr = 1;
                elseif ismember('m',TimeStart)
                    obj.Frequency = 'm';
                    obj.NPeriods = 12;
                    obj.NPeriodsStr = 2;
                else
                    error('Frequency could not be detected.')
                end

                %% Identify limiting dates
                StartYear = eval(obj.Start(1:4));
                StartPer = eval(obj.Start(6:end));
                EndYear = eval(obj.End(1:4));
                EndPer = eval(obj.End(6:end));

                %% Create index
                tid={};
                for yr=StartYear:EndYear
                    for per=1:obj.NPeriods
                        if yr==StartYear && per<StartPer
                            continue
                        elseif yr==EndYear && per>EndPer
                            break
                        end
                        tid{end+1} = sprintf(['%04.0f%s%0',int2str(obj.NPeriodsStr),'.0f'],...
                                             yr,obj.Frequency,per);
                    end
                end
                obj.Labels = tid;
            end
        end
        
        function set.Labels(obj,labels)
            if isempty(obj.Labels)
                obj.Labels = labels;
                obj.N = length(obj.Labels);
                obj.ID = 1:obj.N;
            else
                [tf,idx] = ismember(labels,obj.Labels);
                idx = idx(tf); % pick only existing labels
                obj.Labels = obj.Labels(idx);
                obj.ID = obj.ID(idx);
                obj.N = length(obj.Labels);
            end
        end
        
        function tf = isempty(obj)
            tf = (obj.N==0);
        end

        function [tf,idx] = ismember(obj,labels)
            if isa(labels,'Time'), labels = labels.Labels; end
            [tf,idx] = ismember(labels,obj.Labels);
        end

        function [t1,idx] = subset(obj,timestart,timeend)
            if nargin==3
                t = Time(timestart,timeend);
                labels = t.Labels;
            elseif nargin<3
                labels = timestart;
            end
            t1 = Time(obj.Start,obj.End);
            t1.Labels = labels;
        end

    end %methods
    
end %class


