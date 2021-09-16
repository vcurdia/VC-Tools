function vcdiary(str1,str2,logfolder)

% vcdiary
%
% Starts diary with date and time.
% 
% str1 if provided will be added before date/time stamp
% str2 if provided will be added after date/time stamp
% logfolder
% - if not provided, log will be saved in subfolder .logs/
% - if empty, log will be saved in current folder
%
% See also:
% diary
% 
% Created: January 3, 2020 by Vasco Curdia
% Copyright 2020-2021 by Vasco Curdia

    if nargin<1 || isempty(str1)
        str1 = ''; 
    else 
        str1 = [str1,'-'];
    end
    
    if nargin<2 || isempty(str2)
        str2 = '';
    else
        str2 = ['-',str2];
    end
    
    if nargin<3, logfolder = '.logs'; end
    if ~isempty(logfolder) 
        if ~strcmp(logfolder(end),'/')
            logfolder = [logfolder,'/'];
        end
        if ~isdir(logfolder)
            mkdir(logfolder)
        end
    end
    
    diary(sprintf('%s%s%.0f-%02.0f-%02.0f-%02.0f%02.0f%02.0f%s.log',...
              logfolder,str1,clock,str2))
    diary on

end

