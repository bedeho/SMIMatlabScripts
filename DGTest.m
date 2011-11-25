%
%  DGTest.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Purpose: Generate testing data

function DGTest(filename)

    % General
    nrOfVisualTargetLocations   = 4;
    nrOfEyePositions            = 10;
    samplingRate                = 5;	% (Hz)
    fixationDuration            = 1;	% (s) - fixation period after each saccade

    % non-Elmsley
    visualFieldSize = 200 % Entire visual field (rougly 100 per eye), (deg)
    
    % Derived
    timeStep                    = 1/samplingRate;
    samplesPrLocation           = fixationDuration / timeStep;
    
    targets                     = centerN(visualFieldSize, nrOfVisualTargetLocations);
    eyePositionFieldSize        = visualFieldSize - targets(end) % Make sure eye movement range is sufficiently confined to always keep any target on retina
    eyePositions                = centerN(eyePositionFieldSize, nrOfEyePositions);
    
    % Open file
    fileID = fopen(filename,'w');

    % Make header
    fwrite(fileID, samplingRate, 'ushort');               % Rate of sampling
    fwrite(fileID, 1, 'ushort');                          % Number of simultanously visible targets, needed to parse data
    fwrite(fileID, visualFieldSize, 'float');
    fwrite(fileID, eyePositionFieldSize, 'float');
   
    % Output data sequence for each target
    for e = eyePositions,
        for t = targets,
            for sampleCounter = 1:samplesPrLocation,
            
                disp(['Saved eye :' num2str(e) ', ret ' num2str(t - e)]);
                fwrite(fileID, e, 'float'); % Eye position (HFP)
                fwrite(fileID, t - e, 'float'); % Fixation offset of target
            end
        end
        
        disp('object done*******************');
        fwrite(fileID, NaN('single'), 'float'); % transform flag
    end

    % Close file
    fclose(fileID);
    
end