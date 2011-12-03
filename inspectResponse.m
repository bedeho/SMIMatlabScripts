%
%  inspectResponse.m
%  SMI
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function inspectResponse(filename, nrOfEyePositionsInTesting)


    % Get dimensions
    [networkDimensions, historyDimensions] = getHistoryDimensions(filename);
    
    % Setup vars
    numRegions = length(networkDimensions);
    
    % Allocate datastructure
    regionCorrs = cell(numRegions - 1);
    axisVals = zeros(numRegions, 1);
    
    % Load data
    regionDataPrEyePosition = loadDataPrEyePosition(filename, nrOfEyePositionsInTesting);
    dataPrEyePosition = regionDataPrEyePosition{numRegions};
    
    % Iterate regions to
    % 1) Do initial plots
    % 2) Setup callbacks for mouse clicks
    fig = figure();
    for r=2:numRegions,
        
        % Compute and save correlation
        [regionCorrelation] = regionCorrelation(filename);
        regionCorrs{r-1} = corr;
        
        % Save axis
        axisVals(r-1) = subplot(numRegions, 1, r-1);
        
        im = imagesc(corr);
        colorbar
                
        % Setup callback
        set(im, 'ButtonDownFcn', {@responseCallBack, r});
    end
    
    % Setup blank plot
    axisVals(numRegions) = subplot(numRegions, 1, numRegions);
    
    makeFigureFullScreen(fig);
    
    % Callback
    function responseCallBack(varargin)
        
        % Extract region,row,col
        region = varargin{3};

        pos=get(axisVals(region-1, 2), 'CurrentPoint');
        [row, col] = imagescClick(pos(1, 2), pos(1, 1), networkDimensions(region).y_dimension, networkDimensions(region).x_dimension);

        disp(['You clicked R:' num2str(region) ', row:' num2str(pos(1, 2)) ', col:', num2str(pos(1, 1))]);
        disp(['You clicked R:' num2str(region) ', row:' num2str(row) ', col:', num2str(col)]);

        updateCellReponsePlot(region, row, col);
    end

    function updateCellReponsePlot(region, row, col)

        % Setup blank plot
        axisVals(numRegions) = subplot(numRegions, 1, numRegions);
    
        %{
        
        markerSpecifiers = {'+', '.', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'''};
        
        m = 0;
        
        for e= 1:nrOfEyePositionsInTesting,
            
            v = dataPrEyePosition(:, e, row, col);
            
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
        
        %}
        
        % Bar plot
        bar(dataPrEyePosition(:, :, row, col));
        
        % Dump correlation
        regionCorrs{r-1}(row,col)
        
        set(gca,'XLim',[1 objectsPrEyePosition])
        set(gca,'XTick', 1:objectsPrEyePosition)
        %set(gca,'XTickLabel',['0';' ';'1';' ';'2';' ';'3';' ';'4'])
        
        
        hold;
    end
end

% Made with random experiemtnation with imagesc behavior, MAY not work
% in other settings because of border BS, check it out later, use
% ginput() if possible 
function [row, col] = imagescClick(i, j, y_dimension, x_dimension)

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

