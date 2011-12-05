%
%  inspectWeights.m
%  SMI
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function inspectWeights(networkFile, filename, nrOfEyePositionsInTesting)
    
    % Import global variables
    declareGlobalVars();
    global floatError;
    
    % Load data
    [networkDimensions, neuronOffsets] = loadWeightFileHeader(networkFile); % Load weight file header
    [data, objectsPrEyePosition] = regionDataPrEyePosition(filename, nrOfEyePositionsInTesting); % (object, eye_position, row, col, region)
    
    % Setup activity plot
    fig = figure();
    clickAxis = subplot(3, 1, 1);
    v0 = data{end};
    v0(v0 > floatError) = 1;  % zero out error terms, and only count non error terms as 1.
    v1 = squeeze(sum(sum(v0))); % sum away
    v2 = v1(:,:,1);
    im = imagesc(v2);         % only do first region
    daspect([size(v2) 1]);
    colorbar;
    
    title('Number of testing locations responded to');
        
    % Setup callback
    set(im, 'ButtonDownFcn', {@responseCallBack});
    
    subplot(3, 1, 2);
    subplot(3, 1, 3);

    % makeFigureFullScreen(fig);
    
    % Keep open for callback
    fileID = fopen(networkFile);
    
    % Callback
    function responseCallBack(varargin)
        
        % Extract row,col
        pos = get(clickAxis, 'CurrentPoint');
        [row, col] = imagescClick(pos(1, 2), pos(1, 1), networkDimensions(2).y_dimension, networkDimensions(2).x_dimension);
        
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

