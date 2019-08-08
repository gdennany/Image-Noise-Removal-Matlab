function [out] = gdennany_inpaint(z, mask)

%%%%%%%%%%%%
% Takes the input (from one of gdennany_first_etc functions) image with 
% noise spikes removed to run through prof chans inpainting method
%
% INPUT:
%   z: normalized grayscale input image with noise spikes removed 
%   mask: binary mask indicating where useful data (1's) is and data that needs
%   inpainted (0's)
% OUTPUT:
%   out: output image after running prof Chan's inpaint method
%%%%%%%%%%%%

close all
clc


addpath(genpath('./utilities/'));

%add path to denoisers
addpath(genpath('./denoisers/BM3D/'));
addpath(genpath('./denoisers/TV/'));
addpath(genpath('./denoisers/NLM/'));
addpath(genpath('./denoisers/RF/'));
addpath(genpath('./data/'));

%reset random number generator 
rng(0)

%set noise level
noise_level = 10/255;

%calcualte the observed image
y = z.*mask + noise_level*randn(size(z));

%parameters
method = 'RF';
switch method
    case 'RF'
        lambda = 0.0003;
    case 'NLM'
        lambda = 0.002;
    case 'BM3D'
        lambda = 0.001;
    case 'TV'
        lambda = 0.01;
end

%optional parameters
opts.rho     = 1;
opts.gamma   = 1;
opts.max_itr = 20;
opts.print   = true;

%main routine
tic
out = PlugPlayADMM_inpaint(y,mask,lambda,method,opts);  %WHERE OUT OUTPUT COMES FROM
toc


%display
PSNR_output = psnr(out,z); 

fprintf('\nPSNR = %3.2f dB \n', PSNR_output);
%{
figure;
subplot(121);
imshow(y);
title('Input');

subplot(122);
imshow(out);
tt = sprintf('PSNR = %3.2f dB', PSNR_output);
title(tt); 
%}

end



