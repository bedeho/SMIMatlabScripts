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
    dimensions = OneD_DG_Dimensions()
    
    global tempspacetemp; % Export to OneD_DG_InputLayer
    
    % Allocate space, is reused
    tempspacetemp = zeros(2, dimensions.nrOfVisualPreferences, dimensions.nrOfEyePositionPrefrerence);

    [samplingRate, numberOfSimultanousObjects, visualFieldSize, eyePositionFieldSize, bufferTesting] = OneD_Load(stimuliName);
    [objects, minSequenceLength, objectsFound] = OneD_Parse(bufferTesting);
    
    dotproduct = zeros(objectsFound, objectsFound);
    
    for o1 = 1:objectsFound,
        
        o1
        for o2 = 1:objectsFound,
            
            tmp1 = objects{o1};
            tmp2 = objects{o2};
            
            % We just pick first row, as all rows should be identical!!
            pattern1 = tmp1(1,:);
            pattern2 = tmp2(1,:);
            
            OneD_DG_InputLayer(dimensions, pattern1);
            v1 = tempspacetemp;
            
            OneD_DG_InputLayer(dimensions, pattern2);
            v2 = tempspacetemp;
            
            dotproduct(o1,o2) = dot(v1(:),v2(:));
            
            %%/ normalize
            
        end
    end
    
    imagesc(dotproduct);
    
    str = [base 'Stimuli/' stimuliName '/correlation'];
    
    save str dotproduct; 

end