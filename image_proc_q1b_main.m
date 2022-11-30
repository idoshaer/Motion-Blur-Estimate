clear all; 
close all;
clc; 

% creation of the desired image 
I = zeros(313);
[m,n] = size(I);
for i = 1:m
 for j = 1:n
 I(j,40) = 255;
 I(j,80) = 255;
 I(j,124) = 255;
 I(j,150) = 255;
 end
end

% displaying the image
figure(1)
imshow(I);

% radon transform of the image
R = radon(I);

% displaying the radon transform of the image
figure(2)
imshow(R,[])


%%

% creation of the desired image 
I = zeros(313);
I(40,40) = 255;
I(80,80) = 255;
I(124,124) = 255;
I(150,150) = 255;

% displaying the image
figure(1)
imshow(I);

% radon transform of the image
[R,xp] = radon(I);
% displaying the radon transform of the image
figure(2)
imshow(R,[])


