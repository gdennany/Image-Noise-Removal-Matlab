function [output] = gdennany_driver(inp)
%%%%%%%%%%%%
% Driver function which choreographs the order each helper function is
% called. Genral process is this (steps also labeled in the code):
%
%       1. Determine how much positive data is in input set (sum).
%       2. Use sum to determine which gdennany_first_etc method to used.
%       3. gdennanty_first_etc returns an image normailized on 0 to 1
%          scale, with noise spikes removes, and a binary mask associated
%          with the image.
%       4. Use this input to call Professor Chans Inpainting method. Some
%          images may have had noise spikes that were too large for Chans
%          inpainting method to fully remove. Because of this I had to do
%          other operations (described below) on the image to fully fill in
%          the holes.
%       5. Take newly inpainted image and get a new binary mask for the
%          newly manipulated image.
%       6. Use inward interpolation on image using the new binary mask
%          produced in step 5.
%       7. Copy data from the inwardly interpolated image's filled in holes
%          and paste it on to the originally inpainted images remaining
%          holes.
%       8. Convert the image back to origianl size, based on what method
%          (gdennany_first_etc method) was used to normalie and remove
%          noise spikes.
%
% INPUT: 
%   inp: raw image file name
% OUTPUT:
%   output: cleaned image
%%%%%%%%%%%%

%inp = 'S20160326T030009.nc.txt';       %clear sky (uses method 1: all_negatives)
%inp = 'S20160312T050000.nc.txt';       %light precip (uses method 1: all_negatives)
%inp = 'S20160331T110010.nc.txt';       %heavy precip (uses method 2:with_positivies)
z = importdata(inp);

% 1: gets sum of positive data in set
sum = 0;
[numRows, numColumns] = size(z);
for row = 1 : numRows
    for column = 1 : numColumns
        if z(row, column) > 0
            sum = sum + 1;
        end
    end
end


%2 & 3:
%if there are no positive data points (or too few to make a difference) run
%the noise removal code that deals better with all negative number. Else
%run the code that deals with positive and negative data sets. Method
%variable is used later to decide how to rescale image back to original
%magnitude
if sum < 1000
    [noise_removed, mask] = gdennany_first_all_negatives(z);
    method = 1;
else
        [noise_removed, mask] = gdennany_first_with_positives(z);
        method = 2;
end


%4: method calls prof chans inpainting method
[inpainted] = gdennany_inpaint(noise_removed, mask);


%5: gets new binary mask on image after being inpainted
[new_mask] = gdennany_get_new_binary_mask(inpainted);


%6: Uses iward interpolation on 1/2 sized image to fill in any remaining holes
%then converts back to original size
[resized] = gdennany_inward_interpolation(inpainted);

%this assignment is just for readablity to know that you are now working on
%the output image and keeps origianl inpainted variable in first state
output = inpainted;


%7: copies the inwardly interpolated data on any remaining holes from the resized image 
%onto output (inpainted once) image
[numRows, numColumns] = size(output);
for row = 1 : numRows
    for column = 1 : numColumns
        if new_mask(row, column) == 0
            output(row, column) = resized(row, column);
        end
    end
end


%8: converts image back to original magnitude, depending on which first method
%was used
[numRows, numColumns] = size(output);

if method == 1              %data set with all negative values
    for row = 1 : numRows
        for column = 1 : numColumns
                output(row, column) = (-(output(row, column) * 40));     
        end
    end
    output = medfilt2(output);    
else %method == 2           %data set with positive an negative values
    for row = 1 : numRows
        for column = 1 : numColumns
            output(row,column) = ((output(row,column) - .5) * 100);
        end
    end
end



imshowpair(z, output, 'montage');

%{
subplot(1,1,1), imshow(z);
title('Original Raw Image');
subplot(1,2,1), imshow(noise_removed);
title('Original (Grayscale) Image With Noise Removed');
subplot(1,2,1), imshow(inpainted);
title('Image After One Inpainting Iteration');
subplot(1,2,2), imshow(output);
title('Final Clean Image');
%}

end
