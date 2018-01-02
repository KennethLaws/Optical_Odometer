% Load the images
% Loads images saved in my file format, like bitmap but with no header

function image_1 = load_images(fname1)

fid = fopen(fname1);
img = fread(fid);
fclose(fid);
image_1 = reshape(img,1920,1200);

return