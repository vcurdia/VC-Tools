classdef Variables < matlab.mixin.Copyable

% Variables class
% 
% Object representing variables, used in VAR/BVAR, DSGE, and TimeSeries classes.
% 
% Created: June 1, 2023 
% Copyright 2023 Vasco Curdia
    
    properties
% Names List of variable names to be used in equations and commands
%
% These are the names that will show up in equations and model manipulations.
        Names 
        
% PrettyNames List of variable names formatted for LaTeX output
%
% These are expressions that will represent the variables when plotting or 
% creating LaTeX output.
% 
% If not explicitly specified, then Names is used.
        PrettyNames
    end
        
    properties (SetAccess = protected)
% N number of variables in instance
%
% This property is automatically populated every time that Names is changed.
        N = 0; 
    end
    
    methods
        
        function obj = Variables(v)
            if nargin>0
                [nv,nc] = size(v);
                if nv==1
                    v = v.';
                    nv = nc;
                    nc = 1;
                end
                obj.Names = v(:,1);
                if nc>1
                    obj.PrettyNames = v(:,2);
                end
            end
        end
        
        function set.Names(obj,names)
            obj.Names = names;
            obj.N = length(names);
            if length(obj.PrettyNames)~=obj.N
                obj.PrettyNames = names;
            end
        end
        
        function set.PrettyNames(obj,prettynames)
            if length(prettynames)==obj.N
                obj.PrettyNames = prettynames;
            else
                error('Length of PrettyNames must match number of variables.')
            end
        end
        
        function add(obj,v)
            if ~iscell(v)
                error('Variables to add need to be in cell array.')
            end
            [nv,nc] = size(v);
            names = [obj.Names;v(:,1)];
            prettynames = [obj.PrettyNames;v(:,nc)];
            obj.Names = names;
            obj.PrettyNames = prettynames;
        end

        function v1 = merge(obj,varargin)
            v1 = copy(obj);
            isDuplicates = false;
            for j=1:nargin-1
                v = varargin{j};
                if ~strcmp(class(v),'Variables')
                    error('Cannot merge variables. Input needs to be instance of Variables class.')
                end
                if v.N==0, continue, end
                if v1.N==0
                    v1 = copy(v);
                    continue
                end
                tf = ismember(v.Names,v1.Names);
                isDuplicates = (isDuplicates || any(tf));
                if ~all(tf)
                    names = [v1.Names;v.Names(~tf)];
                    prettynames = [v1.PrettyNames;v.PrettyNames(~tf)];
                    v1.Names = names;
                    v1.PrettyNames = prettynames;
                end
            end
        end
        
        function [v1,idx] = subset(obj,names)
            [tf,idx] = obj.ismember(names);
            if ~all(tf)
                error('Variables not found in data.')
            end
            % idx = idx(tf); % this allowed to use only the existing variables
            v1 = Variables(obj.Names(idx));
            v1.PrettyNames = obj.PrettyNames(idx);
        end
        
        function [tf,idx] = ismember(obj,names)
            if isa(names,'Variables'), names = names.Names; end
            [tf,idx] = ismember(names,obj.Names);
        end

        function tf = isempty(obj)
            tf = (obj.N==0);
        end
        
        function prettynames=findprettynames(obj,names)
            [tf,idx] = ismember(names,obj.Names);
            if ~all(tf)
                error('Could not find %s\n',names{~tf})
            end
            prettynames = obj.PrettyNames(idx);
        end

        function setprettynames(obj,names,prettynames)
            [tf,idx] = ismember(names,obj.Names);
            if ~all(tf)
                error('Could not find %s\n',names{~tf})
            end
            if length(idx)==1 && ischar(prettynames)
                obj.PrettyNames{idx} = prettynames; 
            else
                obj.PrettyNames(idx) = prettynames;
            end
        end
        
    end %methods
    
end %class
