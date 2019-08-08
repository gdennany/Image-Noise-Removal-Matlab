function [output] = gdennany_inward_interpolation(output_after_inpaint)

%%%%%%%%%
% Call this function after using chans inpainting method once. The removed 
% noise blobs (from gdennany_first_etc) may be too large for chans
% inpainting method to completely fille them in. So, there may still a few
% large holes in the image. To resolve this, this function will take the
% inpainted image, resolve to to half resolution (resize image to 1/2
% original size), then use inward interpolation to fill in the holes in
% the half sized image. After this, it resizes the image to original size,
% and outputs this interpolated full size image
% 
% INPUT: 
%   output_after_inpaint: input image after being inpainted
% OUTPUT:
%   ouput: inward interpolated image, resized back to original size. This
%          image should only be used to copy over the interpolated data over
%          from it to the inpainted image 
%%%%%%%%%


addpath(genpath('./utilities/'));

%reads input data and gets sizes for loops
z = output_after_inpaint;

%reszes image to 1/2 size so holes are smaller
z = imresize(z, .5);
[numRows, numColumns] = size(z);
medFilt = medfilt2(z);

%kernel used for laplacian filter
kernel = [0 0 3 2 2 2 3 0 0; 0 2 3 5 5 5 3 2 0; 3 3 5 3 0 3 5 3 3; 2 5 3 -12 -23 -12 3 5 2; 2 5 0 -23 -40 -23 0 5 2; 2 5 3 -12 -23 -12 3 5 2; 3 3 5 3 0 3 5 3 3; 0 2 3 5 5 5 3 2 0; 0 0 3 2 2 2 3 0 0];

% Laplace operator convolution with kernel specified 
laPlacian = conv2(medFilt, kernel, 'same');
laPlacian = laPlacian(1:numRows, 1:numColumns);

% removes (sets to zero) "bad" data 
for row = 1 : numRows
    for column = 1 : numColumns
        if abs(laPlacian(row, column)) > 12
            laPlacian(row,column) = 0;
        else 
            laPlacian(row,column) = 1;
        end
    end
end

% makes laplacian mask more defined
se1 = strel('disk', 2, 0);           %was [4 6]
mask = imerode(laPlacian, se1);      %BINARY MASK OUTPUT PARAMETER COMES FROM HERE

%multiplies input by binary mask (effectively removes 'bad' data from input
%image)
output = mask .* z;

%inward interpolation of holes on input image
output = regionfill(output, ~mask);


%resizes interpolated image to original size
output = imresize(output, 2);

end











