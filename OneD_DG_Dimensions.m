%
%  OneD_DG_Dimensions.m
%  SMI
%
%  Created by Bedeho Mender on 27/01/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%

function [leftMostVisualPosition, rightMostVisualPosition, leftMostEyePosition, rightMostEyePosition, visualPreferences, eyePositionPreferences, nrOfVisualPreferences, nrOfEyePositionPrefrerence, targetBoundary] = OneD_DG_Dimensions()

    % Stimuli
    nrOfVisualTargetLocations   = 4;
    
    % Enviroment (non-Elmsley)
    visualFieldSize             = 200 % Entire visual field (rougly 100 per eye), (deg)
    targetRangeProportionOfVisualField = 0.5;
    % Elmsley eye model
    % DistanceToScreen          = ;     % Eye centers line to screen distance (meters)
    % Eyeball                   = ;     % Radius of each eyeball (meters)
    % EyeSpacing                = ;     % Half eye center distance (meters)
    % OnScreenTargetSpacing     = ;     % On screen target distance (meters)

    % LIP Parameters
    visualPreferenceDistance = 2;
    eyePositionPrefrerenceDistance = 2;
    gaussianSigma = 2; % deg
    sigmoidSlope = 50; % num
    
    % Place targets
    if nrOfVisualTargetLocations > 1,
        targets = centerN(visualFieldSize * targetRangeProportionOfVisualField, nrOfVisualTargetLocations);
        targetBoundary = targets(end);
    else
        targets = 0;
        targetBoundary = 10;
    end
    
    % targetBoundary = eccentricity of most extreme target in head space
    
    % Derive eye movement range is sufficiently confined to keep ANY
    % target on retina
    eyePositionFieldSize = visualFieldSize - 2*targets(end)
    leftMostEyePosition = -eyePositionFieldSize/2;
    rightMostEyePosition = eyePositionFieldSize/2; 
    
    % Retina
    leftMostVisualPosition = -visualFieldSize/2;
    rightMostVisualPosition = visualFieldSize/2;    
    
    % Place LIP preference in retinal/eye position domain
    visualPreferences = centerDistance(visualFieldSize, visualPreferenceDistance);
    eyePositionPreferences = centerDistance(eyePositionFieldSize, eyePositionPrefrerenceDistance);
    
    nrOfVisualPreferences = length(visualPreferences);
    nrOfEyePositionPrefrerence = length(eyePositionPreferences);
end