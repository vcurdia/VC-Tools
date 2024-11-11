function h = vcplotdistbands(y,varargin)

% vcplotdistbands
%
% Plots median and percentile bands for matrix X.
%
% Usage: 
%   vcplotdistbands(y)
%   vcplotdistbands(x,y)
%   vcplotdistbands(...,OptionsStructure,...)
%   vcplotdistbands(...,'PropertyName',PropertyValue,...)
%   h = vcplotdistbands(...)
%
% If no arguments are specified then an example is shown.
%
% Required input argument:
%
%   y
%   Matrix containing data. Percentiles computed along first dimension.
%
% Options:
%
%   Bands2Show
%   Percent intervals to be shown in the plots, centered around median.
%   Default: [50,70,90]
%
%   MedianColor
%   Color of median line.
%   Default: [0,0,0.7]
%
%   ShadeColor
%   Base color for bands.
%   Default: [0.2,0.6,0.5]
%
%   LineWidth
%   Width of median line.
%   Default: 1.5
%
%   isZeroLine
%   If 1 plots the zero line. If 0 it does not plot a zero line.
%   Default: 1
%
%   ZeroLineColor
%   Color for the zero line.
%   Default: 'k'
%
%   ZeroLineStyle
%   Style for the zero line.
%   Default: ':'
%
%   tid
%   x axis values.
%   Default: 1:T
%
% See also:
% vcplot, vcfigure, colorscheme
%
% ----
%
% Created: October 30, 2008 by Vasco Curdia
% Copyright 2008-2024 by Vasco Curdia


%% Check Inputs
    if nargin==0
        % Example
        x = 1:25;
        y = rand(1000,length(x));
        op.AltData = [...
            -0.1+x/25;
            0.4+x/25;
            %     1.3-x/25;
                     ];
        op.LegendLocation = 'SE';
        varargin{1} = op;
    else
        if nargin>1 && isnumeric(varargin{1})
            x = y;
            y = varargin{1};
            varargin(1) = [];
        end
    end

    %% default options
    op.Bands2Show = [50,70,90]; %[50,60,70,80,90]
    op.AltData = [];
    % op.ShowLegend = 0;
    % op.LegendLocation = 'Best';
    % op.LegendString = {};
    % op.LegendOrientation = 'vertical'; %'vertical','horizontal'
    % op.LegendWithBands = 0;
    op.LineColor = colorscheme;
    % op.LineColor = op.LineColor([3,1,2,4:end],:); 
    % Assumes that 3rd line color is red and first is blue
    % op.ShadeColor = [0.2,0.6,0.5];
    % op.ShadeColor = [0.45,0.45,0.5]; 
    % op.ShadeColor = [0.585,0.585,0.65]; 
    op.ShadeColor = [0.72,0.77,0.82]*0.95;
    % op.ShadeColor = [0.15,0.25,0.75];
    op.ShadeColorBrightness = 0.9;
    % op.ShadeFactors = [0.1,0.65]% shade factors at 50 and 90%
    % op.ShadeFactors = [0.2,0.7]; % shade factors at 50 and 90%
    op.ShadeFactors = [0.3,0.5]; % shade factors at 50 and 90%
                                 % op.ShadeFactors = [0.1,0.7]; % shade factors at 50 and 90%
                                 % MedianColor = [0,0,0.7];
                                 % ShadeColor = [0.2,0.6,0.5];
    op.ShadeAlpha = 0.2:0.01:0.25; %ones(10,1); %0.2:0.01:0.25;
    op.YHasBands = 0;
    op.Compare = 0;

    %% Update options
    op = updateoptions(op,varargin{:});

    %% Check y
    [~,nx,ny] = size(y);
    if ~exist('x','var')
        x = 1:nx;
    end

    %% Prepare Data
    op.Bands2Show = sort(op.Bands2Show,'descend');
    nBands = length(op.Bands2Show);
    if op.YHasBands
        YData = y(1,:,:);
        BandsData = y(2:end,:,:);
        if size(BandsData)~=nBands*2
            sdisp.YHasBands = op.YHasBands;
            sdisp.Bands2Show = op.Bands2Show;
            sdisp.nBands = nBands;
            sdisp.sizey = size(y);
            sdisp.sizeYData = size(YData);
            sdisp.sizeBandsData = size(BandsData);
            disp(sdisp)
            error('Cannot use BandsData: number of rows different than 2x nBands')
        end
    else
        YData = prctile(y,50,1);
        BandsData = zeros(nBands*2,nx,ny);
        for jb=1:nBands
            BandsData((jb-1)*2+[1,2],:,:) = prctile(y,50+op.Bands2Show(jb)/2*[-1,+1],1);
        end
    end
    YData = [permute(YData,[3,2,1]);op.AltData];
    nYData = size(YData,1);
    h.YData = YData;
    h.BandsData = BandsData;

    %% Plot bands
    InitHold = ishold;
    if nBands==1
        BandColorSlope = 0;
    else
        BandColorSlope = [-1,1]*op.ShadeFactors'/([1,-1]*op.Bands2Show([1,nBands])');
    end
    BandColorCt = op.ShadeFactors(1)-BandColorSlope*op.Bands2Show(nBands);
    for jy=1:ny
        for jB=1:nBands
            Band = op.Bands2Show(jB);
            BandPath = BandsData((jB-1)*2+[1,2],:,jy);
            op.ShadeColor = op.LineColor(jy,:)*0.8;
            BandColor = op.ShadeColor+...
                (1-op.ShadeColor)*(BandColorCt+BandColorSlope*Band);
            h.Bands(jB) = fill([x,x(end:-1:1)],[BandPath(1,:),BandPath(2,end:-1:1)],...
                               BandColor,'EdgeColor','none','FaceAlpha',op.ShadeAlpha(jB));
            hold on
        end
    end

    %% Plot lines
    % if op.ShowLegend
    %     if isempty(op.LegendString)
    %         op.LegendString{1} = 'Median';
    %         for j=2:ny
    %             op.LegendString{j} = sprintf('Alt %.0f',j-1);
    %         end
    %         for j=1:nBands*op.LegendWithBands
    %             op.LegendString{ny+j} = sprintf('%.0f%%',op.Bands2Show(j));
    %         end
    %     end
    %     if op.LegendWithBands
    %         op.LegendItems = h.Bands;
    %     end
    % end
    hp = vcplot(x,YData,op);
    h.Lines = hp.Lines;
    h.ZeroLine = hp.ZeroLine;
    h.Legend = hp.Legend;
    h.LegendItems = hp.LegendItems;
    h.LineOptions = hp.Options;
    % alpha(gca,op.FaceAlpha)

    %% some more stuff
    if ~InitHold
        hold off
    end
    xlim([x(1),x(end)])


    %% Exit
    h.XData = x;
    h.YData = YData;
    h.Options = op;

end
