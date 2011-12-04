%
%  plotRegion.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function [regionCorrelationPlot, corr] = plotRegion(filename, nrOfEyePositionsInTesting, region, depth)

    % Get dimensions
    [networkDimensions, historyDimensions] = getHistoryDimensions(filename);
    
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
    
    % Compute region correlation
    corr = regionCorrelation(filename, nrOfEyePositionsInTesting);
    
    % Plot region correlation
    regionCorrelationPlot = figure();
    imagesc(corr{region-1});
    colorbar;
