%
%  OneD_DG_Correlation.m
%  SMI
%
%  Created by Bedeho Mender on 27/01/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%

function OneD_DG_Correlation(stimuliName)

    % Import global variables
    declareGlobalVars();
    
    global base;

    % Generate correlation data
    [leftMostVisualPosition, rightMostVisualPosition, leftMostEyePosition, rightMostEyePosition, visualPreferences, eyePositionPreferences, nrOfVisualPreferences, nrOfEyePositionPrefrerence, targetBoundary] = OneD_DG_Dimensions()
    [samplingRate, numberOfSimultanousObjects, visualFieldSize, eyePositionFieldSize, bufferTesting] = OneD_Load(stimuliName);
    [objects, minSequenceLength, objectsFound] = OneD_Parse(bufferTesting);
    
    dotproduct = zeros(objectsFound, objectsFound);
    
    for o1 = 1:objectsFound,
        for o2 = 1:objectsFound,
            
            tmp1 = objects{o1};
            tmp2 = objects{o2};
            
            % We just pick first row, as all rows should be identical!!
            pattern1 = tmp1(1,:);
            pattern2 = tmp2(1,:);
            
            v1 = OneD_DG_InputLayer(visualPreferences, eyePositionPreferences, pattern1);
            v2 = OneD_DG_InputLayer(visualPreferences, eyePositionPreferences, pattern2);
            
            dotproduct(o1,o2) = dot(v1(:),v2(:));          
        end
    end
    
    imagesc(dotproduct);
    
    save([base 'Stimuli/' stimuliName '/correlation'], dotproduct); 

end