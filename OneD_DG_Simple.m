%
%  OneD_DG_Simple.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Purpose: Generates the simplest possible 1d dynamical data
%

function OneD_DG_Simple(stimuliName)

    % Import global variables
    declareGlobalVars();
    
    global base;

    stimuliFolder = [base 'Stimuli/' stimuliName '_training'];
    
    % Make folder
    if ~isdir(stimuliFolder),
        mkdir(stimuliFolder);
    end

    % General
    nrOfVisualTargetLocations   = 4;
    saccadeVelocity             = 400;	% (deg/s), http://www.omlab.org/Personnel/lfd/Jrnl_Arts/033_Sacc_Vel_Chars_Intrinsic_Variability_Fatigue_1979.pdf
    samplingRate                = 10;	% (Hz)
    fixationDuration            = 1;	% (s) - fixation period after each saccade
    saccadeAmplitude            = 10;   % (deg) - angular magnitude of each saccade, after which there is a fixation periode

    % Elmsley eye model
    % DistanceToScreen          = ;     % Eye centers line to screen distance (meters)
    % Eyeball                   = ;     % Radius of each eyeball (meters)
    % EyeSpacing                = ;     % Half eye center distance (meters)
    % OnScreenTargetSpacing     = ;     % On screen target distance (meters)

    % non-Elmsley
    visualFieldSize = 200 % Entire visual field (rougly 100 per eye), (deg)
    
    % Derived
    timeStep = 1/samplingRate;
    saccadeDuration = saccadeAmplitude/saccadeVelocity;
    targets = centerN(visualFieldSize, nrOfVisualTargetLocations);
    
    % Make sure eye movement range is sufficiently confined to always keep any
    % target on retina
    eyePositionFieldSize = visualFieldSize - targets(end)
    leftMostEyePosition = -eyePositionFieldSize/2;
    rightMostEyePosition = eyePositionFieldSize/2; 
     
    % Open file
    fileID = fopen([stimuliFolder '/data.dat'],'w');

    % Make header
    numberOfSimultanousObjects = 1;

    fwrite(fileID, samplingRate, 'ushort');               % Rate of sampling
    fwrite(fileID, numberOfSimultanousObjects, 'ushort'); % Number of simultanously visible targets, needed to parse data
    fwrite(fileID, visualFieldSize, 'float');
    fwrite(fileID, eyePositionFieldSize, 'float');
   
    % Output data sequence for each target
    for t = targets,
        
        % Dynamical quantities
        state = 0;                                      % 0 = fixating, 1 = saccading
        stateTimer = 0;                                 % the duration of the present state
        eyePosition = leftMostEyePosition;              % Center on 0, start on left edge (e.g. -100 deg)
    
        doTimeSteps();
        disp('object done*******************');
        fwrite(fileID, NaN('single'), 'float'); % transform flag
    end

    % Close file
    fclose(fileID);
    
    % Generate complementary testing data
    OneD_DG_Test(stimuliName, visualFieldSize, eyePositionFieldSize);

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

                switchState = timeToNextState <= remainederOfTimeStep;
                
                if switchState, % we must change state within remaining time

                    state = ~state;                                                   % change state
                    stateTimer = 0;                                                   % reset timer for new state
                    consume = timeToNextState;

                else % we cannot change state within remaining time

                    stateTimer = stateTimer + remainederOfTimeStep;                   % move timer
                    consume = remainederOfTimeStep;                                   
                    % we could break here, but what the heck
                end
                
                remainederOfTimeStep = remainederOfTimeStep - consume;                % consume time
                    
                if xor(state, switchState),
                    eyePosition = eyePosition + saccadeVelocity*consume;               % eyes move
                end
                
            end
            
            % Output data point if we are still within visual field
            if eyePosition < rightMostEyePosition,
                disp(['Saved eye :' num2str(eyePosition) ', ret ' num2str(t - eyePosition)]);
                fwrite(fileID, eyePosition, 'float'); % Eye position (HFP)
                fwrite(fileID, t - eyePosition, 'float'); % Fixation offset of target
            else
                return;
            end
            
        end

    end

end