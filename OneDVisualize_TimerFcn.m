%
%  OneDVisualize_TimerFcn.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Draws graphics - TimerFcn callback 

function OneDVisualize_TimerFcn(obj, event, timeStep, numberOfSimultanousObjects, visualFieldSize, eyePositionFieldSize, fig)

    global OneDVisualizeTimeObject; % to expose it to make it stoppable in console

    global buffer;
    global lineCounter;      % must be global to be visible across callbacks
    global nrOfObjectsFoundSoFar;
    
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
    OneDVisualizeTimer = (lineCounter - nrOfObjectsFoundSoFar)*timeStep;
    total = uint64(OneDVisualizeTimer * 1000);
    
    fullMin = idivide(total, 60*1000);
    totalWithoutFullMin = mod(total, 60*1000);
    
    fullSec = idivide(totalWithoutFullMin, 1000);
    
    fullMs = mod(totalWithoutFullMin, 1000);
    
    % Read sample file
    if lineCounter <= length(buffer),
        eyePosition = buffer(lineCounter, 1);
    else
        stop(OneDVisualizeTimeObject);
        return;
    end
    
    % Consume reset
    if ~isnan(eyePosition),

        retinalPositions = buffer(lineCounter, 2:(numberOfSimultanousObjects + 1)); 
         
        disp(['Read: eye =' num2str(eyePosition) ', ret=' num2str(retinalPositions)]);
        
        draw();
        
        lineCounter = lineCounter + 1;
  
    else
        lineCounter = lineCounter + 1;
        nrOfObjectsFoundSoFar = nrOfObjectsFoundSoFar + 1;
        disp('object done********************');
        return;
    end
    
    % draw LIP sig*gauss neurons and input space
    function draw()
        
        % not in the matlab spirit, but I could not figure it out
        for i = 1:nrOfVisualPreferences,
            
            v = visualPreferences((nrOfVisualPreferences + 1) - i); % flip it so that the top row prefers the right most retinal loc.

            for j = 1:nrOfEyePositionPrefrerence,
                
                e = eyePositionPreferences(j);
                
                % visual component
                sigmoidPositive(i,j) = exp(-(retinalPositions - v).^2/(2*gaussianSigma^2));
                sigmoidNegative(i,j) = exp(-(retinalPositions - v).^2/(2*gaussianSigma^2));
                
                % eye modulation
                sigmoidPositive(i,j) = sigmoidPositive(i,j) * 1/(1 + exp(sigmoidSlope * (eyePosition - e))); % positive slope
                sigmoidNegative(i,j) = sigmoidNegative(i,j) * 1/(1 + exp(-1 * sigmoidSlope * (eyePosition - e))); % negative slope

                %sigmoidPositive(i,j) = sigmoidPositive(i,j) * exp(-(eyePosition - e)^2/(2*gaussianSigma^2)); % positive slope
                %sigmoidNegative(i,j) = sigmoidNegative(i,j) * exp(-(eyePosition - e)^2/(2*gaussianSigma^2)); % negative slope

            end
        end
        
        % Clean up so that it is not hidden from us that stimuli is off
        % retina
        sigmoidPositive(sigmoidPositive < 0.001) = 0;
        sigmoidNegative(sigmoidNegative < 0.001) = 0;
        
        % + sigmoid
        subplot(3,1,1);
        imagesc(sigmoidPositive);
        daspect([eyePositionFieldSize visualFieldSize 1]);
        
        tickTitle = [sprintf('%02d', fullMin) ':' sprintf('%02d', fullSec) ':' sprintf('%03d',fullMs)];
        title(tickTitle);
        
        % - sigmoid
        subplot(3,1,2);
        imagesc(sigmoidNegative);
        daspect([eyePositionFieldSize visualFieldSize 1]);
        
        % input space
        subplot(3,1,3);
        
        % cleanup nan
        temp = buffer;
        v = isnan(buffer); % v(:,1) = get logical indexes for all nan rows
        temp(v(:,1),:) = [];  % blank out all these rows
        
        % plot
        rows = 1:(lineCounter - nrOfObjectsFoundSoFar);
        for o = 1:numberOfSimultanousObjects,
            plot(temp(rows, 1), temp(rows ,o + 1) , 'o');
            
            hold on;
        end
        daspect([eyePositionFieldSize visualFieldSize 1]);
        axis([leftMostEyePosition rightMostEyePosition leftMostVisualPosition rightMostVisualPosition]);
        
        %x = eyePosition * ones(1, numberOfSimultanousObjects);
        %y = retinalPositions;
        %plot(x, y,'r*');
        axis([leftMostEyePosition rightMostEyePosition leftMostVisualPosition rightMostVisualPosition]);
    end

end