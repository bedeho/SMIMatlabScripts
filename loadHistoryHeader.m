%
%  loadHistoryHeader.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Purpose: 
%  * Load header of history file
%  Input:
%  * filname
%  Output:
%  *networkDimensions: struct array (dimension,depth) of regions (incl. V1)
%  *historyDimensions: struct (numEpochs,numObjects,numTransforms,numOutputsPrTransform)
%  *headerSize: bytes read, this is where the file pointer is left

function [networkDimensions, historyDimensions, neuronOffsets, headerSize] = loadHistoryHeader(filename)

    % Import global variables
    declareGlobalVars();
    
    global SOURCE_PLATFORM_USHORT;
    global SOURCE_PLATFORM_USHORT_SIZE;
    global SOURCE_PLATFORM_FLOAT_SIZE;

    % Seek to start of file
    fileID = fopen(filename);
    
    % Read history dimensions & number of regions
    v = fread(fileID, 4, SOURCE_PLATFORM_USHORT);
    
    historyDimensions.numEpochs = v(1);
    historyDimensions.numObjects = v(2);
    historyDimensions.numOutputsPrObject = v(3);
    numRegions = v(4);
    
    % Compound stream sizes
    historyDimensions.objectSize = historyDimensions.numOutputsPrObject;
    historyDimensions.epochSize = historyDimensions.objectSize * historyDimensions.numObjects;
    historyDimensions.streamSize = historyDimensions.epochSize * historyDimensions.numEpochs;
    
    % Preallocate struct array
    networkDimensions(numRegions).y_dimension = [];
    networkDimensions(numRegions).x_dimension = [];
    networkDimensions(numRegions).depth = []; 
    neuronOffsets = cell(numRegions,1); % {1} is left empty because V1 is not included
    
    % Read dimensions
    for r=1:numRegions,
        
        y_dimension = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
        x_dimension = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
        depth       = fread(fileID, 1, SOURCE_PLATFORM_USHORT);
        
        networkDimensions(r).y_dimension = y_dimension;
        networkDimensions(r).x_dimension = x_dimension;
        networkDimensions(r).depth = depth;
        
        neuronOffsets{r}(y_dimension, x_dimension, depth).offset = [];
        neuronOffsets{r}(y_dimension, x_dimension, depth).nr = [];
    end
    
    % We compute the size of header just read
    headerSize = SOURCE_PLATFORM_USHORT_SIZE*(4 + 3 * numRegions);
    
    % Compute and store the offset of each neuron's datastream in the file, not V1
    offset = headerSize; 
    nrOfNeurons = 1;
    for r=2:numRegions,
        for d=1:networkDimensions(r).depth, % Region depth
            for row=1:networkDimensions(r).y_dimension, % Region row
                for col=1:networkDimensions(r).x_dimension, % Region col
                    
                    neuronOffsets{r}(row, col, d).offset = offset;
                    neuronOffsets{r}(row, col, d).nr = nrOfNeurons;
                    
                    offset = offset + historyDimensions.streamSize * SOURCE_PLATFORM_FLOAT_SIZE;
                    nrOfNeurons = nrOfNeurons + 1;
                end
            end
        end
    end
    
    % Close file
    fclose(fileID);