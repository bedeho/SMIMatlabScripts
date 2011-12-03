%
%  OneD_Overlay.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Draws graphics - TimerFcn callback 

function OneD_Overlay(trainingStimuliName, testingStimuliName)

    fig = figure();

    plotStimuli(trainingStimuliName, 'ro');
    plotStimuli(testingStimuliName, 'bx');
    
    function plotStimuli(name, color)
        
        % Load file
        [samplingRate, numberOfSimultanousObjects, visualFieldSize, eyePositionFieldSize, buffer] = OneD_Load(name);

        % Derived
        leftMostVisualPosition = -visualFieldSize/2;
        rightMostVisualPosition = visualFieldSize/2;
        leftMostEyePosition = -eyePositionFieldSize/2;
        rightMostEyePosition = eyePositionFieldSize/2;     

        % Cleanup nan
        temp = buffer;
        v = isnan(buffer); % v(:,1) = get logical indexes for all nan rows
        temp(v(:,1),:) = [];  % blank out all these rows

        % Plot
        for o = 1:numberOfSimultanousObjects,
            plot(temp(:,1), temp(:,o + 1) , color);

            hold on;
        end

        daspect([eyePositionFieldSize visualFieldSize 1]);
        axis([leftMostEyePosition rightMostEyePosition leftMostVisualPosition rightMostVisualPosition]);
    end
end