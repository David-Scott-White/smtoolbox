function h = plotDwellTimeCorrelations(dwellPair, binWidth, plotCorr, showData)
% -------------------------------------------------------------------------
% Plot dwell time correlations
% -------------------------------------------------------------------------
%
% input: 
%   dwellPair. [N,2] matrix. see dwellTimeCorrelations.m
%   maxBin = numeric. 
%   showData = bool. Plot scatter of raw data points
%
% UNDER CONSTRUCTION FOR MORE PLOTTING OPTIONS
% 
% Author: David S. White
% Updated: 2021-10-22
% License: MIT
% -------------------------------------------------------------------------

x = dwellPair(:,1); 
y = dwellPair(:,2); 

r = corrcoef(x,y);
r = r(1,2);
N = length(x); 

minBin = -1; 
maxBin = 4; 

[counts, bins] = hist3(log10([x,y]), {minBin:binWidth:maxBin,minBin:binWidth:maxBin});
xx = min(bins{1}):binWidth:max(bins{1});
yy = min(bins{2}):binWidth:max(bins{2});
[X1, Y1] = meshgrid(bins{1}, bins{2});
[X2, Y2] = meshgrid(xx,yy); 
counts = interp2(X1, Y1, counts', X2, Y2); 

h = figure; 
contour(xx,yy,counts); 
colormap(jet); 
colorbar

if plotCorr
    hold on
    plot(minBin:maxBin, minBin:maxBin,'--k')
end

if showData
    hold on
    scatter(log10(x), log10(y), 3,'filled', 'o', 'MarkerEdgeColor','k', 'MarkerFaceColor', 'k');
end

% titleText = ['N = ', num2str(length(x)), ', {\it r} = ', num2str(round(r,2))];
% title(titleText)
%text(maxB-1.25, maxB-0.25, [['N = ', num2str(length(x))], newline,...
%    ['{\itr} = ', num2str(round(r,2))]], 'Fontsize',5)
% text(0.25, maxBin-0.1, [['N = ',N], newline, ['{\itr} = ', num2str(round(r,2))]], 'Fontsize',5)
xticks(minBin:1:maxBin);
yticks(minBin:1:maxBin)

xlim([minBin+1 maxBin])
ylim([minBin+1, maxBin])

end