function [output, filter] = gdennany_first_with_positives(z)

%%%%%%%%%
% This handles the normaliztation and removal of noise of data sets that contain
% many positive values (or cases with heavy precipitation).
% 
% INPUT: 
%   inp: input raw spetral data (.txt file)
% OUTPUT:
%   ouput: spectral data, with noise artifacts removed, normalized to a 0
%          to 1 scale around 0.5. positve values above 0.5 and negative
%          values below 0.5
%   filter: binary mask that tells chans code where and where not to perfrom
%           the inpainting methd (0 for no data, needs inpainted and 1 for data
%           here is good).
%%%%%%%%%

%clear all;
addpath(genpath('./utilities/'));
%inp = 'S20160312T050000.nc.txt';
%inp = 'S20160331T110010.nc.txt';

%original = importdata(inp);

%reads input data and gets sizes for loops
%z = importdata(inp);
[numRows, numColumns] = size(z);
filter = edge(z, 'sobel');
se1 = strel('rectangle', [4 6]);
filter = imdilate(filter, se1);


%noramlizes around 0.5 instead of zero since there are positive and
%negative numbers
maximum = 50;       
minimum = -50;
for row = 1 : numRows
    for column = 1 : numColumns
        if z(row, column) > maximum
            z(row,column) = maximum;
        elseif z(row,column) < minimum
            z(row, column) = minimum;
        end
        z(row,column) = (z(row,column) / 100) +.5;   
    end
end

%imshowpair(original, z, 'montage');


%edge returns a binary matrix that has 1s where there should be 0s and vice
%versa so I had to flip it
for row = 1 : numRows
    for column = 1 : numColumns
        if filter(row, column) == 1
            filter(row, column) = 0;
        else
            filter(row, column) = 1;
        end
    end
end

%imshowpair(original, z, 'montage');
output = z .* filter;
%imshowpair(z, edge, 'montage');


end

