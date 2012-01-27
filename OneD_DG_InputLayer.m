%
%  OneD_DG_InputLayer.m
%  SMI
%
%  Created by Bedeho Mender on 27/01/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%

function OneD_DG_InputLayer(dimensions, pattern)

    % Import
    global tempspacetemp;

    % v(1,x,y) - sigmoid positive
    % v(2,x,y) - sigmoid negative

    retinalPositions = pattern(2:end);
    eyePosition = pattern(1);
    
    % not in the matlab spirit, but I could not figure it out
    for i = 1:dimensions.nrOfVisualPreferences,

        x = dimensions.visualPreferences((dimensions.nrOfVisualPreferences + 1) - i); % flip it so that the top row prefers the right most retinal loc.

        for j = 1:dimensions.nrOfEyePositionPrefrerence,

            e = dimensions.eyePositionPreferences(j);

            % visual component
            tempspacetemp(1,i,j) = exp(-(retinalPositions - x).^2/(2*dimensions.gaussianSigma^2));
            tempspacetemp(2,i,j) = exp(-(retinalPositions - x).^2/(2*dimensions.gaussianSigma^2));

            % eye modulation
            tempspacetemp(1,i,j) = tempspacetemp(1,i,j) * 1/(1 + exp(dimensions.sigmoidSlope * (eyePosition - e))); % positive slope
            tempspacetemp(2,i,j) = tempspacetemp(2,i,j) * 1/(1 + exp(-1 * dimensions.sigmoidSlope * (eyePosition - e))); % negative slope
        end
    end
           
end