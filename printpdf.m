function printpdf(fn,varargin)

% printpdf
%
% Prints current figure into pdf and adjusts paper settings
%
% ...........
%
% Created: March 13, 2020 by Vasco Curdia
% Copyright 2020 by Vasco Curdia

    %% options
    op.h = gcf;
%     op.TightFig = 0;
%     op.TightFigOptions = struct;
    op.PaperSize = [6.5, 6.5];
    op.PaperPosition = [0, 0, 6.5, 6.5];
    op = updateoptions(op,varargin{:});


    %% adjust paper size
    op.h.PaperSize = op.PaperSize;
    op.h.PaperPosition = op.PaperPosition;
    
    %% tightfig
%     if op.TightFig
%         tightfig(op.h,op.Fig.Shape,hf,op.TightFigOptions)
%     end

    %% print to pdf
    print('-dpdf',fn)

end
