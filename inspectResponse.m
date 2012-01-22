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
    for r=2:numRegions
        
        % Save axis
        axisVals(r-1) = subplot(numRegions, 1, r-1);
        
        %% TRADITIONAL TEST
        %{ 
        im = imagesc(regionCorrs{r-1});
        title('Head centerede correlation');
        %}
        
        %% SIMON TEST
        %%{
        v0 = data{end};
        v0(v0 > 0) = 1;  % count all nonzero as 1, error terms have already been removed
        v1 = squeeze(sum(sum(v0))); % sum away
        v2 = v1(:,:,1);
        im = imagesc(v2);         % only do first region
        daspect([size(v2) 1]);
        title('Number of testing locations responded to');
        %%}
    
        colorbar;
        
        % Setup callback
        set(im, 'ButtonDownFcn', {@responseCallBack, r});
    end
    
    %makeFigureFullScreen(fig);
    
    % Callback
    function responseCallBack(varargin)
        
        % Extract region,row,col
        region = varargin{3};

        pos = get(axisVals(region-1), 'CurrentPoint');
        [row, col] = imagescClick(pos(1, 2), pos(1, 1), networkDimensions(region).y_dimension, networkDimensions(region).x_dimension);

        % Dump correlation
        disp(['Correlation: ' num2str(regionCorrs{region-1}(row,col))]);
        
        % Setup blank plot
        axisVals(numRegions) = subplot(numRegions, 1, numRegions);
    
        %% SIMON STYLE - object based line plot
        %%{
        
        cla
        
        markerSpecifiers = {'r+', 'g.', 'bx', 'cs', 'md', 'y^', 'kv', 'w>'}; %, '<', 'p', 'h'''
        
        m = 1;
        
        for o= 1:objectsPrEyePosition,
            
            v = squeeze(data{region-1}(o, :, row, col));
            
            if max(v) > m,
                m = max(v);
            end
            
            plot(v, [':' markerSpecifiers{o}]);
            
            hold all;
        end  

        axis([1 nrOfEyePositionsInTesting -0.1 m]);
        
        %%}
        
        %% OLD STYLE - Bar plot
        %cla
        
        %Simon Style
        %plot(data{region-1}(:, :, row, col));
        %set(gca,'XLim',[0 nrOfEyePositionsInTesting]);
        %set(gca,'YLim',[-0.1 1.1]);
        
        % Old Style
        %bar(data{region-1}(:, :, row, col));
        %set(gca,'XLim',[0 (objectsPrEyePosition+1)])
        
        %set(gca,'XTick', 1:objectsPrEyePosition)
        title(['Row:' num2str(row) ', Col:' num2str(col)]); % ', R:' num2str(region)
    end
end