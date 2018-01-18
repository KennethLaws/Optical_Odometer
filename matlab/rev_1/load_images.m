% Load the images
function [image_1, image_2, subFrame1] = load_images(fname1,fname2,x1,y1,h,w)
    % load the first image
    image_1 = imread(fname1)';
    % load the second image
    image_2 = imread(fname2)';
    % define the subframe image
    subFrame1 = image_1(y1:(y1+h-1),x1:x1+w-1); 
return