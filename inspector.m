%
%  inspector.m
%  SMI
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function inspector(folder, networkFile, nrOfEyePositionsInTesting)

    % Import global variables
    declareGlobalVars();

    % Fill in missing arguments    
    if nargin < 2,
        networkFile = 'TrainedNetwork.txt';
    end 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Invariance Plots
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Open files
    firingFileID = fopen([folder '/firingRate.dat']);
    
    % Read header
    [networkDimensions, historyDimensions, neuronOffsets, headerSize] = loadHistoryHeader(firingFileID);
    
    % Open file
    %%connectivityFileID = fopen([folder '/' networkFile]);

    % Read header
    %[networkDimensions, neuronOffsets2] = loadWeightFileHeader(connectivityFileID);
        
    % Setup vars
    depth               = 1;    
    %floatError          = 0.01;
    %synapseTHRESHOLD    = 0.15;
    nrOfColumns         = 3;
    
    numRegions          = length(networkDimensions);
    numEpochs           = historyDimensions.numEpochs;
    numObjects          = historyDimensions.numObjects;
    numOutputsPrObject  = historyDimensions.numOutputsPrObject;
    y_dimension         = networkDimensions(numRegions).y_dimension;
    x_dimension         = networkDimensions(numRegions).x_dimension;
    
    %Phases = [0, 180, -90, 90];
    %Orrientations = [0, 45, 90, 135];
    %Wavelengths = [2];
    
    % Allocate datastructure
    regionCorrs = cell(numRegions - 1);
    axisVals = zeros(numRegions, nrOfColumns);
    
    
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
    
    % Iterate regions to
    % 1) Do initial plots
    % 2) Setup callbacks for mouse clicks
    for r=2:numRegions,
        
        %{
        
        % Save axis
        axisVals(r-1,1) = subplot(numRegions, nrOfColumns, plotNr(r-1, 1));
        
        raw = regionActivity{r - 1}(historyDimensions.numOutputsPrTransform, :, :, numEpochs, :, :);
        raw = raw > floatError;
        
        if numTransforms > 1,
            
            if numObjects > 1,
                responsePrObject = sum(raw);
                responsePrCell = sum(responsePrObject);
                responsePrCell = squeeze(responsePrCell); % sum leaves singleton dimension
            else
                responsePrObject = sum(raw);
                responsePrCell = responsePrObject;
            end
        else
                
            if numObjects > 1,
                responsePrObject = squeeze(raw);
                responsePrCell = sum(responsePrObject);
                responsePrCell = squeeze(responsePrCell); % sum leaves singleton dimension
            else
                responsePrObject = squeeze(raw);
                responsePrCell = responsePrObject;
            end
        end
        
        q = reshape(responsePrObject, [numObjects regionDimension*regionDimension]); %sum goes along first non singleton dimension, so it skeeps all our BS 1dimension

        % Plot invariance historgram for region
        for o=1:numObjects,
            
            regionHistogram = hist(q(o,:), 0:numTransforms); % One extra for the 0 bucket
            plot(regionHistogram(2:(numTransforms+1)));
            hold all;
        end
        
        axis tight;

        %}
        
        % Compute and save correlation
        corr = regionCorrelation(firingFileID, historyDimensions, neuronOffsets, networkDimensions, numRegions, depth, nrOfEyePositionsInTesting);
        regionCorrs{r-1} = corr;
        
        % Save axis
        axisVals(r-1, 2) = subplot(numRegions, nrOfColumns, plotNr(r-1, 2));
        
        im = imagesc(corr);
        colorbar
        axis square
        %colormap(jet(max(max(corr)) + 1));
        
        
        % Setup callback
        set(im, 'ButtonDownFcn', {@responseCallBack, r});
    end
    
    fclose(firingFileID);
    
    % Setup blank present cell invariance plot
    axisVals(numRegions, [1 nrOfColumns]) = subplot(numRegions, nrOfColumns, [plotNr(numRegions, 1), plotNr(numRegions, nrOfColumns)]);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Weight Plots
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %{
    % Setup dummy weight plots
    for r=1:(numRegions-1)

        % Get region dimension
        regionDimension = networkDimensions(r).dimension;

        % Save axis
        axisVals(r, 3) = subplot(numRegions, 3, 3*(numRegions - r - 1) + 3);
        
        % Only setup callback for V2+
        if r > 1,
            im = imagesc(zeros(regionDimension));
            colorbar;

            set(im, 'ButtonDownFcn', {@connectivityCallBack, r});
        end
    end
    
    %}
    
    makeFigureFullScreen(fig);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CALLBACKS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function responseCallBack(varargin)
        
        % Extract region,row,col
        region = varargin{3};

        buttonClick = get(gcf,'SelectionType');
        
        pos=get(axisVals(region-1, 2), 'CurrentPoint');
        [row, col] = imagescClick(pos(1, 2), pos(1, 1), networkDimensions(region).y_dimension, networkDimensions(region).x_dimension);

        disp(['You clicked R:' num2str(region) ', row:' num2str(pos(1, 2)) ', col:', num2str(pos(1, 1))]);
        disp(['You clicked R:' num2str(region) ', row:' num2str(row) ', col:', num2str(col)]);

        if strcmp(buttonClick, 'alt'), % Normal left mouse click
            plotSynapseHistory(folder, region, 1, row, col, numEpochs);
        else % Right mouse click, open synapse history
            updateCellReponsePlot(region, row, col);
            %updateWeightPlot(region, row, col);
        end
    end

     %{
    function connectivityCallBack(varargin)
        
        % Extract region,row,col
        region = varargin{3};
        
        pos = get(axisVals(region, 3), 'CurrentPoint');
        
        %row = imagescClick(pos(1, 2));
        %col = imagescClick(pos(1, 1));
        
        [row, col] = imagescClick(pos(1, 2), pos(1, 1), networkDimensions(region).dimension);
        
        disp(['You clicked R:' num2str(region) ', row:' num2str(pos(1, 2)) ', col:', num2str(pos(1, 1))]);
        disp(['You clicked R:' num2str(region) ', row:' num2str(row) ', col:', num2str(col)]);
        
        if region > 2,
            updateWeightPlot(region, row, col);
        end
        
        % Do feature plot ========================
        
        v1Dimension = networkDimensions(1).dimension;

        axisVals(1, 3) = subplot(numRegions, 3, 3*(numRegions-1));

        hold off;
        
        features = findV1Sources(region, depth, row, col);
        numFeatures = length(features);
        
        if numFeatures > 0,
        
            for k = 1:numFeatures,
                drawFeature(features(k).row, features(k).col, features(k).depth);
            end
        else
             % this is needed in case there are no features found, because in this
             % case we would ordinarily not get the content cleared, even
             % with hold off.
            plot([(v1Dimension+1)/2 (v1Dimension+1)/2], [0 v1Dimension+1], 'r');
            hold on;
            plot([0 v1Dimension+1], [(v1Dimension+1)/2 (v1Dimension+1)/2], 'r');
        end
        
        % weird issue with shrinking...
        %title(['Threshold:' num2str(THRESHOLD) ', Phase:' num2str(Phases) ', Orrientations:' num2str(Orrientations) ',Wavelengths' num2str(Wavelengths)]);
        
        % Since we use plot axis for feature plot,
        % which has reversed axis, we must reverse axis
        set(gca,'YDir','reverse');
        
        axis([0 v1Dimension+1 0 v1Dimension+1]);
        
        updateInvariancePlot(region, row, col);
        
        % sources = cell  of struct  (1..n_i).(col,row,depth, productWeight)  
        function [sources] = findV1Sources(region, depth, row, col)

            if region == 1, % termination condition, V1 cells return them self

                % Make 1x1 struct array
                sources(1).region = region;
                sources(1).row = row;
                sources(1).col = col;
                sources(1).depth = depth;

            elseif region > 1, 

                synapses = afferentSynapseList(connectivityFileID, neuronOffsets2, region, depth, row, col);

                sources = [];
                
                for s=1:length(synapses) % For each child

                    % Check that presynaptic neuron is in lower region (in
                    % case feedback network we dont want eternal loop), and
                    % that weight is over threshold
                    if synapses(s).weight > synapseTHRESHOLD && synapses(s).region < region
                        sources = [sources findV1Sources(synapses(s).region, synapses(s).depth, synapses(s).row, synapses(s).col)];
                    end
                end
            end
        end

    end

%}

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
        
        % Dump correlation
        regionCorrs{r-1}(row,col)
        
        
        hold;
    end

%{
    function updateWeightPlot(region, row, col) 

        % Get weightbox
        weights = afferentSynapseMatrix(connectivityFileID, networkDimensions, neuronOffsets2, region, depth, row, col, region - 1, 1);

        % Save axis
        axisVals(region - 1, 3) = subplot(numRegions, 3, 3*(numRegions - region - 1 + 1) + 3);
        im2 = imagesc(weights);
        colorbar;
        %axis square;

        % Setup callback
        if region > 2,
            set(im2, 'ButtonDownFcn', {@connectivityCallBack, region - 1});
        %else
            %title(['Threshold:' num2str(THRESHOLD) ', Phase:' num2str(Phases) ', Orrientations:' num2str(Orrientations) ',Wavelengths' num2str(Wavelengths)]);
        end
        
    end

    function drawFeature(row, col, depth)

        halfSegmentLength = 3;%0.5;
        [orrientation, wavelength, phase] = decodeDepth(depth);
        featureOrrientation = orrientation + 90; % orrientation is the param to the filter, but it corresponds to a perpendicular image feature

        dx = halfSegmentLength * cos(deg2rad(featureOrrientation));
        dy = halfSegmentLength * sin(deg2rad(featureOrrientation));

        x1 = col - dx;
        x2 = col + dx;
        y1 = row - dy;
        y2 = row + dy;
        plot([x1 x2], [y1 y2], '-r');
        hold on;

    end 

    function [orrientation, wavelength, phase] = decodeDepth(depth)

        depth = uint8(depth)-1; % These formula expect C indexed depth, since I copied from project

        w = mod((idivide(depth, length(Phases))), length(Wavelengths));
        wavelength = Wavelengths(w+1);

        ph = mod(depth, length(Phases));
        phase = Phases(ph+1);

        o = idivide(depth, (length(Wavelengths) * length(Phases)));
        orrientation = Orrientations(o+1);
    end 

%}

    function [nr] = plotNr(row, col)

        nr = nrOfColumns*(row - 1) + col; %(numRegions - row)

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

