clear all; 
close all;
clc; 

% loading original images
cameraman = imread('cameraman.tif');
moon = imread('moon.tif');

% adjusting the size of "moon" to match "cameraman"
moon_resize = imresize(moon,[256 256]);

% 2D fourier transform of the images
cameraman_fft = fft2(cameraman);
moon_fft = fft2(moon_resize);

% displaying the images
figure;
imshow(cameraman);
title('Cameraman');
figure;
imshow(moon);
title('Moon');
figure;
imshow(moon_resize);
title('Resized Moon');
%%

% acquiring the amplitude and phase of each image
a1 = abs(cameraman_fft);
a2 = abs(moon_fft);
p1 = angle(cameraman_fft);
p2 = angle(moon_fft);

% switching between the phases of the images
combined1 = a1.*exp(1j*p2);
combined2 = a2.*exp(1j*p1);

% inverse fourier transform of the new images
combined1_ifft = uint8(ifft2(combined1));
combined2_ifft = uint8(ifft2(combined2));

% displaying the new images
figure(1)
imshow(combined1_ifft,[]);
title('Moon''s phase with Cameraman''s amplitude');
figure(2)
imshow(combined2_ifft,[]);
title('Cameraman''s phase with Moon''s amplitude');

