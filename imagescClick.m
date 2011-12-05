%
%  imagescClick.m
%  SMI
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function [row, col] = imagescClick(i, j, y_dimension, x_dimension)

    % [0.5,1.5) => 1, [1.5,2.5) => 2, ...
    row = ceil(i - 0.5);
    col = ceil(j - 0.5);
    
    % For some reason on the maximal border of imagesc, one can get to
    % N.5201, while 0.5 is the maximum for all i < N.
    if row > x_dimension,
        row = x_dimension;
    end
    
    if col > y_dimension,
        col = y_dimension;
    end

    disp(['(' num2str(i) ',' num2str(j) ') => (' num2str(row) ',' num2str(col) ')']);
end