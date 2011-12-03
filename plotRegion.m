%
%  plotRegion.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function [regionCorrelationPlot, corr] = plotRegion(filename, nrOfEyePositionsInTesting, region, depth)

    % Import global variables
    declareGlobalVars();

    % Open file
    fileID = fopen();
    
    % Read header
    [networkDimensions, historyDimensions, neuronOffsets, headerSize] = loadHistoryHeader(fileID);
    
    % Fill in missing arguments    
    if nargin < 4,
        depth = 1;                                  % pick top layer
        
        if nargin < 3,
            region = length(networkDimensions);     % pick last region
        end
    end
    
    if region < 2,
        error('Region is to small');
    end
    
    corr = regionCorrelation(fileID, historyDimensions, neuronOffsets, networkDimensions, region, depth, nrOfEyePositionsInTesting);

    regionCorrelationPlot = figure();
    imagesc(corr);
    colorbar;
    
    fclose(fileID);