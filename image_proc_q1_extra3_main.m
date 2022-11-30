clear all; 
close all;
clc; 

%%loading the images
moon = im2double(imread('moon.tif'));
trees = im2double(imread('trees.tif'));
shadow = im2double(imread('shadow.tif'));
cameraman = im2double(imread('cameraman.tif'));
tire = im2double(imread('tire.tif'));

array = {moon,trees,shadow,cameraman,tire};

% creating the motion blur filter
h = fspecial('motion',15,40);

estimated_angle_radon = [];
estimated_angle_gabor = [];

t_End = zeros(2,5); 

for i = 1:length(array) %%performs a loop for all the images
    
    % change the size of the image
    array{i} = imresize(array{i},[length(array{i}) length(array{i})]);
    
    % applying the motion blur on the original image
    MotionBlur = imfilter(array{i},h,'conv','circular');
    
%     var_gauss = var(MotionBlur,0,[1 2])/10^4;
%     MotionBlur = imnoise(MotionBlur,'gaussian',0,var_gauss);

    
    %%algorithm 1 to estimate the angle (radon transform)
    tStart = tic; 
    w = hanning(length(array{i}))*hanning(length(array{i}))';
    MotionBlur_hann_fft = fftshift(abs(fft2(MotionBlur.*w)));
    MotionBlur_hann_log = log(MotionBlur_hann_fft);
    theta = 0:179;
    [MotionBlur_hann_log_Radon,xp] = radon(MotionBlur_hann_log,theta);
    peak_radon = max(max(real(MotionBlur_hann_log_Radon)));
    [row,estimated_angle] = find(real(MotionBlur_hann_log_Radon) == peak_radon);
    tEnd = toc(tStart);
    t_End(1,i) = tEnd;
    
    estimated_angle_radon = [estimated_angle_radon,estimated_angle];


    %%algorithm 2 to estimate the angle (gabor filter)
    tStart = tic;
    gaborArray = gabor(4,0:179);
    gaborMag = imgaborfilt(abs(log(fft2(MotionBlur))),gaborArray);
    gabor_Mag_norms = sqrt(sum(gaborMag.^2,[1 2]));
    estimated_angle_2 = find(gabor_Mag_norms == max(max(gabor_Mag_norms)));
    tEnd = toc(tStart);
    t_End(2,i) = tEnd;

    estimated_angle_gabor = [estimated_angle_gabor,estimated_angle_2];

end


