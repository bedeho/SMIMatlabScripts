%
%  OneD_Visualize.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Purpose: visualizes 1d data
%

function OneD_Visualize(stimuliName)
  
    global OneDVisualizeTimeObject; % exporting
    global buffer;                  % exporting
    global lineCounter;           % exporting             
    global nrOfObjectsFoundSoFar;   % exporting
    
    % Init
    lineCounter = 1;
    nrOfObjectsFoundSoFar = 0;
    
    % Parameters
    playAtPrcntOfOriginalSpeed = 1;
    
    % Load file
    [samplingRate, numberOfSimultanousObjects, visualFieldSize, eyePositionFieldSize, buffer] = OneD_Load(stimuliName);

    % Derived
    timeStep = 1/samplingRate;
    period = timeStep / playAtPrcntOfOriginalSpeed;
    
    % Make figure
    fig = figure();

    % Setup timer
    % Good video on timers: http://blogs.mathworks.com/pick/2008/05/05/advanced-matlab-timer-objects/
    OneDVisualizeTimeObject = timer('Period', period, 'ExecutionMode', 'fixedSpacing');
    set(OneDVisualizeTimeObject, 'TimerFcn', {@OneDVisualize_TimerFcn, timeStep, numberOfSimultanousObjects, visualFieldSize, eyePositionFieldSize, fig});
    set(OneDVisualizeTimeObject, 'StopFcn', {@OneDVisualize_StopFcn});

    % Start timer
    start(OneDVisualizeTimeObject);
end