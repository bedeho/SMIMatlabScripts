%
%  1DVisualize.m
%  VisBack
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function OneDVisualize(filename)

% Elmsley eye model
% DistanceToScreen          = ;     % Eye centers line to screen distance (meters)
% Eyeball                   = ;     % Radius of each eyeball (meters)
% EyeSpacing                = ;     % Half eye center distance (meters)
% OnScreenTargetSpacing     = ;     % On screen target distance (meters)

% LIP Parameters
visualFieldSize = 200; % Entire visual field (rougly 100 per eye), (deg)
visualPreferencePerDeg = 1;
eyePositionPrefrerencePerDeg = 1;
playBackSpeedUp = 1/10; % 

gaussianSigma = 5; % deg
sigmoidSlope = 10; % num

% Open file
fileID = fopen(filename,'w');

% Read header
samplingRate = fread(fileID, 1, 'uint');               % Rate of sampling
numberOfSimultanousObjects = fread(fileID, 1, 'uint'); % Number of simultanously visible targets, needed to parse data

% Derived
timeStep = 1/samplingRate;
period = samplingRate * playBackSpeedUp;
leftEdgeOfVisualField = -visualFieldSize/2;
rightEdgeOfVisualField = visualFieldSize/2;

% Setup timer
t = timer('Period', period, ...
            'TasksToExecute', 2, ...
            'ExecutionMode', 'fixedSpacing', ...
            'TimerFcn', , ...
            'StopFcn', , ...
            '', );

TimerFcn : {@OneDVisualize_TimerFcn, x, y}
StopFcn : {@OneDVisualize_StopFcn, x, y}
runforever

% Start timer
start(t);

end