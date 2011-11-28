%
%  regionCorrelation.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Input=========
%  fileID: fileID of open weight file
%  historyDimensions:
%  neuronOffsets: cell array giving byte offsets (rel. to 'bof') of neurons 
%  region: neuron region
%  col: neuron column
%  row: neuron row
%  depth: neuron depth
%  Output========
%  correlation coefficient of region as computed in O'Dhaniel: 2-d array (row, col) 

function [regionCorrelation] = regionCorrelation(fileID, historyDimensions, neuronOffsets, networkDimensions, region, depth, nrOfEyePositionsInTesting)

    % Validate input
    validateNeuron('regionCorrelation.m', networkDimensions, region, depth);
    
    % Cutoff for being designated as silent
    floatError = 0.01;
    
    numEpochs           = historyDimensions.numEpochs;
    numObjects          = historyDimensions.numObjects;
    numOutputsPrObject  = historyDimensions.numOutputsPrObject;
    y_dimension         = networkDimensions(region).y_dimension;
    x_dimension         = networkDimensions(region).x_dimension;
    
    result                 = regionHistory(fileID, historyDimensions, neuronOffsets, networkDimensions, region, depth, numEpochs);
    dataAtLastStepPrObject = squeeze(result(numOutputsPrObject, :, numEpochs, :, :)); % (object, row, col)
    
    if mod(numObjects, nrOfEyePositionsInTesting) ~= 0,
        error(['The number of "objects" is not divisible by nrOfEyePositionsInTesting: o=' num2str(numObjects) ', neps=' num2str(nrOfEyePositionsInTesting)]);
    end
    
    objectsPrEyePosition = numObjects / nrOfEyePositionsInTesting;
    regionCorrelation = zeros(y_dimension, x_dimension);
    
    for row = 1:y_dimension,
        for col = 1:x_dimension,
            
            corr = 0;
            
            for eyePosition = 1:(nrOfEyePositionsInTesting - 1),
                
                % Get final state of each fixation
                allDataForThisNeuron = dataAtLastStepPrObject(:, row, col);
                
                % Remove CLOSE to zero values to avoid floating point
                % issues and isConstant not detecting arrays which really
                % contain all zeros and hence will return nan
                allDataForThisNeuron(allDataForThisNeuron < floatError) = 0;
                
                % Get data from fixations belonging to two consecutive eye
                % positions
                firstPoint = 1 + (eyePosition - 1)*objectsPrEyePosition;
                lastPoint = firstPoint + 2*objectsPrEyePosition - 1;
                
                consecutiveEyePositions = allDataForThisNeuron(firstPoint:lastPoint);
                
                observationMatrix = reshape(consecutiveEyePositions, [objectsPrEyePosition 2]);
                
                if isConstant(observationMatrix(:, 1)) || isConstant(observationMatrix(:, 2)),
                    c = 0; % uncorrelated
                else
                
                    % correlation
                    correlationMatrix = corrcoef(observationMatrix);
                    c = correlationMatrix(1,2); % pick random nondiagonal element :)

                end
                
                corr = corr + c;
            end
            
            regionCorrelation(row, col) = corr / (nrOfEyePositionsInTesting - 1); % average correlatin
        end
    end
    
    function [test] = isConstant(arr)
        
        test = isequal(arr(1) * ones(length(arr),1), arr);
    