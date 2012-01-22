%
%  OneD_DG_TestOnTrained.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Purpose: Generates testing data which tests in exactly the training
%  positions and which makes the result of this test in the appropriate
%  format for the analysis scripts.
%

function OneD_DG_TestOnTrained(stimuliName)

    % Import global variables
    declareGlobalVars();
    
    global base;
    
    % Movement parameters
    fixationDuration = 0.2; % (s) 0
    
    % Make folder
    str = strsplit(stimuliName,'_');
    stimuliFolder = [base 'Stimuli/' char(str{1}) '_testOnTrained'];
    if ~isdir(stimuliFolder),
        mkdir(stimuliFolder);
    end
    
    % Load file
    [samplingRate, numberOfSimultanousObjects, visualFieldSize, eyePositionFieldSize, buffer] = OneD_Load(stimuliName);
    
    % Parse data
    [objects, minSequenceLength, objectsFound] = OneD_Parse(buffer);
    
    %{
    lastObjectEnd = 0;
    objectsFound = 0;
    minSequenceLength = bitmax; % Saves the number of data points per head centered location we will include
    for c = 1:length(buffer),
        
        eyePosition = buffer(c, 1);
        
        if isnan(eyePosition),
            objectsFound = objectsFound + 1;
            objects{objectsFound} = buffer((lastObjectEnd + 1):(c-1), :); % use cell to support varying stream sizes
            
            % Clean up duplicates
            %objects{objectsFound} = unique(objects{objectsFound}, 'rows');
            
            lastObjectEnd = c;
            
            % Check if this is the new shortest sequence
            minSequenceLength = min(minSequenceLength, length(objects{objectsFound}));
        end
    end
    %}
    
    % Use as nrOfEyePositionsInTesting in analysis
    nrOfEyePositionsInTesting = num2str(minSequenceLength)
    
    % Open file
    filename = [stimuliFolder '/data.dat'];
    fileID = fopen(filename,'w');

    % Make header
    numberOfSimultanousObjects = 1;

    fwrite(fileID, samplingRate, 'ushort');               % Rate of sampling
    fwrite(fileID, numberOfSimultanousObjects, 'ushort'); % Number of simultanously visible targets, needed to parse data
    fwrite(fileID, visualFieldSize, 'float');
    fwrite(fileID, eyePositionFieldSize, 'float');
    
    ticksPrSample = fixationDuration * samplingRate;
    
    if(ticksPrSample < 1) 
        error(['ticksPrSample < 1' ticksPrSample]);
    end
   
    % Output data sequence for each target
    for o = 1:objectsFound,
        for s = 1:minSequenceLength,
            
            % Duplicat sample and write out duplicates in column order
            repeatedSample = repmat(objects{o}(s,:)',1,ticksPrSample);
            fwrite(fileID, repeatedSample, 'float');
            
            % Inject transform stop
            fwrite(fileID, NaN('single'), 'float'); 
       end
    end

    % Close file
    fclose(fileID);
    
    % Create payload for xgrid
    startDir = pwd;
    cd(stimuliFolder);
    [status, result] = system('tar -cjvf xgridPayload.tbz data.dat');
    if status,
        error(['Could not create xgridPayload.tbz' result]);
    end
    cd(startDir);
    
end