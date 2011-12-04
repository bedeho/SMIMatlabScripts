%
%  inspectWeights.m
%  SMI
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function inspectWeights(folder, networkFile, nrOfEyePositionsInTesting)

    % Get dimensions
    [networkDimensions, historyDimensions] = getHistoryDimensions(filename);
    
    % Load data
    [data, objectsPrEyePosition] = regionDataPrEyePosition(filename, nrOfEyePositionsInTesting); % (object, eye_position, row, col, region)
    
    % Setup activity plot
    fig = figure();
    subplot(3, 1, 1);
    v1 = sum(sum(data));     % sum away 
    im = imagesc(v1(:,:,1)); % only do first region
    colorbar;
        
    % Setup callback
    set(im, 'ButtonDownFcn', {@responseCallBack});
    
    subplot(3, 1, 2);
    subplot(3, 1, 3);
    
    % Make data available for callback
    fileID = fopen(filename);
    [networkDimensions, historyDimensions, neuronOffsets, headerSize] = loadHistoryHeader(filename); % required
    
    makeFigureFullScreen(fig);
    
    % Callback
    function responseCallBack(varargin)
        
        % Extract row,col
        pos = get(axisVals(region-1, 2), 'CurrentPoint');
        [row, col] = imagescClick(pos(1, 2), pos(1, 1), networkDimensions(region).y_dimension, networkDimensions(region).x_dimension);

        disp(['You clicked R:' num2str(region) ', row:' num2str(pos(1, 2)) ', col:', num2str(pos(1, 1))]);
        disp(['You clicked R:' num2str(region) ', row:' num2str(row) ', col:', num2str(col)]);
        
        % Plot the two input layers
        subplot(3, 1, 2);
        weightBox1 = afferentSynapseMatrix(fileID, networkDimensions, neuronOffsets, 2, 1, row, col, 1, 1);
        imagesc(weightBox1);
        colorbar;
        hold;
        
        subplot(3, 1, 3);
        weightBox2 = afferentSynapseMatrix(fileID, networkDimensions, neuronOffsets, 2, 1, row, col, 1, 2);
        imagesc(weightBox2);
        colorbar;
        hold;
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



