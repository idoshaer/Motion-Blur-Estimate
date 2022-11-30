clear all; 
close all;
clc; 

%% motion blur length = 20

% loading the original image
cameraman = im2double(imread('cameraman.tif'));
blur_angle = 30;
blur_length = 20;
% creating the motion blur filter with motion blur length = 20 and motion blur angle = 30
h = fspecial('motion',blur_length,blur_angle);

% applying the motion blur on the original image
motion_blur = imfilter(cameraman,h,'conv','circular');

% 2D fourier transform on the original image and the motion blurred image
cameraman_fft = fftshift(fft2(cameraman));
motion_blur_fft = fftshift(fft2(motion_blur));

% displaying the images
subplot(2,2,1)
imshow(cameraman);
title('Original Cameraman');

subplot(2,2,2)
imshow(motion_blur);
title('Blurry Cameraman');

subplot(2,2,3)
imshow(log(1+abs(cameraman_fft)),[]);
title('Fourier Transform of Original Cameraman');

subplot(2,2,4)
imshow(log(1+abs(motion_blur_fft)),[]);
title('Fourier Transform of Blurry Cameraman');


%% motion blur length = 40

clear all; 
close all;
clc; 

% loading the original image
cameraman = imread('cameraman.tif');

blur_angle = 30;
blur_length = 40;

% creating the motion blur filter with motion blur length = 40 and motion blur angle = 30
h = fspecial('motion',blur_length,blur_angle);

% applying the motion blur on the original image
motion_blur = imfilter(cameraman,h,'conv','circular');

% 2D fourier transform on the original image and the motion blurred image
cameraman_fft = fftshift(fft2(cameraman));
motion_blur_fft = fftshift(fft2(motion_blur));

% displaying the images
subplot(2,2,1)
imshow(cameraman);
title('Original Cameraman');

subplot(2,2,2)
imshow(motion_blur);
title('Blurry Cameraman');

subplot(2,2,3)
imshow(log(1+abs(cameraman_fft)),[]);
title('Fourier Transform of Original Cameraman');

subplot(2,2,4)
imshow(log(1+abs(motion_blur_fft)),[]);
title('Fourier Transform of Blurry Cameraman');
%% algorithm 2

% creating and applying a hahn window on the fourier transform of the blurry image
w = hanning(256)*hanning(256)';
motion_blur_hann = motion_blur_fft.*w;

% applying log on the image
motion_blur_hann_log = log(motion_blur_hann);

% radon transform on the image
theta = 0:179;
[motion_blur_hann_log_Radon,xp] = radon(motion_blur_hann_log,theta);

% finding the maximum value of the radon transform
peak_radon = max(max(real(motion_blur_hann_log_Radon)));

% finding the motion blur angle
[row,estimated_angle] = find(real(motion_blur_hann_log_Radon) == peak_radon);


%% algorithm 4

% acquiring the radon transform with specific theta
radon_angle = motion_blur_hann_log_Radon(:,blur_angle + 1)';

% finding the locations of all local minimas in the radon transform
local_minimas = islocalmin(real(radon_angle));

% summing all local minimas
local_minimas_sum = sum(local_minimas == 1);

% finding the distance between the first and last local minimas
minimas_distance = find(local_minimas,1,'last') - find(local_minimas,1,'first');

% averaging the distances between minimas
avg_distance = minimas_distance/(local_minimas_sum-1);

% finding the motion blur length
estimated_length = floor(length(cameraman)/avg_distance);


%% wiener filter

% determination of the motion blur values
PSF = fspecial('motion', 20, 30);

% applying wiener filter on the motion blurred image
J = deconvwnr(motion_blur,PSF);
imshow(J);

% displaying the results
subplot(1,3,1)
imshow(cameraman);
title('Original Cameraman');
subplot(1,3,2)
imshow(motion_blur);
title('Blurry Cameraman');
subplot(1,3,3)
imshow(J);
title('Reconstructed Image');

