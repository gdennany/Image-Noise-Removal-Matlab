function gdennany_driver_automated()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function will be used to automatically input new raw images to the
% driver function, and then save the cleaned images to the netCDF file.
% Upon running, a GUI will pop up. Select the desired folder and then the
% code will run through all the files associated with that folder.
%
% Tip: the files will automatically be saved to the current working
% directory, so make current folder where you want the output to go to
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%inp = 'S20160312T050000.nc.txt';
%z = importdata(inp);
%ncwrite(filename,varname,vardata,start)

%dayUsed = '0307';
%folder = strcat('Select a folder');
%outputDestination = '/Volumes/gdennany/Cleaned_data/0307/';

%pops up gui that allows you to pick folder you want to run
d = uigetdir('/Volumes/gdennany/print_fmcw_spectra_output/', 'folder');

%list files in folder in one long list
list = ls(d);

%Splits list of files into a string array w/ each object holding a
%file name
files = string(strsplit(list));


[~, numFiles] = size(files);
files = files(1, 1:numFiles - 1);   %For some reason imported file list had an extra empty string attached to the end so I had to get rid of it


%writing to nc file attempts
nc = files;
[~, x] = size(nc);

for num = 1 : x
    [output] = gdennany_driver(files(num));
    sf_clean = output;
    temp = nc(1, num);
    nc(1, num) = extractBetween(temp, 1, strlength(temp) - 4);
    nccreate(nc(1,num), sf_clean);
end


%{
% this saves a text file of output to current path directory
for file = 1 : numFiles - 1
    [output] = gdennany_driver(files(file));
    %dlmwrite(files(file), output); %writes output as txt file to folder
    nccreate(, sf_clean);
end


%result = gdennany_driver(z);
%}
%}
end





