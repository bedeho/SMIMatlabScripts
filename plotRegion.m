%
%  plotRegion.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  PLOT REGION INVARIANCE
%  Input=========
%  filename: filename of weight file
%  standalone: whether gui should be shown (i.e standalone == true)
%  region: region to plot, V1 = 1
%  depth: region depth to plot
%  row: neuron row
%  col: neuron column

function [regionCorrelationPlot] = plotRegion(filename, nrOfEyePositionsInTesting, region, depth)

    % Import global variables
    declareGlobalVars();

    % Open file
    fileID = fopen(filename);
    
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
    
    numEpochs           = historyDimensions.numEpochs;
    numObjects          = historyDimensions.numObjects;
    numOutputsPrObject  = historyDimensions.numOutputsPrObject;
    y_dimension         = networkDimensions(region).y_dimension;
    x_dimension         = networkDimensions(region).x_dimension;
    
    result                 = regionHistory(fileID, historyDimensions, neuronOffsets, networkDimensions, region, depth, numEpochs);
    dataAtLastStepPrObject = result(numOutputsPrObject, :, numEpochs, :, :); % (object, row, col)
    
    if mod(numObjects, nrOfEyePositionsInTesting) != 0,
        error(['The number of "objects" is not divisible by nrOfEyePositionsInTesting: o=' num2str(numObjects) ', neps=' num2str(nrOfEyePositionsInTesting)]);
    end
    
    objectsPrEyePosition = numObjects / nrOfEyePositionsInTesting;
    regionCorrelation = zeros(y_dimension, x_dimension);
    
    regionCorrelationPlot = figure();
    
    for row = 1:y_dimension,
        for col = 1:x_dimension,
            
            corr = 0;
            
            for eyePosition = 1:(nrOfEyePositionsInTesting - 1),
                
                % Get final state of each fixation
                allDataForThisNeuron = dataAtLastStepPrObject(:, row, col);
                
                % Get data from fixations belonging to two consecutive eye
                % positions
                firstPoint = 1 + (eyePosition - 1)*objectsPrEyePosition;
                lastPoint = first + 2*objectsPrEyePosition - 1;
                
                consecutiveEyePositions = allDataForThisNeuron(firstPoint:lastPoint);
                
                observationMatrix = reshape(consecutiveEyePositions, [objectsPrEyePosition 2]);
                
                % Compute correlation
                correlationMatrix = corrcoef(observationMatrix);
                corr = corr + correlationMatrix(1,2); % pick random nondiagonal element :)
            end
            
            regionCorrelation(row, col) = corr / (nrOfEyePositionsInTesting - 1); % average correlatin
        end
    end
    
    fclose(fileID);