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
  
    % Exporting
    global OneDVisualizeTimeObject; 
    global buffer;                  
    global lineCounter;                          
    global nrOfObjectsFoundSoFar;
    global timeStep;
    global fig;

    global dimensions;
    dimensions = OneD_DG_Dimensions();
    
    %{
    global numberOfSimultanousObjects;
    global eyePositionFieldSize;
    global visualFieldSize;
    global visualPreferences;
    global eyePositionPreferences;
    global leftMostEyePosition; 
    global rightMostEyePosition;
    global leftMostVisualPosition;
    global rightMostVisualPosition;
    
    % Load dimensions
    dimensions = OneD_DG_Dimensions();
    visualPreferences = dimensions.visualPreferences;
    eyePositionPreferences = dimensions.eyePositionPreferences;
    leftMostEyePosition = dimensions.leftMostEyePosition;
    rightMostEyePosition = dimensions.rightMostEyePosition;
    leftMostVisualPosition = dimensions.leftMostVisualPosition;
    rightMostVisualPosition = dimensions.rightMostVisualPosition;
    %}

    % Load file
    [samplingRate, numberOfSimultanousObjects, visualFieldSize, eyePositionFieldSize, buffer] = OneD_Load(stimuliName);
    
    % Init
    lineCounter = 1;
    nrOfObjectsFoundSoFar = 0;
    fig = figure();
    playAtPrcntOfOriginalSpeed = 1;                 % Parameters
    timeStep = 1/samplingRate;                      % Derived
    period = timeStep / playAtPrcntOfOriginalSpeed; % Derived
    
    % Setup timer
    % Good video on timers: http://blogs.mathworks.com/pick/2008/05/05/advanced-matlab-timer-objects/
    OneDVisualizeTimeObject = timer('Period', period, 'ExecutionMode', 'fixedSpacing');
    set(OneDVisualizeTimeObject, 'TimerFcn', {@OneDVisualize_TimerFcn});
    set(OneDVisualizeTimeObject, 'StopFcn', {@OneDVisualize_StopFcn});

    % Start timer
    start(OneDVisualizeTimeObject);
end