function exportFrame(image, varargin)
% -------------------------------------------------------------------------
% Export frame from video in smViewer to publishFigure (.mat, .png, .pdf)
%
%
% David S. White
% 2021-02-01
% MIT
% -------------------------------------------------------------------------
aoi = 0; % bounding box only
scaleBar = 0;
umPerPixel = 0;
time_s = 0;
filePath = 0;

% add option for figure size in future, display range

for i = 1:2:length(varargin)-1
    switch varargin{i}
        case 'aoi'
            aoi = varargin{i+1};
        case 'scaleBar'
            scaleBar = varargin{i+1};
        case 'umPerPixel'
            umPerPixel = varargin{i+1};
        case 'format'
            format = varargin{i+1};
        case 'quality'
            quality = varargin{i+1};
        case 'time_s'
            time_s = varargin{i+1};
        case 'filePath'
            filePath = varargin{i+1};
    end
end

if ~filePath
    [file, path] = uiputfile('video.mp4');
    filePath = [path,file];
end

%%
figExist = findobj('type','figure','name','Frame Export');
if ~isempty(figExist)
    close('Frame Export');
end

[xImage, yImage] = size(image);
[x1, x2] = autoImageBC(image);

hFig = figure('Name', 'Frame Export', 'NumberTitle', 'off');;
imshow(image, 'DisplayRange', [x1,x2],'Border', 'tight', 'Interpolation','nearest');
pause(1)
hold on;
if aoi
    for j = 1:length(aoi)
        rectangle('Position', aoi(j,:), 'EdgeColor', 'r');
    end
    pause(1);
end

if time_s
    s = seconds(round(time_s));
    s.Format = 'hh:mm:ss';
    x1 = xImage-round(0.98*xImage);
    y1 =yImage-round(0.98*xImage);
    text(x1,y1,char(s),'Color','w','FontSize',7,'FontName','Helvetica');
end

if scaleBar && umPerPixel
    pos1 = round(0.98*xImage);
    pos2 = round(0.95*yImage);
    pixels = scaleBar/umPerPixel;
    p1 = pos1-pixels; % 10
    sbX = p1:pos1;
    sbY = sbX*0 + pos1;
    plot(sbX, sbY,'-w','linewidth',1)
    text(pos1, pos2, [num2str(scaleBar), '\mum'], 'Color', 'w','FontSize',7,...
        'FontName', 'Helvertica', 'HorizontalAlignment', 'right');
end

[file,path] = uiputfile([filePath, '.pdf']);
if file
    filePathSave = [path,file(1:end-4)];
    % hFig.Children.Children = flip(hFig.Children.Children);
    publishFigure(hFig, 'figureName', filePathSave, 'saveOnly', 1);
    
    % note, text will be behind image in PDF (do not know how to fix...)
    % and wrong color... and wrong font. WTF... 
    
end
close('Frame Export');