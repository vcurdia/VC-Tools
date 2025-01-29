function s = stats(x,varargin)
    % stats
    %
    % structure with descriptive statistics of x
    %
    % Created by Vasco Curdia on January 29, 2025
    % copyright (c) 2025  by Vasco Curdia

    %% options
    op.Dim = 1;
    op.P = [1, 5, 15, 25, 75, 85, 95, 99];
    op = updateoptions(op,varargin{:});

    %% compute statistics
    s = struct;
    s.Mean = mean(x,op.Dim,'omitnan');
    s.Median = median(x,op.Dim,'omitnan');
    s.SD = std(x,0,op.Dim,'omitnan');
    s.Min = min(x,[],op.Dim,'omitnan');
    s.Max = max(x,[],op.Dim,'omitnan');
    for jP=1:length(op.P)
        s.(sprintf('Prc%02.0f',op.P(jP))) = prctile(x,op.P(jP),op.Dim);
    end


end
