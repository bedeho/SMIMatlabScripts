%
%  regionCorrelation.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function [regionCorrelation] = regionCorrelation(filename)

    % Get dimensions
    [networkDimensions, historyDimensions] = getHistoryDimensions(filename);
    
    % Validate input
    validateNeuron('regionCorrelation.m', networkDimensions, region, depth);

    % Setup vars
    numRegions = length(networkDimensions);
    y_dimension = networkDimensions(numRegions).y_dimension;
    x_dimension = networkDimensions(numRegions).x_dimension;
    regionCorrelation = zeros(y_dimension, x_dimension);
    
    % Load data
    regionDataPrEyePosition = loadDataPrEyePosition(filename, nrOfEyePositionsInTesting);
    dataPrEyePosition = regionDataPrEyePosition{numRegions};

    % Compute correlation for each cell
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
                    c = correlationMatrix(1,2); % pick one of the two identical non-diagonal element :)

                end
                
                corr = corr + c;
            end
            
            regionCorrelation(row, col) = corr / (nrOfEyePositionsInTesting - 1); % average correlatin
        end
    end
    
    function [test] = isConstant(arr)
        
        test = isequal(arr(1) * ones(length(arr),1), arr);
    