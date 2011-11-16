%
%  OneDVisualize_TimerFcn.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

% Draws graphics - TimerFcn callback 
function OneDVisualize_TimerFcn(obj, event, fileID, timeStep, numberOfSimultanousObjects, fig)

    global OneDVisualizeTimer;      % must be global to be visible across callbacks
    global OneDVisualizeTimeObject; % tried to expose it to make it stoppable in console.. didnt work
    
    % LIP Parameters
    visualFieldSize = 200; % (deg)
    visualPreferenceDistance = 2;
    eyePositionPrefrerenceDistance = 2;
    gaussianSigma = 5; % deg
    sigmoidSlope = 0.1; % num
    
    % Elmsley eye model
    % DistanceToScreen          = ;     % Eye centers line to screen distance (meters)
    % Eyeball                   = ;     % Radius of each eyeball (meters)
    % EyeSpacing                = ;     % Half eye center distance (meters)
    % OnScreenTargetSpacing     = ;     % On screen target distance (meters)
    
    % Derived
    leftEdgeOfVisualField = -visualFieldSize/2;
    rightEdgeOfVisualField = visualFieldSize/2;
    visualPreferences = leftEdgeOfVisualField:visualPreferenceDistance :rightEdgeOfVisualField;
    eyePositionPreferences = leftEdgeOfVisualField:eyePositionPrefrerenceDistance:rightEdgeOfVisualField;
    
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
    
    disp(OneDVisualizeTimer);
    
    % Read sample from file
    eyePosition = fread(fileID, 1, 'float');
    
    % Consume reset
    if ~isnan(eyePosition),
         retinalPositions = fread(fileID, numberOfSimultanousObjects,'float'); % Fixation offset of target
         
         disp(['eye: ' num2str(eyePosition) ', ret: ' num2str(retinalPositions) ]);

         draw();
         
    else
        disp('object done********************');
        
        % Stop timer if this was last object in file
        if feof(fileID),
            stop(OneDVisualizeTimeObject);
        end
    
        return;
    end
    
    % draw LIP sig*gauss neurons and input space
    function draw()
        
        % not in the matlab spirit, but I could not figure it out
        for i = 1:nrOfVisualPreferences,
            for j = 1:nrOfEyePositionPrefrerence,
                
                e = eyePositionPreferences(i);
                v = visualPreferences(j);
                
                % visual component
                sigmoidPositive(j,i) = exp(-(retinalPositions - v).^2/(2*gaussianSigma^2));
                sigmoidNegative(j,i) = exp(-(retinalPositions - v).^2/(2*gaussianSigma^2));
                
                % eye modulation
                sigmoidPositive(j,i) = sigmoidPositive(j, i) * 1/(1 + exp(sigmoidSlope * (eyePosition - e))); % positive slope
                sigmoidNegative(j,i) = sigmoidNegative(j, i) * 1/(1 + exp(-1 * sigmoidSlope * (eyePosition - e))); % negative slope
                
            end
        end
        
        % + sigmoid
        subplot(3,1,1);
        imagesc(sigmoidPositive);
        %colorbar
        set(gca,'YDir','normal');
        axis square;
        
        tickTitle = [sprintf('%02d', fullMin) ':' sprintf('%02d', fullSec) ':' sprintf('%03d',fullMs)];
        title(tickTitle);
        
        % - sigmoid
        subplot(3,1,2);
        imagesc(sigmoidNegative);
        %colorbar
        set(gca,'YDir','normal')
        axis square;
        
        % input space
        subplot(3,1,3);
        x = eyePosition * ones(1, numberOfSimultanousObjects);
        y = retinalPositions;
        plot(x, y,'r*');
        axis([leftEdgeOfVisualField rightEdgeOfVisualField leftEdgeOfVisualField rightEdgeOfVisualField]);
        axis square;
    end

end