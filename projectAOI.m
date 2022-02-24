function rois = projectAOI(rois, video)
% Replaces projectTimeSeries 
% Use if there is no drift correction to the centroids, only video or none
%
% Still slow, need a faster approach...
%
% Author: David S. White 
% Date 2022-02-01
% License: MIT
% -------------------------------------------------------------------------

[nROIs, nChannels] = size(rois);
nTotal = nChannels*nROIs;
p = 1;
wb = waitbar(0, 'Projecting AOIs...');
removeIdx = []; 
for j = 1:nChannels
    videoIter = video{j};
    nFrames = size(videoIter, 3);
    emptyTimeSeries = zeros(nFrames,1);
    % emptySpot = zeros(rois(1,1).boundingBox(1,3)+1, rois(1,1).boundingBox(1,4)+1, nFrames);
    
    modSize = 2; 
    spotSize = rois(1,1).boundingBox(1,4); 
    xx = spotSize+(modSize*2)+1;
    emptySpot = zeros(xx, xx, nFrames);
    for i = 1:nROIs
        rois(i,j).timeSeries = emptyTimeSeries;
        rois(i,j).spot = emptySpot;
        bb = rois(i,j).boundingBox(1,:);
        for k = 1:nFrames
            
            im1 = imcrop(videoIter(:,:,k), bb); % will need to fix!
            %im1 = im1(1:end-1,:);
            %im1 = im1(:,1:end-1);
            
            bb2 = bb;
            bb2(1) = bb(1)-modSize; 
            bb2(2) = bb(2)-modSize; 
            bb2(3:4) = bb(3:4)+modSize*2; 
            im3 = imcrop(videoIter(:,:,k), bb2); % adds 1..  
            
            if size(im3,1)~=xx || size(im3,2)~=xx
                removeIdx = [removeIdx, i];
            else
                rois(i,j).spot(:,:,k) = im3; % was im1
                rois(i,j).timeSeries(k,1) = sum(sum(im1));
            end
            
           % Remove ROIs that drop to 0 (drift correction)
%            if rois(i,j).timeSeries(k,1) == 0
%                removeIdx = [removeIdx; i];
%                break
%            end
        end
        waitbar(p/nTotal, wb);
        p = p +1;
    end
end
close(wb)

% need some way to detect beads

% Remove ROIs that drop to 0 (drift correction)
rois(removeIdx,:) = [];