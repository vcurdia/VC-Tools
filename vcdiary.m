function vcdiary(str1,str2)

% vcdiary
%
% Starts diary with date and time
%
% See also:
% diary
% 
% ...........................................................................
% 
% Created: January 3, 2020 by Vasco Curdia
% 
% Copyright 2020 by Vasco Curdia

    if nargin<1 || isempty(str1)
        str1 = ''; 
    else 
        str1 = ['-',str1];
    end
    
    if nargin<2 || isempty(str2)
        str2 = '';
    else
        str2 = ['-',str2];
    end
    
    diary(sprintf('log%s-%.0f-%02.0f-%02.0f-%02.0f%02.0f%02.0f%s.log',...
              str1,clock,str2))
    diary on

end

