function AOIs = transformAOI(AOIs, radius, channelTransformation)
% David S. White 
% 2021-09-19 

% Transform AOIs using a provided tform
%
% rois: struct with rois.centroid
% tform: result from image regresitation 
% radius 

AOIs = [AOIs, AOIs];
if ~exist('channelTransformation', 'var') || isempty(channelTransformation)
     msgbox('Warning: No Transform provided.');
else
    centroids = vertcat(AOIs(:,1).Centroid); 
    % centroids = applyTransform(centroids, channelTransformation);
    centroids = transformPointsInverse(channelTransformation.tformAOI, centroids);
    diameter = AOIs(1,1).boundingBox(4); 
    boundingBox = makeBoundingBox(centroids, diameter); 
    for i = 1:length(AOIs)
        AOIs(i,2).Centroid = centroids(i,:);
        AOIs(i,2).boundingBox = boundingBox(i,:);
    end
end

