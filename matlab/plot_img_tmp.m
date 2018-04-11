% Plot a single image of type tmp generated by my cprog with Bassler camera
% this is basically a bmp type file with no header
% Kenneth Laws
% 12/14/2017


clear all;

% specify camera lens and setup




% set the file names

if exist('/Volumes/M2Ext/Test_Drive_1214/calib2/')
    imgPath = '/Volumes/M2Ext/Test_Drive_1214/calib2/';
elseif exist('/media/kip/960Pro/images/')
    imgPath = '/media/kip/960Pro/images/20180410121727/';
else
    error('Image folder not found, update image path in script');
end

imgFile1 = strcat(imgPath,'1523387847996.bin');


tic;
% load in the images
image_1 = load_image_tmp(imgFile1);


% plot the first image
figure(1), clf, hold on, colormap gray
pcolor(image_1);
shading interp;

% plot a registration line
plot([200 1000],[100 100],'r');

xlim([0 1200]);
axis equal

% y = 151;
% d = 72.5;
% plot([800 1000],[y+d/2 y+d/2],'r')
% plot([800 1000],[y-d/2 y-d/2],'r')
% xlim([800 950])
% ylim([y-100 y+100])

% [1852 1752 1650 1552 1452 1351 1249 1150 1052 953  853 755   653  554
% 453 352 251 151
% [70.5 70.5  71   71  72.5  73.5 74  74.5 75.0 75.5 75.5 75.1 75.1 74.1
% 74.1 73.5 73.5 72.5



