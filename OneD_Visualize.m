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

    % Import global variables
    declareGlobalVars
    
    global base; % importing
    
    global OneDVisualizeTimeObject; % exporting
  
    global buffer;                  % exporting
    global sampleCounter;           % exporting
    global fileCounter;             % exporting
    
    sampleCounter = 1;
    fileCounter = 1;
    
    filename = [base 'Stimuli/' stimuliName '/data.dat'];

    playAtPrcntOfOriginalSpeed = 0.5;

    % Open file
    fileID = fopen(filename);

    % Read header
    samplingRate = fread(fileID, 1, 'ushort');               % Rate of sampling
    numberOfSimultanousObjects = fread(fileID, 1, 'ushort'); % Number of simultanously visible targets, needed to parse data
    visualFieldSize = fread(fileID, 1, 'float');           % Size of visual field
    eyePositionFieldSize = fread(fileID, 1, 'float');
    
    % Read body,
    % we cannot read in one blow because the internal sequence sepeartors
    % are in arbitrary locations, at the very least in real data.
    counter = 0;
    buffer = []; % we could compute a funky and very loose upper bound on size, but it would be odd
    while ~feof(fileID),
        
        % Read sample from file
        eyePosition = fread(fileID, 1, 'float');
        
        % Consume reset
        if ~isnan(eyePosition),
            
            retinalPositions = fread(fileID, numberOfSimultanousObjects,'float');
            buffer = [buffer; eyePosition retinalPositions];
        else

            % Reset counter at last object
            buffer = [buffer; nan (nan * ones(1,numberOfSimultanousObjects))];
        end
        
        counter = counter + 1;
    end
    
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