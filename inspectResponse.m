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
    
    % Load data
    [data, objectsPrEyePosition] = regionDataPrEyePosition(filename, nrOfEyePositionsInTesting);
    regionCorrs = regionCorrelation(filename, nrOfEyePositionsInTesting);
    
    % Setup vars
    numRegions = length(networkDimensions);
    axisVals = zeros(numRegions-1, 1); % Save axis that we can lookup 'CurrentPoint' property on callback
    
    % Iterate regions to do correlation plot and setup callbacks
    fig = figure();
    for r=2:numRegions,
        
        % Save axis
        axisVals(r-1) = subplot(numRegions, 1, r-1);
        
        im = imagesc(regionCorrs{r-1});
        colorbar
        title('Head centerede correlation');
                
        % Setup callback
        set(im, 'ButtonDownFcn', {@responseCallBack, r});
    end
    
    makeFigureFullScreen(fig);
    
    % Callback
    function responseCallBack(varargin)
        
        % Extract region,row,col
        region = varargin{3};

        pos = get(axisVals(region-1), 'CurrentPoint');
        [row, col] = imagescClick(pos(1, 2), pos(1, 1), networkDimensions(region).y_dimension, networkDimensions(region).x_dimension);

        disp(['You clicked R:' num2str(region) ', row:' num2str(pos(1, 2)) ', col:', num2str(pos(1, 1))]);
        str = [' region:' num2str(region) ', row:' num2str(row) ', col:', num2str(col)];
        disp(['You clicked ' str]);

        % Setup blank plot
        axisVals(numRegions) = subplot(numRegions, 1, numRegions);
    
        %{
        
        markerSpecifiers = {'+', '.', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'''};
        
        m = 0;
        
        for e= 1:nrOfEyePositionsInTesting,
            
            v = data{region-1}(:, e, row, col);
            
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
        bar(data{region-1}(:, :, row, col));
        
        % Dump correlation
        regionCorrs{region-1}(row,col)
        
        set(gca,'XLim',[1 objectsPrEyePosition])
        set(gca,'XTick', 1:objectsPrEyePosition)
        %set(gca,'XTickLabel',['0';' ';'1';' ';'2';' ';'3';' ';'4'])
        title(['Response for ' str]);
        hold;
    end
end