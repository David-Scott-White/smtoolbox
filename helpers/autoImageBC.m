function [x1, x2] = autoImageBC(image)
% Auto-adjust Image Range -------------------------------------------------
% Auto determination of brightness/ constrant for display of an image.
% Adapted from emperical results with ImageJ
%
% David S. White 
% 2021-09-19 
% -------------------------------------------------------------------------
image = image(:);
image(image==0) = []; 
[mu, sigma]= normfit(image);
x1 = mu-2*sigma; 
x2 = mu+6*sigma;
if x1<0
    x1 = 0;
end


