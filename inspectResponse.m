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
    [data, objectsPrEyePosition] = regionDataPrEyePosition(filename, nrOfEyePositionsInTesting); % (object, eye_position, row, col, region)
    regionCorrs = regionCorrelation(filename, nrOfEyePositionsInTesting);
    
    % Setup vars
    numRegions = length(networkDimensions);
    axisVals = zeros(numRegions, 3); % Save axis that we can lookup 'CurrentPoint' property on callback
    
    % Iterate regions to do correlation plot and setup callbacks
    fig = figure('name',filename,'NumberTitle','off');
    for r=2:numRegions
        
        % Save axis
        axisVals(r-1,1) = subplot(numRegions, 3, 3*(r-2) + 1); % Simon model
        
        %% TRADITIONAL TEST
        %{ 
        im = imagesc(regionCorrs{r-1});
        title('Head centerede correlation');
        %}
        
        %% SIMON TEST
        %%{
        v0 = data{r-1};
        v0(v0 > 0) = 1;  % count all nonzero as 1, error terms have already been removed
        v1 = squeeze(sum(sum(v0))); % sum away
        v2 = v1(:,:,1);
        im = imagesc(v2);         % only do first region
        daspect([size(v2) 1]);
        title('Number of testing locations responded to');
        %%}
    
        colorbar;
        
        % Histogram
        axisVals(r-1,2) = subplot(numRegions, 3, 3*(r-2) + 2); % Simon model
        noZeros = v2(:);
        noZeros(noZeros == 0) = [];
        
        hist(noZeros,1:(max(max(v2))));
        title(['Mean: ' num2str(mean2(v2))]);
        
        % Setup callback
        set(im, 'ButtonDownFcn', {@responseCallBack, r});
        
        %% Invariance heuristic
        axisVals(r-1,3) = subplot(numRegions, 3, 3*(r-2) + 3);
        responsePerObject = squeeze(sum(v0)); % (eye_position, row, col)
        
        % Clear out cells that respond to multiple objects
        % Note: Couldnt figure it out in vectorized form.
        numberOfObjectsRespondedTo = squeeze(sum(responsePerObject > 0)); % (row,col) = number of objects responded to atleast one transform of
        respondedToMultiple = numberOfObjectsRespondedTo > 1; % (row,col) = true/false: responded to multiple objects
        
        % Get dimensions for this region
        y_dimension = networkDimensions(r).y_dimension;
        x_dimension = networkDimensions(r).x_dimension;
        
        % Clear out cells that respond to more than one object
        for row=1:y_dimension,
            for col=1:x_dimension,
                responsePerObject(:,row,col) = ~respondedToMultiple(row,col) * responsePerObject(:,row,col); % Zero out cells that responded to multiple
            end
        end
                
        % Plot a line for each object
        for e=1:nrOfEyePositionsInTesting,
            z = responsePerObject(e,:,:);
            z = z(:);
            z(z == 0) = [];
            responseCounts = hist(z,1:objectsPrEyePosition);
            
            plot(responseCounts);
            hold all
        end
        
        axis tight
        
        hold off
       
    end
    
    %makeFigureFullScreen(fig);
    
    % Callback
    function responseCallBack(varargin)
        
        % Extract region,row,col
        region = varargin{3};

        pos = get(axisVals(region-1,1), 'CurrentPoint');
        [row, col] = imagescClick(pos(1, 2), pos(1, 1), networkDimensions(region).y_dimension, networkDimensions(region).x_dimension);

        % Dump correlation
        disp(['Correlation: ' num2str(regionCorrs{region-1}(row,col))]);
        
        % Setup blank plot
        axisVals(numRegions, [1 3]) = subplot(numRegions, 3, [3*(numRegions - 1) + 1 3*(numRegions - 1) + 3]);
        
        %axisVals(numRegions, [1 2]) = subplot(numRegions, 2, [2*(numRegions - 1) + 1 2*(numRegions - 1) + 2]);
    
        %% SIMON STYLE - object based line plot
        %%{
        
        cla
        
        markerSpecifiers = {'r+', 'kv', 'bx', 'cs', 'md', 'y^', 'g.', 'w>'}; %, '<', 'p', 'h'''
        
        m = 1.1;
        
        for h = 1:nrOfEyePositionsInTesting,
            
            v = squeeze(data{region-1}(:, h, row, col));
            
            if max(v) > m,
                m = max(v);
            end
            
            plot(v, [':' markerSpecifiers{h}]);
            
            hold all;
        end  

        axis([1 objectsPrEyePosition -0.1 m]);
        
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