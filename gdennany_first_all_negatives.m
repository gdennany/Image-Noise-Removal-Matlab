function [output, mask] = gdennany_first_all_negatives(z)
 
%%%%%%%%%
% Handles the normalization and removal of noise  for data sets
% with zero or few posivitve values (little precip or clear sky cases).
% 
% INPUT: 
%   z: input raw spetral data (.txt file)
% OUTPUT:
%   ouput: grayscale spectral data image, with noise artifacts removed, normalized to a 0
%          to 1 scale
%   mask: binary mask that tells chans code where and where not to perfrom
%         the inpainting methd 0 for no data (needs inpainted), and 1 for good data.
%%%%%%%%%
 
 
addpath(genpath('./utilities/'));
 
%inp = 'S20160312T050000.nc.txt';
%inp = 'S20160331T110010.nc.txt';
%z = importdata(inp);
 
%reads input data and gets sizes for loops
[numRows, numColumns] = size(z);
medFilt = medfilt2(z);
 
%kernel used for laplacian filter
kernel = [0 0 3 2 2 2 3 0 0; 0 2 3 5 5 5 3 2 0; 3 3 5 3 0 3 5 3 3; 2 5 3 -12 -23 -12 3 5 2; 2 5 0 -23 -40 -23 0 5 2; 2 5 3 -12 -23 -12 3 5 2; 3 3 5 3 0 3 5 3 3; 0 2 3 5 5 5 3 2 0; 0 0 3 2 2 2 3 0 0];
 
% Laplace operator convolution with kernel specified 
laPlacian = conv2(medFilt, kernel, 'same');
laPlacian = medfilt2(laPlacian);
laPlacian = laPlacian(1:numRows, 1:numColumns);
 
% removes (sets to zero) "bad" data 
for row = 1 : numRows
    for column = 1 : numColumns
        if abs(laPlacian(row, column)) > 500
            laPlacian(row,column) = 0;
        else 
            laPlacian(row,column) = 1;
        end
    end
end
 
% makes laplacian mask more defined
se1 = strel('rectangle', [4 6]);    %was [4 6]
mask = imerode(laPlacian, se1);      %BINARY MASK OUTPUT PARAMETER COMES FROM HERE
 
%product of original data and laplacian operator. still needs normalized to
% 0 to 1 scale 
output = mask .* z;
 
%normalizing output to 0 to 1 for input to chans code. max/min values
%provided by dr tanamachi
maximum = 40;       
minimum = -40;
sum = 0;
for row = 1 : numRows
    for column = 1 : numColumns
        if output(row, column) > 0
            sum = sum +1;
        end
        if output(row, column) > maximum
            output(row,column) = maximum;
        elseif output(row,column) < minimum
            output(row, column) = minimum;
        end
        output(row,column) = output(row,column) / maximum;   
    end
end
 
 
%imshowpair(z, output, 'montage');
output = abs(output);           % THIS IS WHERE THE OUTPUT OUTPUT PARAMETER COMES FROM
 
%imshowpair(z, output, 'montage');
 
end
 
 
 
 
 
 
 
 
 
 
 
 
 

