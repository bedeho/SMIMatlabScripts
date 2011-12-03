%
%  loadDataPrEyePosition.m
%  SMI
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Result: (object, eye_position, row, col, region)

function [dataPrEyePosition, networkDimensions, historyDimensions, neuronOffsets, headerSize] = loadDataPrEyePosition(networkDimensions, historyDimensions, neuronOffsets, headerSize, filename, nrOfEyePositionsInTesting)

    % Open files
    firingFileID = fopen(filename);
    
    % Read header
    [] = loadHistoryHeader(firingFileID);
    
    % Setup vars
    depth               = 1;
    
    numRegions          = length(networkDimensions);
    numEpochs           = historyDimensions.numEpochs;
    numObjects          = historyDimensions.numObjects;
    numOutputsPrObject  = historyDimensions.numOutputsPrObject;
    y_dimension         = networkDimensions(numRegions).y_dimension;
    x_dimension         = networkDimensions(numRegions).x_dimension;
    
    if mod(numObjects, nrOfEyePositionsInTesting) ~= 0,
        error(['The number of "objects" is not divisible by nrOfEyePositionsInTesting: o=' num2str(numObjects) ', neps=' num2str(nrOfEyePositionsInTesting)]);
    end
    
    objectsPrEyePosition   = numObjects / nrOfEyePositionsInTesting;
    
    % Pre-process data
    result                 = regionHistory(firingFileID, historyDimensions, neuronOffsets, networkDimensions, numRegions, depth, numEpochs);
    
    % Get final state of each fixation
    dataAtLastStepPrObject = squeeze(result(numOutputsPrObject, :, numEpochs, :, :)); % (object, row, col)
    
    % Restructure to access data on eye position basis
    dataPrEyePosition      = reshape(dataAtLastStepPrObject, [objectsPrEyePosition nrOfEyePositionsInTesting y_dimension x_dimension]); % (object, eye_position, row, col)
    
    % Zero out error terms
    floatError = 0.01; % Cutoff for being designated as silent
    dataPrEyePosition(dataPrEyePosition < floatError) = 0;