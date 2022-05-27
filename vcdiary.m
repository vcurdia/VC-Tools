function vcdiary(str,logfolder)

% vcdiary
%
% Starts diary with date and time.
% 
% str if provided will be added after date/time stamp
% logfolder
% - if not provided, log will be saved in subfolder .logs/
% - if empty, log will be saved in current folder
%
% See also:
% diary
% 
% Created: January 3, 2020 by Vasco Curdia
% Copyright 2020-2021 by Vasco Curdia

    if nargin<1 || isempty(str)
        str = '';
    else
        str = ['-',str];
    end
    
    if nargin<2, logfolder = '.logs'; end
    if ~isempty(logfolder) 
        if ~strcmp(logfolder(end),'/')
            logfolder = [logfolder,'/'];
        end
        if ~isdir(logfolder)
            mkdir(logfolder)
        end
    end
    
    diary(sprintf('%s%.0f-%02.0f-%02.0f-%02.0f%02.0f%02.0f%s.log',...
              logfolder,clock,str))
    diary on

end

