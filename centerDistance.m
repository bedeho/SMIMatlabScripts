
function [v] = centerDistance(width, distance)
    
    v = -width/2:distance:width/2;
    v = v - (v(1) + v(end)) / 2; % shift approprite amount in the right direction to center