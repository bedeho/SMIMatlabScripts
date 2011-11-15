
% Finishes up - StopFcn callback
function OneDVisualize_StopFcn()

    % Delete timer
    delete(t);

    % Close file
    fclose(fileID);
end