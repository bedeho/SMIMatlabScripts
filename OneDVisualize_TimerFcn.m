%
%  OneDVisualize_TimerFcn.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
% Draws graphics - TimerFcn callback 

function OneDVisualize_TimerFcn(obj, event, fileID, timeStep, numberOfSimultanousObjects, visualFieldSize, eyePositionFieldSize, fig)

    global OneDVisualizeTimer;      % must be global to be visible across callbacks
    global OneDVisualizeTimeObject; % to expose it to make it stoppable in console
    % LIP Parameters
    visualPreferenceDistance = 2;
    eyePositionPrefrerenceDistance = 2;
    
    gaussianSigma = 5; % deg
    sigmoidSlope = 0.5; % num
    
    % Elmsley eye model
    % DistanceToScreen          = ;     % Eye centers line to screen distance (meters)
    % Eyeball                   = ;     % Radius of each eyeball (meters)
    % EyeSpacing                = ;     % Half eye center distance (meters)
    % OnScreenTargetSpacing     = ;     % On screen target distance (meters)
    
    % Derived
    leftMostVisualPosition = -visualFieldSize/2;
    rightMostVisualPosition = visualFieldSize/2;
    leftMostEyePosition = -eyePositionFieldSize/2;
    rightMostEyePosition = eyePositionFieldSize/2;     
    
    visualPreferences = centerDistance(visualFieldSize, visualPreferenceDistance);
    eyePositionPreferences = centerDistance(eyePositionFieldSize, eyePositionPrefrerenceDistance);
    
    nrOfVisualPreferences = length(visualPreferences);
    nrOfEyePositionPrefrerence = length(eyePositionPreferences);
    
    % allocate space, is reused
    sigmoidPositive = zeros(nrOfVisualPreferences, nrOfEyePositionPrefrerence);
    sigmoidNegative = zeros(nrOfVisualPreferences, nrOfEyePositionPrefrerence);
    
    % Update time counter
    OneDVisualizeTimer = OneDVisualizeTimer + timeStep;
    total = uint64(OneDVisualizeTimer * 1000);
    
    fullMin = idivide(total, 60*1000);
    totalWithoutFullMin = mod(total, 60*1000);
    
    fullSec = idivide(totalWithoutFullMin, 1000);
    
    fullMs = mod(totalWithoutFullMin, 1000);
    
    % Read sample from file
    eyePosition = fread(fileID, 1, 'float');
    
    % Stop timer if this was last object in file
    if feof(fileID),
        stop(OneDVisualizeTimeObject);
        disp('object done********************');
        return;
    end
    
    % Consume reset
    if ~isnan(eyePosition),
         retinalPositions = fread(fileID, numberOfSimultanousObjects,'float'); % Fixation offset of target
         
         disp(['Read: eye =' num2str(eyePosition) ', ret=' num2str(retinalPositions)]);

         draw();
         
    else
        return;
    end
    
    % draw LIP sig*gauss neurons and input space
    function draw()
        
        % not in the matlab spirit, but I could not figure it out
        for i = 1:nrOfEyePositionPrefrerence,
            
            e = eyePositionPreferences(i);
            
            for j = 1:nrOfVisualPreferences,
                
                v = visualPreferences(j);

                % visual component
                sigmoidPositive(j,i) = exp(-(retinalPositions - v).^2/(2*gaussianSigma^2));
                sigmoidNegative(j,i) = exp(-(retinalPositions - v).^2/(2*gaussianSigma^2));
                
                % eye modulation
                sigmoidPositive(j,i) = sigmoidPositive(j,i) * 1/(1 + exp(sigmoidSlope * (eyePosition - e))); % positive slope
                sigmoidNegative(j,i) = sigmoidNegative(j,i) * 1/(1 + exp(-1 * sigmoidSlope * (eyePosition - e))); % negative slope
                
            end
        end
        
        % Clean up so that it is not hidden from us that stimuli is off
        % retina
        sigmoidPositive(sigmoidPositive < 0.001) = 0;
        sigmoidNegative(sigmoidNegative < 0.001) = 0;
        
        % + sigmoid
        subplot(3,1,1);
        imagesc(sigmoidPositive);
        colorbar
        set(gca,'YDir','normal');
        
        tickTitle = [sprintf('%02d', fullMin) ':' sprintf('%02d', fullSec) ':' sprintf('%03d',fullMs)];
        title(tickTitle);
        
        % - sigmoid
        subplot(3,1,2);
        imagesc(sigmoidNegative);
        colorbar
        set(gca,'YDir','normal');
        
        % input space
        subplot(3,1,3);
        x = eyePosition * ones(1, numberOfSimultanousObjects);
        y = retinalPositions;
        plot(x, y,'r*');
        axis([leftMostEyePosition rightMostEyePosition leftMostVisualPosition rightMostVisualPosition]);
    end

end