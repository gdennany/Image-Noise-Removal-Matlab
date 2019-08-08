function [new_mask] = gdennany_get_new_binary_mask(inp)

%%%%%%%%%%%%%%%%%%%
% This function generates a new binary mask for the newly processed (inpainted) image.
% Call this function after manipulating (removing noise and using inpainting method)
% an image and need a new bianry mask for the newly manipulated image.
%
% INPUT:
%   inp: input image after having inpainting method perfromed on it
% OUTPUT:
%   new_mask: new binary mask for previously inpainted image
%%%%%%%%%%%%%%%%%%%

[numRows, numColumns] = size(inp);
new_mask = inp;

%creates new binary mask on newly input image
for row = 1 : numRows
    for column = 1 : numColumns
        if new_mask(row, column) > 0 && new_mask(row,column) < 0.2
            new_mask(row,column) = 0;    
        else 
            new_mask(row,column) = 1;
        end
    end
end

se2 = strel('disk', 7, 0);
new_mask = imerode(new_mask, se2);

end