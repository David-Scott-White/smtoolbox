function h = publishFigure(h, varargin)
% -------------------------------------------------------------------------
% Modify Figure (h) for publication
% -------------------------------------------------------------------------
%
%
% David S. White
% 2021-10-19
% -------------------------------------------------------------------------

% WORK IN  PROGRESS
% set defaults

saveOnly = 0; 
figureName = [];
figureSize = [];
fontName = 'Arial';
fontSize = 7;
legendFontSize = 5;
legendTokenSize = [10, 6];
tickDir = 'out';
box = 'off';
plotColor = 'k';
showImage = 0;

for i = 1:2:length(varargin)-1
    switch varargin{i}
        case 'figureName'
            figureName = varargin{i+1};
        case 'figureSize'
            figureSize = varargin{i+1};
        case 'fontName'
            fontName = varargin{i+1};
        case 'fontSize'
            fontSize = varargin{i+1};
        case 'tickDir'
            tickDir = varargin{i+1};
        case 'box'
            box = varargin{i+1};
        case 'plotColor'
            plotColor = varargin{i+1};
        case 'showImage'
            showImage = varargin{i+1};
        case 'legendFontSize'
            legendFontSize = varargin{i+1};
        case 'legendTokenSize'
            legendTokenSize = varargin{i+1};
        case 'saveOnly'
            saveOnly = varargin{i+1};
    end
end

if ~saveOnly
%     set(gca,'fontsize',fontSize,'fontname', fontName, 'tickdir',tickDir, 'box',box,...
%         'XColor', plotColor, 'YColor', plotColor);
    
        set(gca,'fontsize',fontSize,'fontname', fontName, 'tickdir',tickDir, 'box',box,...
        'XColor', plotColor);
    
    set(h, 'DefaultAxesFontName', fontName);
    set(h, 'DefaultTextFontName', fontName);
    
    % h.FontSize = fontSize;
    % h.FontName = fontName;
    % h.XColor = plotColor;
    % h.YColor = plotColor;
    % h.TickDir = tickDir;
    % h.CurrentAxes.Box = box;
    if ~isempty(figureSize)
        h.Units = 'inches';
        h.Position = [0, 0, figureSize(1), figureSize(2)];
    end
    
    hh  = findobj('-property','FontSize');
    for i = 1:length(hh)
        hh(i).FontSize = fontSize;
    end
    
    % check for legend, modify
    if ~isempty(legendTokenSize)
        hh  = findobj('Type', 'Legend');
        for i = 1:length(hh)
            hh(i).FontSize = legendFontSize;
            hh(i).ItemTokenSize = legendTokenSize;
        end
    end
end
% Save (as a .mat, .pdf, and .png);
if isempty(figureName)
    [file,path] = uiputfile('.fig'); 
    figureName = [path,file(1:end-4)];
end
savefig(h, figureName);
print(h, figureName,'-dpdf')
% print(h,'-dpng', '-r300', figureName); % issue with not recognizing font...
exportgraphics(h, [figureName, '.png'], 'Resolution', 300);

% Note may need to increase java heap memory. Prefences->General->Java Heap
% Memory
%
%exportgraphics(h, [figureName, '.pdf'])

if showImage
    close(h);
    A = imshow(imread([figureName,'.png']), 'InitialMagnification', 100);
end

end
