function [mdl, RMSE, R2, h] = linearRegression(x, y, fitIntercept, plotData)
%% David S. White 
% 2023-07-14

% simple function to perform linear regression of y on x 
% will return 95% prediction bounds and compute RMSE, R2
% makes a nice plot 

% add in options for fit display? Color?

% requires matlab curve fitting toolbox 
if nargin < 3
    fitIntercept = 1; 
end
if nargin < 4
    plotData = 0;
end
if fitIntercept
ft = fittype('a + b*x',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'a','b'});
else
    ft = fittype('b*x',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'b'});
end
x = x(:);
y = y(:);

% normal equation to estimate parameters
if fitIntercept
    X = [ones(length(x),1) x];
    p0 = X\y;
    mdl = fit(x, y, ft, 'StartPoint', [p0(1), p0(2)]);
else
    p0 = x\y;
    mdl = fit(x, y, ft, 'StartPoint', p0(1));
end

xx = linspace(min(x), max(10), 100); 
Yhat = feval(mdl, x); 
R2 = 1 - sum((y - Yhat).^2)/sum((y - mean(y)).^2);
RMSE = sqrt((sum((y - Yhat).^2))/length(y));
if plotData
    xx = linspace(min(x), max(x), 100); 
    xx = xx(:);
    yy = feval(mdl, xx);
    CIF = predint(mdl, xx, 0.95,'Functional');
    h = figure;
    hold on
    patch([xx' fliplr(xx')], [CIF(:,2)' fliplr(CIF(:,1)')],...
        'r', 'FaceColor', 'r', 'EdgeColor','none', 'FaceAlpha', 0.1);
    plot(xx,yy, '-r')
    plot(x,y, 'ok', 'MarkerFaceColor', 'w')
    legend('95% CI', 'Fit', 'Data', 'Location', 'Best')
    xlabel('x');
    ylabel('y')
else
    h = [];
end
disp('Linear Regression:')
disp(['>> Slope: ', num2str(mdl.b)])
if fitIntercept
    disp(['>> Intercept: ', num2str(mdl.a)])
else
    disp('>> Intercept: 0')
end
disp(['>> R2: ', num2str(R2)])
disp(['>> RMSE: ', num2str(RMSE)])


end