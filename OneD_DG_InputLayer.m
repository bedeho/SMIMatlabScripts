%
%  OneD_DG_InputLayer.m
%  SMI
%
%  Created by Bedeho Mender on 27/01/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%

function v = OneD_DG_InputLayer(visualPreferences, eyePositionPreferences, pattern)

    % allocate space, is reused
    nrOfVisualPreferences = length(visualPreferences);
    nrOfEyePositionPrefrerence = length(eyePositionPreferences);
    
    v = zeros(2, nrOfVisualPreferences, nrOfEyePositionPrefrerence);
       
    % v(1,x,y) - sigmoid positive
    % v(2,x,y) - sigmoid negative

    retinalPositions = pattern(2:end);
    eyePosition = pattern(1);
    
    % not in the matlab spirit, but I could not figure it out
    for i = 1:nrOfVisualPreferences,

        v = visualPreferences((nrOfVisualPreferences + 1) - i); % flip it so that the top row prefers the right most retinal loc.

        for j = 1:nrOfEyePositionPrefrerence,

            e = eyePositionPreferences(j);

            % visual component
            v(1,i,j) = exp(-(retinalPositions - v).^2/(2*gaussianSigma^2));
            v(2,i,j) = exp(-(retinalPositions - v).^2/(2*gaussianSigma^2));

            % eye modulation
            v(1,i,j) = v(1,i,j) * 1/(1 + exp(sigmoidSlope * (eyePosition - e))); % positive slope
            v(2,i,j) = v(2,i,j) * 1/(1 + exp(-1 * sigmoidSlope * (eyePosition - e))); % negative slope
        end
    end
           
end