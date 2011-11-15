%
%  1DVisualize.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function OneDVisualize(filename)

    global OneDVisualizeTimer;
    global OneDVisualizeTimeObject;
    OneDVisualizeTimer = 0;
    
    playBackSlowDownUp = 3; 

    % Open file
    fileID = fopen(filename);

    % Read header
    samplingRate = fread(fileID, 1, 'uint');               % Rate of sampling
    numberOfSimultanousObjects = fread(fileID, 1, 'uint'); % Number of simultanously visible targets, needed to parse data

    % Derived
    timeStep = 1/samplingRate;
    period = timeStep * playBackSlowDownUp;
    
    % Make figure
    fig = figure();

    % Setup timer
    % Good video on timers: http://blogs.mathworks.com/pick/2008/05/05/advanced-matlab-timer-objects/
    OneDVisualizeTimeObject = timer('Period', period, 'ExecutionMode', 'fixedSpacing');
    set(OneDVisualizeTimeObject, 'TimerFcn', {@OneDVisualize_TimerFcn, fileID, timeStep, numberOfSimultanousObjects, fig});
    set(OneDVisualizeTimeObject, 'StopFcn', {@OneDVisualize_StopFcn, fileID});

    % Start timer
    start(OneDVisualizeTimeObject);
end