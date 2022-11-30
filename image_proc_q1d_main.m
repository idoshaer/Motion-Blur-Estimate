clear all; 
close all;
clc; 

% loading the original image
cameraman = im2double(imread('cameraman.tif'));

% creating the motion blur filter with motion blur length = 20 and motion blur angle = 30
h = fspecial('motion',20,30);

% applying the motion blur on the original image
motion_blur = imfilter(cameraman,h,'conv','circular');


%% gabor filter

% creating a bank of gabor filters with 0<theta<179
gaborArray = gabor(4,0:179);

% applying the gabor filters on the motion blurred image
gaborMag = imgaborfilt(abs(log(fft2(motion_blur))),gaborArray);

% finding the norms of the gabor magnitude
gabor_Mag_norms = sqrt(sum(gaborMag.^2,[1 2]));

% finding the motion blur angle
estimated_angle = find(gabor_Mag_norms == max(max(gabor_Mag_norms)));


