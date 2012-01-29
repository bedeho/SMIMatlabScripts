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
    
    % Load enviromental paramters
    dimensions = OneD_DG_Dimensions();
    
    % Movement parameters
    saccadeVelocity             = 400000000000;	% (deg/s), http://www.omlab.org/Personnel/lfd/Jrnl_Arts/033_Sacc_Vel_Chars_Intrinsic_Variability_Fatigue_1979.pdf
    samplingRate                = 50;	% (Hz)
    fixationDuration            = 0.2;  % 0.25;	% (s) - fixation period after each saccade
    saccadeAmplitude            = 10;    % (deg) - angular magnitude of each saccade, after which there is a fixation periode
    
    % Derived
    timeStep = 1/samplingRate;
    saccadeDuration = saccadeAmplitude/saccadeVelocity;
    
    % Open file
    filename = [stimuliFolder '/data.dat'];
    fileID = fopen(filename,'w');

    % Make header
    fwrite(fileID, samplingRate, 'ushort');               % Rate of sampling
    fwrite(fileID, dimensions.numberOfSimultanousObjects, 'ushort'); % Number of simultanously visible targets, needed to parse data
    fwrite(fileID, dimensions.visualFieldSize, 'float');
    fwrite(fileID, dimensions.eyePositionFieldSize, 'float');
   
    % Output data sequence for each target
    for t = dimensions.targets,
        
        % Dynamical quantities
        state = 0;                                      % 0 = fixating, 1 = saccading
        stateTimer = 0;                                 % the duration of the present state
        eyePosition = dimensions.leftMostEyePosition;              % Center on 0, start on left edge (e.g. -100 deg)
    
        % Save at t=0
        fwrite(fileID, eyePosition, 'float');           % Eye position (HFP)
        fwrite(fileID, t - eyePosition, 'float');       % Fixation offset of target

        % Output all samples for this target position
        doTimeSteps();
        
        fwrite(fileID, NaN('single'), 'float');         % transform flag
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
    
    % Save dimensions used
    save('dimensions.mat','dimensions');
    
    cd(startDir);
    
    % Generate complementary testing data
    OneD_DG_Test(stimuliName, dimensions.targetBoundary, dimensions.visualFieldSize, dimensions.eyePositionFieldSize);
    OneD_DG_TestOnTrained([stimuliName '_training']);
    
    % Generate correlation data
    OneD_DG_Correlation([stimuliName '_testOnTrained']);
    
    % Visualize
    OneD_Overlay([stimuliName '_training'],[stimuliName '_testOnTrained'])
    
    function doTimeSteps()

        % Do all timesteps, 
        % inner loop terminates when eyes have saccaded past right edge of visual field
        while true,

            % Do one timestep
            
            % We start by setting the remainder to the full time step
            % remainederOfTimeStep = how much of present time step remains
            remainederOfTimeStep = timeStep;

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
                    eyePosition = eyePosition + saccadeVelocity*consume;              % eyes move
                end
                
            end
            
            % Output data point if we are still within visual field
            if eyePosition < dimensions.rightMostEyePosition,
                %disp(['Saved: eye =' num2str(eyePosition) ', ret =' num2str(t - eyePosition)]); % relationhip is t = r + e
                fwrite(fileID, eyePosition, 'float'); % Eye position (HFP)
                fwrite(fileID, t - eyePosition, 'float'); % Fixation offset of target
            else
                return;
            end
            
        end

    end

end