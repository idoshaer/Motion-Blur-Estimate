clear all; 
close all;
clc; 

%%defining the angles values
angles_vector = 0:5:90;

estimated_angle_radon = [];
estimated_angle_gabor = [];

for i = angles_vector %%performs a loop for all the angles values

    % loading the original image
    cameraman = im2double(imread('cameraman.tif'));
    
    % creating the motion blur filter
    h = fspecial('motion',15,i);
    
    % applying the motion blur on the original image
    MotionBlur = imfilter(cameraman,h,'conv','circular');
    
%     var_gauss = var(MotionBlur,0,[1 2])/10^4;
%     MotionBlur = imnoise(MotionBlur,'gaussian',0,var_gauss);

    %%algorithm 1 to estimate the angle (radon transform)

    % creating and applying a hahn window on the blurry image by using
    % fourier transform
    w = hanning(256)*hanning(256)';
    MotionBlur_hann_fft = fftshift(abs(fft2(MotionBlur.*w)));
    
    % applying log on the image
    MotionBlur_hann_log = log(MotionBlur_hann_fft);

    % radon transform on the image
    theta = 0:179;
    [MotionBlur_hann_log_Radon,xp] = radon(MotionBlur_hann_log,theta);

    % finding the maximum value of the radon transform
    peak_radon = max(max(real(MotionBlur_hann_log_Radon)));
    
    % finding the motion blur angle
    [row,estimated_angle] = find(real(MotionBlur_hann_log_Radon) == peak_radon);
    
    estimated_angle_radon = [estimated_angle_radon,estimated_angle];
	

    %%algorithm 2 to estimate the angle (gabor filter)
    
    % creating a bank of gabor filters with 0<theta<179
    gaborArray = gabor(4,0:179);
    
    % applying the gabor filters on the motion blurred image
    gaborMag = imgaborfilt(abs(log(fft2(MotionBlur))),gaborArray);
    
    % finding the norms of the gabor magnitude
    gabor_Mag_norms = sqrt(sum(gaborMag.^2,[1 2]));
    
    % finding the motion blur angle
    estimated_angle = find(gabor_Mag_norms == max(max(gabor_Mag_norms)));
    
    estimated_angle_gabor = [estimated_angle_gabor,estimated_angle];


end

%%calculation of the errors
error_radon = abs(angles_vector-estimated_angle_radon);
error_gabor = abs(angles_vector-estimated_angle_gabor);

%%displaying a graph of the error of radon and gabor methods as a function of the angles  
plot(angles_vector,error_radon);
xticks(angles_vector)
ylim([-5 10])
yticks(-5:1:10)
xlabel('Blur angle')
ylabel('abs (actual angle - predicted angle)')
title('Motion blur angle estimation with blur length 15 pixels')
grid on

hold on
plot(angles_vector,error_gabor);

legend('Radon transform method','Gabor filter method');


%%calculation of the different parameters
avg_error_radon = mean(error_radon);
avg_error_gabor= mean(error_gabor);

mse_radon = norm(error_radon,2)^2/length(angles_vector);
rmse_radon = sqrt(mse_radon);   
nrmse_radon = sqrt((norm(error_radon,2)^2)/(norm(angles_vector-mean(angles_vector),2)^2));

mse_gabor = norm(error_gabor,2)^2/length(angles_vector);
rmse_gabor = sqrt(mse_gabor);   
nrmse_gabor = sqrt((norm(error_gabor,2)^2)/(norm(angles_vector-mean(angles_vector),2)^2));

