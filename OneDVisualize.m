%
%  1DVisualize.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Purpose: visualizes 1d data
%

function OneDVisualize(filename)

    global OneDVisualizeTimer;
    global OneDVisualizeTimeObject;
    OneDVisualizeTimer = 0;
    
    playAtPrcntOfOriginalSpeed = 0.5;

    % Open file
    fileID = fopen(filename);

    % Read header
    samplingRate = fread(fileID, 1, 'ushort');               % Rate of sampling
    numberOfSimultanousObjects = fread(fileID, 1, 'ushort'); % Number of simultanously visible targets, needed to parse data
    visualFieldSize = fread(fileID, 1, 'float');           % Size of visual field
    eyePositionFieldSize = fread(fileID, 1, 'float');

    % Derived
    timeStep = 1/samplingRate;
    period = timeStep / playAtPrcntOfOriginalSpeed;
    
    % Make figure
    fig = figure();

    % Setup timer
    % Good video on timers: http://blogs.mathworks.com/pick/2008/05/05/advanced-matlab-timer-objects/
    OneDVisualizeTimeObject = timer('Period', period, 'ExecutionMode', 'fixedSpacing');
    set(OneDVisualizeTimeObject, 'TimerFcn', {@OneDVisualize_TimerFcn, fileID, timeStep, numberOfSimultanousObjects, visualFieldSize, eyePositionFieldSize, fig});
    set(OneDVisualizeTimeObject, 'StopFcn', {@OneDVisualize_StopFcn, fileID});

    % Start timer
    start(OneDVisualizeTimeObject);
end