%
%  inspectWeights.m
%  SMI
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function inspectWeights(networkFile, filename, nrOfEyePositionsInTesting)

    % Load data
    [networkDimensions, neuronOffsets] = loadWeightFileHeader(networkFile); % Load weight file header
    [data, objectsPrEyePosition] = regionDataPrEyePosition(filename, nrOfEyePositionsInTesting); % (object, eye_position, row, col, region)
    
    % Setup activity plot
    fig = figure();
    clickAxis = subplot(3, 1, 1);
    v1 = squeeze(sum(sum(data{end})));     % sum away
    v2 = v1(:,:,1);
    im = imagesc(v2); % only do first region
    daspect([size(v2) 1]);
    colorbar;
        
    % Setup callback
    set(im, 'ButtonDownFcn', {@responseCallBack});
    
    subplot(3, 1, 2);
    subplot(3, 1, 3);

    makeFigureFullScreen(fig);
    
    % Keep open for callback
    fileID = fopen(networkFile);
    
    % Callback
    function responseCallBack(varargin)
        
        % Extract row,col
        pos = get(clickAxis, 'CurrentPoint');
        [row, col] = imagescClick(pos(1, 2), pos(1, 1), networkDimensions(2).y_dimension, networkDimensions(2).x_dimension);

        disp(['You clicked R:' num2str(2) ', row:' num2str(pos(1, 2)) ', col:', num2str(pos(1, 1))]);
        disp(['You clicked R:' num2str(2) ', row:' num2str(row) ', col:', num2str(col)]);
        
        % Plot the two input layers
        subplot(3, 1, 2);
        weightBox1 = afferentSynapseMatrix(fileID, networkDimensions, neuronOffsets, 2, 1, row, col, 1, 1);
        imagesc(weightBox1);
        dim = size(weightBox1);
        daspect([dim 1]);
        colorbar;
        hold;
        
        subplot(3, 1, 3);
        weightBox2 = afferentSynapseMatrix(fileID, networkDimensions, neuronOffsets, 2, 1, row, col, 1, 2);
        imagesc(weightBox2);
        daspect([dim 1]);
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



