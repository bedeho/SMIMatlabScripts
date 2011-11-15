%
%  DGSimple.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function DGSimple(filename)

    % General
    nrOfVisualTargetLocations   = 10;
    saccadeVelocity             = 400;	% (deg/s), http://www.omlab.org/Personnel/lfd/Jrnl_Arts/033_Sacc_Vel_Chars_Intrinsic_Variability_Fatigue_1979.pdf
    samplingRate                = 4;	% (Hz)
    fixationDuration            = 0.7;	% (s) - fixation period after each saccade
    saccadeAmplitude            = 40;   % (deg) - angular magnitude of each saccade, after which there is a fixation periode

    % Elmsley eye model
    % DistanceToScreen          = ;     % Eye centers line to screen distance (meters)
    % Eyeball                   = ;     % Radius of each eyeball (meters)
    % EyeSpacing                = ;     % Half eye center distance (meters)
    % OnScreenTargetSpacing     = ;     % On screen target distance (meters)

    % non-Elmsley
    visualFieldSize = 200; % Entire visual field (rougly 100 per eye), (deg)

    % Derived
    timeStep = 1/samplingRate;
    saccadeDuration = saccadeAmplitude/saccadeVelocity;
    leftEdgeOfVisualField = -visualFieldSize/2;
    rightEdgeOfVisualField = visualFieldSize/2;

    % Open file
    fileID = fopen(filename,'w');

    % Make header
    numberOfSimultanousObjects = 1;

    fwrite(fileID, samplingRate, 'uint');               % Rate of sampling
    fwrite(fileID, numberOfSimultanousObjects, 'uint'); % Number of simultanously visible targets, needed to parse data

    % Output data sequence for each target
    targets = leftEdgeOfVisualField:visualFieldSize/nrOfVisualTargetLocations:rightEdgeOfVisualField;

    for t = targets,
        
        % Dynamical quantities
        state = 0;                                          % 0 = fixating, 1 = saccading
        stateTimer = 0;                                     % the duration of the present state
        eyePosition = leftEdgeOfVisualField;                % Center on 0, start on left edge (e.g. -100 deg)
    
        doTimeSteps();
        
        fwrite(fileID, NaN('single'), 'float'); % transform flag
    end

    % Close file
    fclose(fileID);

    function doTimeSteps()

        % Do all timesteps, 
        % inner loop terminates when eyes have saccaded past right edge of visual field
        while true,

            % Do one timestep
            remainederOfTimeStep = timeStep; % how much of present time step remains

            while remainederOfTimeStep > 0,

                if ~state, % fixating
                    timeToNextState = fixationDuration - stateTimer;
                else % saccading 
                    timeToNextState = saccadeDuration - stateTimer;
                end

                if timeToNextState < remainederOfTimeStep, % we can change state within remaining time

                    state ~= state;                                                   % change to fixation state
                    stateTimer = 0;                                                   % reset timer at fixation state
                    remainederOfTimeStep = remainederOfTimeStep - timeToNextState; % consume time
                    eyePosition = eyePosition + saccadeVelocity*timeToNextState;   % eyes move
                    
                else % we cannot change state within remaining time

                    stateTimer = stateTimer + remainederOfTimeStep;                   % move timer 
                    remainederOfTimeStep = 0;                                         % consume time
                    eyePosition = eyePosition + saccadeVelocity*remainederOfTimeStep; % eyes move
                end
            end

            % Output data point if we are still within visual field
            if eyePosition < rightEdgeOfVisualField,
                disp('writing');
                fwrite(fileID, eyePosition, 'float'); % Eye position (HFP)
                fwrite(fileID, t - eyePosition, 'float'); % Fixation offset of target
            else
                return;
            end
        end

    end

end