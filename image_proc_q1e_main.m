clear all; 
close all;
clc; 

% loading the original image
cameraman = im2double(imread('cameraman.tif'));

blur_angle = 30;
blur_length = 20;
% creating the motion blur filter with motion blur length = 20 and motion blur angle = 30
h = fspecial('motion',blur_length,blur_angle);

% applying the motion blur on the original image
motion_blur = imfilter(cameraman,h,'conv','circular');

% 2D fourier transform of the original image and motion blurred image
cameraman_fft = fft2(double(cameraman));
motion_blur_fft = fft2(motion_blur);

% creating and applying a hahn window on the fourier transform of the blurry image
% w = hanning(256)*hanning(256)';
% motion_blur_hann = motion_blur_fft.*w;

% applying log on the image
motion_blur_hann_log = log(1+abs(motion_blur_fft));

% acquiring the cepstrum of the image
cepstrum_motion_blur = ifft2(motion_blur_hann_log);

% rotating the cepstrum image by 30 degrees
cepstrum_motion_blur_rotate = imrotate(cepstrum_motion_blur,-blur_angle);

cepstrum_mean = real(mean(cepstrum_motion_blur_rotate,1));

% finding the motion blur length
estimated_length = find(cepstrum_mean<0,1,'first');


