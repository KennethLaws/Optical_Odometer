% Load two sequential images

% old version here loads images compatible with matlab imread function
% function [image_1, image_2, subFrame1] = load_images(fname1,fname2,x1,y1,h,w)
%     % load the first image
%     image_1 = imread(fname1)';
%     % load the second image
%     image_2 = imread(fname2)';
%     % define the subframe image
%     subFrame1 = image_1(y1:(y1+h-1),x1:x1+w-1); 
% return

% newer version, compatible with my format, like bitmap but with no header
% this version does not select the subframe region
function [image_1, image_2] = load_images(fnames)
    fid = fopen(fnames{1});   
    img = fread(fid);
    fclose(fid);
    image_1 = reshape(img,1920,1200);

    fid = fopen(fnames{2});
    img = fread(fid);
    fclose(fid);
    image_2 = reshape(img,1920,1200);

return