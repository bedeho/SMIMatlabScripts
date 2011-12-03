%
%  inspectRepresentation.m
%  SMI
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function inspectRepresentation(filename, nrOfEyePositionsInTesting)

    % Import global variables
    declareGlobalVars();
    
    % Open files
    firingFileID = fopen(filename);
    
    % Read header
    [networkDimensions, historyDimensions, neuronOffsets, headerSize] = loadHistoryHeader(firingFileID);
    
    % Setup vars
    depth               = 1;
    
    numRegions          = length(networkDimensions);
    numEpochs           = historyDimensions.numEpochs;
    numObjects          = historyDimensions.numObjects;
    numOutputsPrObject  = historyDimensions.numOutputsPrObject;
    y_dimension         = networkDimensions(numRegions).y_dimension;
    x_dimension         = networkDimensions(numRegions).x_dimension;
    
    % Allocate datastructure
    axisVals = zeros(numRegions, 1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if mod(numObjects, nrOfEyePositionsInTesting) ~= 0,
        error(['The number of "objects" is not divisible by nrOfEyePositionsInTesting: o=' num2str(numObjects) ', neps=' num2str(nrOfEyePositionsInTesting)]);
    end
    
    objectsPrEyePosition   = numObjects / nrOfEyePositionsInTesting;
    
    % Pre-process data
    result                 = regionHistory(firingFileID, historyDimensions, neuronOffsets, networkDimensions, numRegions, depth, numEpochs);
    
    % Get final state of each fixation
    dataAtLastStepPrObject = squeeze(result(numOutputsPrObject, :, numEpochs, :, :)); % (object, row, col)
    
    % Restructure to access data on eye position basis
    dataPrEyePosition      = reshape(dataAtLastStepPrObject, [objectsPrEyePosition nrOfEyePositionsInTesting y_dimension x_dimension]); % (object, eye_position, row, col)
    
    % Zero out error terms
    floatError = 0.01; % Cutoff for being designated as silent
    dataPrEyePosition(dataPrEyePosition < floatError) = 0;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
    fig = figure();
    
    % Reformat data
    shuffled = permute(dataPrEyePosition,[4 3 1 2]); % reshuffle so that row, col are the two inner dimensions
    objectResponseCount = sum(sum(shuffled)); % sum the two inner dimensions, so now we have: (object, eye_position)
    
    % Plot testing locations    
    subplot(1,numRegions,1);
    imagesc(objectResponseCount);
    colorbar;
    daspect([objectsPrEyePosition nrOfEyePositionsInTesting 1]);
    
    % Setup callback
    set(im, 'ButtonDownFcn', @responseCallBack);
    
    fclose(firingFileID);
    
    makeFigureFullScreen(fig);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CALLBACKS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function responseCallBack()
        
        buttonClick = get(gcf,'SelectionType');
        
        pos=get(axisVals(region-1, 2), 'CurrentPoint');
        [row, col] = imagescClick(pos(1, 2), pos(1, 1));

        disp(['You clicked R:' num2str(region) ', row:' num2str(pos(1, 2)) ', col:', num2str(pos(1, 1))]);
        disp(['You clicked R:' num2str(region) ', row:' num2str(row) ', col:', num2str(col)]);

        if strcmp(buttonClick, 'alt'), % Normal left mouse click

        else % Right mouse click, open synapse history
            updateCellReponsePlot(region, row, col);
        end
    end


    function updateCellReponsePlot(region, row, col)
        
        %markerSpecifiers = {'+', 'o', '*', '.', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'''};
        
        markerSpecifiers = {'+', '.', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'''};
        
        % Populate response plot
        axisVals(numRegions, [1 nrOfColumns]) = subplot(numRegions, nrOfColumns, [plotNr(numRegions, 1), plotNr(numRegions, nrOfColumns)]);
        
        m = 0;
        
        for e= 1:nrOfEyePositionsInTesting,
            
            v = dataPrEyePosition(:, e, row, col)
            
            if max(v) > m,
                m = max(v);
            end
            
            plot(v, [':' markerSpecifiers{e}]);
            
            hold all;
        end  
        
        if m > 1,
            axis([1 objectsPrEyePosition -0.1 m]);
        else
            axis([1 objectsPrEyePosition -0.1 1.1]);
        end
        
        % Dump response count
        objectResponseCount(row,col)
        
        set(gca,'XLim',[1 objectsPrEyePosition])
        set(gca,'XTick', 1:objectsPrEyePosition)
        %set(gca,'XTickLabel',['0';' ';'1';' ';'2';' ';'3';' ';'4'])
        
        
        hold;
    end

    function [nr] = plotNr(row, col)

        nr = nrOfColumns*(row - 1) + col; %(numRegions - row)

    end

    % Made with random experiemtnation with imagesc behavior, MAY not work
    % in other settings because of border BS, check it out later, use
    % ginput() if possible 
    function [row, col] = imagescClick(i, j)

        if i < 1
            row = 1;
        else
            row = floor(i);
        end

        if j < 0.5
            col = 1;
        else
            col = round(j);

            if col > x_dimension,
                col = x_dimension;
            end
        end
    end


end
