function writeImagesToVideo(video, varargin)
% Export video processed in smViewer to tif format
%
% * requires VideoWriter
%
% David S. White
% 2021-02-01
% MIT
% -------------------------------------------------------------------------
frameRate = 10;
aoi = 0; % bounding box only
scaleBar = 0;
umPerPixel = 0;
% format = '.mp4'; % only option for mac. For windows, use AVI
quality = 100;
time_s = 0; 
filePath = 0; 
displayRange = []; 

for i = 1:2:length(varargin)-1
    switch varargin{i}
        case 'frameRate'
            frameRate = varargin{i+1};
        case 'aoi'
            aoi = varargin{i+1};
        case 'scaleBar'
            scaleBar = varargin{i+1};
        case 'umPerPixel'
            umPerPixel = varargin{i+1};
        %case 'format'
        %    format = varargin{i+1};
        case 'quality'
            quality = varargin{i+1};
        case 'time_s'
            time_s = varargin{i+1};
        case 'filePath'
            filePath = varargin{i+1};
        case 'displayRange'
            displayRange = varargin{i+1};
    end
end

if ~filePath
    [file, path] = uiputfile('video.mp4');
    filePath = [path,file]; 
end

if isempty(displayRange)
    temp = video(:);
    temp(temp==0)= [];
    [mu,sigma] = normfit(temp);
    x1 = mu-2*sigma;
    x2 = mu+6*sigma;
    displayRange = [x1, x2];
end

%%
[xVideo, yVideo, nFrames] = size(video);

figExist = findobj('type','figure','name','Video Preview');
if ~isempty(figExist)
    close('Video Preview');
end

for i = 1:nFrames
    if i == 1
        hFig = figure('Name', 'Video Preview', 'NumberTitle', 'off');
        %x0 = hFig.Position;
        %hFig.Position = [x0(1), x0(2), xVideo*2, yVideo*2];
        imshow(video(:,:,i), 'DisplayRange', displayRange, 'Border', 'tight',...
            'InitialMagnification', 1000 , 'Interpolation','nearest');
        pause(1)
        hold on;
        if aoi
            for j = 1:length(aoi)
                rectangle('Position', aoi(j,:), 'EdgeColor', 'r', 'linewidth', 1);
            end
            pause(1); 
        end
        
        % scalebar (no need to upate)
        % need to compute, need to draw line
        if scaleBar && umPerPixel
            pixels = scaleBar/umPerPixel;
            p0 = xVideo-10; 
            p1 = xVideo-10-pixels;
            sbX = p1:p0;
            sbY = sbX*0 + yVideo-10;
            plot(sbX, sbY,'-w','linewidth',1)
            text(p0, yVideo-20, [num2str(scaleBar), '\mum'], 'Color', 'w','FontSize',12, 'HorizontalAlignment', 'right');
        end
        
        % no need to update everything else % add in options for display
        if time_s
            s = seconds(round(time_s));
            s.Format = 'hh:mm:ss'; 
            timestr = char(s(i));
            text(10,10,timestr,'Color','w','FontSize',14);
            pause(1)
        end
        
    else
        h = gca;
        % update text
        if time_s
            timestr = char(s(i));
            h.Children(1).String = timestr;
        end
        h.Children(end).CData = video(:,:,i);
    end
    
    % add conditions here
    F(i) = getframe(gcf);
    drawnow
    % writeVideo(writerObj, F(i));
    
end
%close(writerObj);
close('Video Preview');

% create the video writer with 1 fps

[file,path] = uiputfile(filePath);
disp(['Saving: ', file])
if file
    writerObj = VideoWriter([path,file],  'MPEG-4');
    writerObj.Quality = quality;
    writerObj.FrameRate = frameRate;
    
    % open the video writer
    open(writerObj);
    % write the frames to the video
    for i=1:nFrames
        writeVideo(writerObj, F(i));
    end
    % close the writer object
    close(writerObj);
    
end
disp(['>> Saved.'])
