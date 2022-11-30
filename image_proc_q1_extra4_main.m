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

%%defining the phase of the motion blur 
phase = 30;

% creating the motion blur filter
h = fspecial('motion',20,phase);
    
estimated_length_radon = [];
estimated_length_cepstrum = [];


for i = 1:length(array) %%performs a loop for all the images

    array{i} = imresize(array{i},[length(array{i}) length(array{i})]);
    
    % applying the motion blur on the original image
    MotionBlur = imfilter(array{i},h,'conv','circular');
    
%     var_gauss = var(MotionBlur,0,[1 2])/10^4;
%     MotionBlur = imnoise(MotionBlur,'gaussian',0,var_gauss);

    %%algorithm 1 to estimate the length (radon transform)
    w = hanning(length(array{i}))*hanning(length(array{i}))';
    MotionBlur_hann_fft = fftshift(abs(fft2(MotionBlur.*w)));
    MotionBlur_hann_log = log(1+abs(MotionBlur_hann_fft));
    theta = 0:179;
    [MotionBlur_hann_log_Radon,xp] = radon(MotionBlur_hann_log,theta);
    radon_angle = MotionBlur_hann_log_Radon(:,phase+1)';
    local_minimas = islocalmin(real(radon_angle));
    local_minimas_sum = sum(local_minimas == 1);
    minimas_distance = find(local_minimas,1,'last') - find(local_minimas,1,'first');
    avg_distance = minimas_distance/(local_minimas_sum-1);
    estimated_length = floor(length(cameraman)/avg_distance);

    estimated_length_radon = [estimated_length_radon,estimated_length];


    %%algorithm 2 to estimate the length (cepstrum)
    w = hanning(length(array{i}))*hanning(length(array{i}))';
    MotionBlur_hann_fft = fft2(MotionBlur.*w);
    MotionBlur_hann_log = log(1+abs(MotionBlur_hann_fft));
    cepstrum_MotionBlur = ifft2(MotionBlur_hann_log);
    cepstrum_MotionBlur_rotate = imrotate(cepstrum_MotionBlur,-phase);
    cepstrum_mean = real(mean(cepstrum_MotionBlur_rotate,1));
    estimated_length = find(cepstrum_mean<0,1,'first');
    
    estimated_length_cepstrum = [estimated_length_cepstrum,estimated_length];


end
