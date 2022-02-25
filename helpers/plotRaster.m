function h = plotRaster(events, varargin)
% -------------------------------------------------------------------------
% Raster plot of idealized traces
% -------------------------------------------------------------------------
%
% events = cell(N,1) events for each molecule. see findEvents.m
%
% Example Code (Temp)
%
% N = 100; 
% events = cell(N,1);
% for i = 1:N
%     fps = 1;
%     q = [0, 0.0025; 0.05, 0];
%     ss = simulateQ(q, [0, 1], 1e2, fps);
%     events{i} = findEvents(ss); 
% end
% sortTraces = 1; 
% plotRaster(traces, 'frameRate_s', 1/fps)
%
% Author: David S. White
% Updated: 2021-10-28
% License: MIT
% -------------------------------------------------------------------------
%%
% Set Default parameters
sortTraces  = 1;   % boolean
colorScheme = 'k'; % need a gradient for multiple states
frameRate_s = 0;   % else, returns frames

for i = 1:2:length(varargin)-1
    switch varargin{i}
        case 'sortTraces'
            sortTraces = varargin{i+1};
        case 'colorScheme'
            colorScheme = varargin{i+1};
        case 'frameRate_s'
            frameRate_s = varargin{i+1};
    end
end

concatEvents = cell2mat(events);
minState = min(concatEvents(:,4));
maxFrame = max(concatEvents(:,2));
% nEvents = size(concatEvents); 

% Sort traces?
N = size(events,1);
if sortTraces
    firstEventFrame = zeros(N,1);
    for i = 1:N
        if size(events{i},1) == 1
            if events{i}(4) == minState
                firstEventFrame(i) = events{i}(2);
            else
                firstEventFrame(i) = events{i}(1);
            end
            
        else
            if events{i}(1,4) > min(events{i}(:,4))
                firstEventFrame(i) = 1;
            else
                firstEventFrame(i) = events{i}(2,1);
            end
        end
    end
    [~,sortedIdx] = sort(firstEventFrame);
    events = events(sortedIdx, :);
end

h = figure; hold on
xlim([0, maxFrame]);
ylim([0.5, N])
for i = 1:N
    for j = 1:size(events{i},1)
        if events{i}(j,4) > minState
            s0 = events{i}(j,1);
            s1 = events{i}(j,3);
            % xstart, ystart, xlength, ylength
            rectangle('Position',[s0, i-0.5, s1, 1], 'EdgeColor', colorScheme, 'FaceColor', colorScheme);
        end
    end
end

if frameRate_s
    x1 = xticklabels; 
    x2 = x1; 
    for i = 1:length(x1)
        x2{i} = num2str(str2double(x1{i})*frameRate_s);
    end
    xlabel('Time (s)');
    set(gca,'XTickLabel',x2);
else
    xlabel('Frames');
end
ylabel('Molecule');
set(gca, 'tickdir', 'out');

