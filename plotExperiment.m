%
%  plotExperiment.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Purpose: Create summary of parameter search

function plotExperiment(experiment, nrOfEyePositionsInTesting)

    % Import global variables
    declareGlobalVars();
    
    global EXPERIMENTS_FOLDER;
    global base;

    experimentFolder = [EXPERIMENTS_FOLDER experiment '/'];
    
    % Iterate simulations in this experiment folder
    listing = dir(experimentFolder); 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find an example of simulation directory to extract column names- HORRIBLY CODED
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for d = 1:length(listing),

        simulation = listing(d).name;

        if listing(d).isdir && ~any(strcmp(simulation, {'Filtered', 'Images', '.', '..'})),
            [parameters, nrOfParams] = getParameters(simulation);
            break;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Save results for summary
    filename = [experimentFolder 'Summary_' num2str(length(listing)) '.html']; % Make name that is always original so we dont overwrite old summary which is from previous xGridCleanup run of partial results from this same parameter search
    fileID = fopen(filename, 'w'); % did note use datestr(now) since it has string
    
    % HTML header with javascript/css for JQUERY table plugin
    fprintf(fileID, '<html><head>\n');
    fprintf(fileID, '<style type="text/css" title="currentStyle">\n');
                             
    fprintf(fileID, ['@import "' base 'Scripts/DataTables-1.8.2/media/css/demo_page.css";\n']);
	fprintf(fileID, ['@import "' base 'Scripts/DataTables-1.8.2/media/css/demo_table.css";\n']);
	fprintf(fileID, '</style>\n');
	fprintf(fileID, ['<script type="text/javascript" language="javascript" src="' base 'Scripts/DataTables-1.8.2/media/js/jquery.js"></script>\n']);
	fprintf(fileID, ['<script type="text/javascript" language="javascript" src="' base 'Scripts/DataTables-1.8.2/media/js/jquery.dataTables.js"></script>\n']);
	fprintf(fileID, '<script type="text/javascript" charset="utf-8">\n');
	fprintf(fileID, '$(document).ready(function() { $("#example").dataTable();});\n');
	fprintf(fileID, '</script>\n');
    fprintf(fileID, '</head>\n');
    fprintf(fileID, '<body>\n');
    
    % HTML Title
    fprintf(fileID, '<h1>%s - %s</h1>\n', experiment, datestr(now));
    
    % HTML table
    fprintf(fileID, '<table id="example" class="display" cellpadding="10" style="border: solid 1px">\n');
    fprintf(fileID, '<thead><tr>');
    fprintf(fileID, '<th>Name</th>');
    fprintf(fileID, '<th>Network</th>');
    fprintf(fileID, '<th>Result</th>');
    for p = 1:nrOfParams,
        fprintf(fileID, ['<th>' parameters{p,1} '</th>']);
    end
    fprintf(fileID, '<th>#</th>');
    fprintf(fileID, '<th>Action</th>');
    fprintf(fileID, '</tr></thead>');
    
    %h = waitbar(0, 'Plotting&Infoanalysis...');
    counter = 1;
    
    format('short');
    
    fprintf(fileID, '<tbody>\n');
    for d = 1:length(listing),

        % We are only looking for directories, but not the
        % 'Filtered' directory, since it has filtered output
        simulation = listing(d).name;

        if listing(d).isdir && ~any(strcmp(simulation, {'Filtered', 'Images', '.', '..'})),
            
            % Waitbar messes up -nodisplay option
            %waitbar(counter/(nnz([listing(:).isdir]) - 2), h);
            disp(['******** Doing ' num2str(counter) ' out of ' num2str((nnz([listing(:).isdir]) - 2)) '********']); 
            counter = counter + 1;
            
            summary = plotSimulation(experiment, simulation, nrOfEyePositionsInTesting);

            for s=1:length(summary),
                
                netDir = [experimentFolder  simulation '/' summary(s).directory];
                
                % Start row
                fprintf(fileID, '<tr>');
                
                    % Name
                    fprintf(fileID, '<td> %s </td>\n', simulation);
                    
                    % Network
                    fprintf(fileID, '<td> %s </td>\n', summary(s).directory);
                    
                    % Result
                    fprintf(fileID, '<td><img src="%s" width="370px" height="300px"/></td>\n', [netDir '/result_1.png']);
                     
                    % Parameters
                    parameters = getParameters(simulation);
                    
                    for p = 1:nrOfParams,
                        fprintf(fileID, ['<td> ' parameters{p,2} ' </td>\n']);
                    end
                    
                    if summary(s).nrOfHeadCenteredCells > 0,
                        fprintf(fileID, '<td style=''background-color:green;''> %d </td>\n', summary(s).nrOfHeadCenteredCells);
                    else    
                        fprintf(fileID, '<td> %d </td>\n', summary(s).nrOfHeadCenteredCells);
                    end
                        
                    % Action
                    fprintf(fileID, '<td>\n');
                    outputButton('Figure', ['matlab:open(\\''' netDir '/result_1.fig\\'')']);
                    outputButton('Response', ['matlab:inspectResponse(\\''' netDir '/firingRate.dat\\'',' num2str(nrOfEyePositionsInTesting) ')']);
                    outputButton('Weights', ['matlab:inspectWeights(\\''' netDir '/' summary(s).directory '.txt\\'',\\''' netDir '/firingRate.dat\\'',' num2str(nrOfEyePositionsInTesting) ')']);
                    outputButton('Representation', ['matlab:inspectRepresentation(\\''' netDir '/firingRate.dat\\'',' num2str(nrOfEyePositionsInTesting) ')']); 
                    outputButton('Firing', ['matlab:plotNetworkHistory(\\''' netDir '/firingRate.dat\\'')']); 
                    outputButton('Activation', ['matlab:plotNetworkHistory(\\''' netDir '/activation.dat\\'')']);
                    outputButton('IActivation', ['matlab:plotNetworkHistory(\\''' netDir '/inhibitedActivation.dat\\'')']);
                    outputButton('Trace', ['matlab:plotNetworkHistory(\\''' netDir '/trace.dat\\'')']);
                    fprintf(fileID, '</td>');
                    
                    % Network name: summary(s).directory '.txt\''
                
                fprintf(fileID, '</tr>\n\n');
            end
            
        end
    end

    fprintf(fileID, '</table></body></html>');
    fclose(fileID);
    
    %web(filename);
    
    % Thanks to DanTheMans excellent advice, now we dont
    % have to fire up terminal insessantly
    
    disp('DONE...');
    system('stty echo');
    
    function outputButton(title, action)
        fprintf(fileID, ['<input type="button" value="' title '" onclick="document.location=''' action '''"/></br>\n']);
    end

end
    

function [parameters, nrOfParams] = getParameters(experiment)

    % Get a sample simulation name
    columns = strsplit(experiment, '_');
    nrOfParams = length(columns) - 1;

    parameters = cell(nrOfParams,2);

    for p = 1:nrOfParams,
        pair = strsplit(char(columns(p)),'='); % columns(p) is a 1x1 cell
        parameters{p,1} = char(pair(1));
        parameters{p,2} = char(pair(2));
    end
end
    