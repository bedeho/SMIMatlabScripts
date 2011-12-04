%
%  inspectRepresentation.m
%  SMI
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function inspectRepresentation(filename, nrOfEyePositionsInTesting)

    % Get dimensions
    [networkDimensions, historyDimensions] = getHistoryDimensions(filename);
    
    % Load data
    [data, objectsPrEyePosition] = regionDataPrEyePosition(filename, nrOfEyePositionsInTesting); % (object, eye_position, row, col, region)
    
    % Setup vars
    numRegions = length(networkDimensions);

    % Setup activity plot
    fig = figure();
    subplot(numRegions, 1, 1);
    v1 = permute(data, [3 4 5 1 2]); % expose the last three dimensions to be summed away
    v2 = sum(sum(sum(v1)));          % sum over all neurons in all regions
    im = imagesc(v2);
    colorbar;
        
    % Setup callback
    set(im, 'ButtonDownFcn', {@responseCallBack});
    
    % Iterate regions to do blank plot
    for r=2:numRegions,
        subplot(numRegions, 1, r);
    end
    
    makeFigureFullScreen(fig);
    
    % Callback
    function responseCallBack(varargin)
        
        % Extract row,col
        pos = get(axisVals(region-1, 2), 'CurrentPoint');
        [row, col] = imagescClick(pos(1, 2), pos(1, 1), networkDimensions(region).y_dimension, networkDimensions(region).x_dimension);

        disp(['You clicked R:' num2str(region) ', row:' num2str(pos(1, 2)) ', col:', num2str(pos(1, 1))]);
        disp(['You clicked R:' num2str(region) ', row:' num2str(row) ', col:', num2str(col)]);
        
        % Iterate regions to do response plot
        for r=2:numRegions,
            subplot(numRegions, 1, r);
            
            imagesc(data(row, col, :, :, r));
            
            hold;
        end
    end
end

% Made with random experiemtnation with imagesc behavior, MAY not work
% in other settings because of border BS, check it out later, use
% ginput() if possible 
function [row, col] = imagescClick(i, j, y_dimension, x_dimension)

    if i < 1
        row = 1;
    else
        row = floor(i);
    end

    if j < 0.5
        col = 1;
    else
        col = round(j);

        if col > x_dimension,
            col = x_dimension;
        end
    end
end

