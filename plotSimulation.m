%
%  plotSimulation.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  PLOT REGION INVARIANCE FOR ALL SIMULATION FILES
%  Input=========
%  experiment: experiment name
%  simulation: simulation name

function [summary] = plotSimulation(experiment, simulation)

    % Import global variables
    declareGlobalVars();
    
    global EXPERIMENTS_FOLDER;

    simulationFolder = [EXPERIMENTS_FOLDER experiment '/' simulation '/'];

    % Iterate all network result folders in this simulation folder
    listing = dir(simulationFolder);

    % Preallocate struct array for summary
    summary = [];
    counter = 1;

    % Iterate dir and do plot for each folder
    for d = 1:length(listing),
        
        % We are only looking for directories, but not the
        % 'Training' directory, since it has network evolution in training
        directory = listing(d).name;
        
        if listing(d).isdir == 1 && ~strcmp(directory,'Training') && ~strcmp(directory,'.') && ~strcmp(directory,'..'),
            
            netDir = [simulationFolder directory];
            
            [fig, figImg, fullInvariance, meanInvariance, nrOfSingleCell, multiCell] = plotRegion([netDir '/firingRate.dat']);
            
            saveas(fig,[netDir '/result_1.fig']);
            saveas(figImg,[netDir '/result_1.png']);
            
            delete(fig);
            delete(figImg);
            
            % Save results for summary
            summary(counter).directory = directory;
            
            %summary(counter).fullInvariance = fullInvariance;
            %summary(counter).meanInvariance = meanInvariance;
            %summary(counter).multiCell = multiCell;
            %summary(counter).nrOfSingleCell = nrOfSingleCell;
            
            counter = counter + 1;
        end
    end
    