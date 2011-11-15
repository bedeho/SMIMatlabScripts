%
%  OneDVisualize_StopFcn.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

% Finishes up - StopFcn callback
function OneDVisualize_StopFcn(obj, event, fileID)

    global OneDVisualizeTimeObject;
    
    % Delete timer
    delete(OneDVisualizeTimeObject);

    % Close file
    fclose(fileID);
end