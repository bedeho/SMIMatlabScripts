%
%  plotSynapseHistory.m
%  SMI (VisBack copy)
%
%  Created by Bedeho Mender on 16/01/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%
%  Input=========
%  filename: filename of weight file
%  region: region to plot, V1 = 1
%  depth: region depth to plot
%  row: neuron row
%  col: neuron column
%  maxEpoch: last epoch to plot
%  Output========
%  Plots line plot of activity for spesific neuron

function plotSynapseHistory(folder, region, depth, row, col, includeSynapses, maxEpoch)

    % Import global variables
    declareGlobalVars();
    
    % Get history dimensions
    [networkDimensions, historyDimensions] = getHistoryDimensions([folder '/firingRate.dat']);
    
    if nargin < 7,
        maxEpoch = historyDimensions.numEpochs; % pick all epochs
        
        if nargin < 6,
            includeSynapses = true;
        end
    end
    
    streamSize = maxEpoch * historyDimensions.epochSize;
    
    % Setup figure
    fig = figure();
    
    % Plot synapses
    if includeSynapses,
        
        synapseFile = [folder '/synapticWeights.dat'];

        % Open file
        fileID = fopen(synapseFile);

        % Read header
        [networkDimensions, historyDimensions, neuronOffsets] = loadSynapseWeightHistoryHeader(fileID);

        % Get history array
        synapses = synapseHistory(fileID, networkDimensions, historyDimensions, neuronOffsets, region, depth, row, col, maxEpoch);

        % Plot history of each synapse
        for s=1:length(synapses),

            v = synapses(s).activity(:, :, 1:maxEpoch);
            vect = reshape(v, [1 streamSize]);
            synapseLine = plot(vect);
            hold on;
        end

        fclose(fileID);
        
    end
    
    % Plot neuron dynamics
    [traceLine, m1] = plotFile('trace.dat', 'g');
    [activationLine, m2] = plotFile('activation.dat', 'y');
    [firingLine, m3] = plotFile('firingRate.dat', 'r');
    [stimulationLine, m4] = plotFile('stimulation.dat', 'k');
    mFinal = max([0.51 m1 m2 m3 m4]); % Used for axis

    % GRID

    % No longer valid, transforms dont exist!
    % Draw vertical divider for each transform
    %if historyDimensions.numOutputsPrTransform > 1,
    %    x = historyDimensions.numOutputsPrTransform : historyDimensions.numOutputsPrTransform : streamSize;
    %    gridxy(x, 'Color', 'c', 'Linestyle', ':');
    %end
    
    hold on
    
    % Draw vertical divider for each object
    if historyDimensions.numObjects > 1,
        x = historyDimensions.objectSize : historyDimensions.objectSize : streamSize;
        gridxy(x, 'Color', 'b', 'Linestyle', '--');
    end
    
    hold on
    
    % Draw vertical divider for each epoch
    if maxEpoch > 1,
        x = historyDimensions.epochSize : historyDimensions.epochSize : streamSize;
        gridxy(x, 'Color', 'k', 'Linestyle', '-');
    end
    
    hold on
    
    title(['Row ' num2str(row) ' Col ' num2str(col) ' Region ' num2str(region)]);
    
    if includeSynapses,
        legend([synapseLine firingLine traceLine activationLine stimulationLine],'Synapses','Firing','Trace','Activation','Stimulation');
    else
        legend([firingLine traceLine activationLine stimulationLine],'Firing','Trace','Activation','Stimulation');
    end
    
    axis([0 streamSize -0.02 mFinal]);
    
    function [lineHandle, maxValue] = plotFile(filename, color)
        
        firingRateFile = [folder '/' filename];

        % Open file
        fileID = fopen(firingRateFile);

        % Read header
        [networkDimensions, historyDimensions, neuronOffsets] = loadHistoryHeader(firingRateFile);

        % Get history array
        activity = neuronHistory(fileID, networkDimensions, historyDimensions, neuronOffsets, region, depth, row, col, maxEpoch);

        % Plot
        v = activity(:, :, 1:maxEpoch);

        streamSize = maxEpoch * historyDimensions.epochSize;
        vect = reshape(v, [1 streamSize]);
        lineHandle = plot(vect, color);
        hold on;
        
        maxValue = max(vect);

        fclose(fileID);
    end
end