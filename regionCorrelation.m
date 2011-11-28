%
%  regionCorrelation.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

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
    
    if mod(numObjects, nrOfEyePositionsInTesting) ~= 0,
        error(['The number of "objects" is not divisible by nrOfEyePositionsInTesting: o=' num2str(numObjects) ', neps=' num2str(nrOfEyePositionsInTesting)]);
    end
    
    objectsPrEyePosition   = numObjects / nrOfEyePositionsInTesting;
    
    % Pre-process data
    result                 = regionHistory(fileID, historyDimensions, neuronOffsets, networkDimensions, region, depth, numEpochs);
    
    % Get final state of each fixation
    dataAtLastStepPrObject = squeeze(result(numOutputsPrObject, :, numEpochs, :, :)); % (object, row, col)
    
    % Restructure to access data on eye position basis
    dataPrEyePosition      = reshape(dataAtLastStepPrObject, [objectsPrEyePosition nrOfEyePositionsInTesting y_dimension x_dimension]); % (object, eye_position, row, col)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    regionCorrelation = zeros(y_dimension, x_dimension);
    
    for row = 1:y_dimension,
        for col = 1:x_dimension,
            
            corr = 0;
            
            for eyePosition = 1:(nrOfEyePositionsInTesting - 1),
                
                observationMatrix = [dataPrEyePosition(:, eyePosition,row,col) dataPrEyePosition(:, eyePosition+1,row,col)];
                
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
    