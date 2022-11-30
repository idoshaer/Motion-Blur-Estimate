clear all; 
close all;
clc; 

%%defining the lengths values
lengths_vector = 5:1:20;

%%defining the phase of the motion blur 
phase = 0;

estimated_length_radon = [];
estimated_length_cepstrum = [];


for i = lengths_vector %%performs a loop for all the lengths values

    % loading the original image
    cameraman = im2double(imread('cameraman.tif'));
    
    % creating the motion blur filter
    h = fspecial('motion',i,phase);
    
    % applying the motion blur on the original image
    MotionBlur = imfilter(cameraman,h,'conv','circular');
    
%     var_gauss = var(cameraman,0,[1 2])/10^4;
%     cameraman = imnoise(cameraman,'gaussian',0,var_gauss);

    %%algorithm 1 to estimate the length (radon transform)

    % creating and applying a hahn window on the blurry image by using
    % fourier transform
    w = hanning(256)*hanning(256)';
    MotionBlur_hann_fft = fftshift(abs(fft2(MotionBlur.*w)));
    
    % applying log on the image
    MotionBlur_hann_log = log(1+abs(MotionBlur_hann_fft));
    
    % radon transform on the image
    theta = 0:179;
    [MotionBlur_hann_log_Radon,xp] = radon(MotionBlur_hann_log,theta);
    
    % acquiring the radon transform with specific theta
    radon_angle = MotionBlur_hann_log_Radon(:,phase+1)';
    
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

    estimated_length_radon = [estimated_length_radon,estimated_length];


    %%algorithm 2 to estimate the length (cepstrum)
    
    % creating and applying a hahn window on the blurry image by using
    % fourier transform
    w = hanning(256)*hanning(256)';
    MotionBlur_hann_fft = fft2(MotionBlur.*w);
    
    % applying log on the image
    MotionBlur_hann_log = log(1+abs(MotionBlur_hann_fft));
    
    % acquiring the cepstrum of the image
    cepstrum_MotionBlur = ifft2(MotionBlur_hann_log);
    
    % rotating the cepstrum image by 30 degrees
    cepstrum_MotionBlur_rotate = imrotate(cepstrum_MotionBlur,-phase);
    
    cepstrum_mean = real(mean(cepstrum_MotionBlur_rotate,1));
    
    % finding the motion blur length
    estimated_length = find(cepstrum_mean<0,1,'first');
    
    estimated_length_cepstrum = [estimated_length_cepstrum,estimated_length];
    
end

%%calculation of the errors
error_radon = abs(lengths_vector-estimated_length_radon);
error_cepstrum = abs(lengths_vector-estimated_length_cepstrum);

%%displaying a graph of the error of radon and Cepstral methods as a function of the lengths  
plot(lengths_vector,error_radon);
xticks(lengths_vector)
ylim([-5 10])
yticks(-5:1:10)
xlabel('Blur length')
ylabel('abs(actual length - predicted length)')
title('Motion blur length estimation with blur angle 0 degrees')
grid on

hold on
plot(lengths_vector,error_cepstrum);

legend('Radon transform method','Cepstral transform method');


%%calculation of the different parameters
avg_error_radon = mean(error_radon);
avg_error_cepstrum = mean(error_cepstrum);

mse_radon = norm(error_radon,2)^2/length(lengths_vector);
rmse_radon = sqrt(mse_radon);   
nrmse_radon = sqrt((norm(error_radon,2)^2)/(norm(lengths_vector-mean(lengths_vector),2)^2));

mse_cepstrum = norm(error_cepstrum,2)^2/length(lengths_vector);
rmse_cepstrum = sqrt(mse_cepstrum);   
nrmse_cepstrum = sqrt((norm(error_cepstrum,2)^2)/(norm(lengths_vector-mean(lengths_vector),2)^2));


