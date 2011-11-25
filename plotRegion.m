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


function [fig, figImg, fullInvariance, meanInvariance, nrOfSingleCell, multiCell] = plotRegion(filename, region, depth)

    % Import global variables
    declareGlobalVars();
    
    global INFO_ANALYSIS_FOLDER;

    % Open file
    fileID = fopen(filename);
    
    % Read header
    [networkDimensions, historyDimensions, neuronOffsets, headerSize] = loadHistoryHeader(fileID);
    
    % Fill in missing arguments    
    if nargin < 3,
        depth = 1;                                  % pick top layer
        
        if nargin < 2,
            region = length(networkDimensions);     % pick last region
        end
    end
    
    if region < 2,
        error('Region is to small');
    end
    
    numEpochs = historyDimensions.numEpochs;
    numTransforms = historyDimensions.numTransforms;
    regionDimension = networkDimensions(region).dimension; 
    MaxInfo = log2(historyDimensions.numObjects);
    numCells = regionDimension*regionDimension;
    
    % Allocate data structure
    invariance = zeros(regionDimension, regionDimension, historyDimensions.numObjects);
    bins = zeros(numTransforms + 1,1);
    
    % Setup Max vars
    fullInvariance = 0;
    meanInvariance = 0;
    
    fig = figure();
    figImg = figure();
    
    floatError = 0.1;
    
    tic
    
    [pathstr, name, ext] = fileparts(filename);
    
    disp(['***Processing' pathstr]);
    
    barPlot = zeros(historyDimensions.numObjects, numTransforms);
    
    % Iterate objects
    for o = 1:historyDimensions.numObjects,           % pick all objects,
        
        % Zero out from last object
        bins = 0*bins;
        
        % Old school: this was before I started using regionHistory and was
        % array jedi!
        for row = 1:regionDimension,

            for col = 1:regionDimension,

                % Get history array
                activity = neuronHistory(fileID, networkDimensions, historyDimensions, neuronOffsets, region, depth, row, col, numEpochs); % pick last epoch

                % Count number of non zero elements
                count = length(find(activity(historyDimensions.numOutputsPrTransform, :, o, numEpochs) > floatError));

                % Save in proper bin and in invariance surface
                invariance(row, col, o) = count;
                bins(count + 1) = bins(count + 1) + 1;
            end
        end
        
        b = bins(2:length(bins));
        figure(fig); % Set as present figure
        subplot(3, 1, 1);
        plot(b);
        hold all;
        
        barPlot(o,:) = b;
        
        % Update max values
        fullInvariance = fullInvariance + b(numTransforms); % The latter is the number of neurons that are fully invariant
        meanInvariance = meanInvariance + dot((b./(sum(b))),1:numTransforms); % The latter is the mean level of invariance
    end
    
    fclose(fileID);
    
    figure(figImg); % Set as present figure
    bar(barPlot'); %./numCells Normalize
    hold all;
    axis tight;
    
    figure(fig); % Set as present figure
    axis tight;
    