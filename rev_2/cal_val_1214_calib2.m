% cal_val_1214_calib2
% calibrate and validate
% used for calibration and validation for data set 12/14/17

clear;

doCal = 0;      % set this to do the calibration step

% set image path
if exist('/Volumes/M2Ext/Test_Drive_1214/calib2/')
    imgPath = '/Volumes/M2Ext/Test_Drive_1214/calib2/';
elseif exist('/media/earthmine/M2Ext/Test_Drive_1214/calib2/')
    imgPath = '/media/earthmine/M2Ext/Test_Drive_1214/calib2/';
else
    error('Image folder not found, update image path in script');
end

% load processed sequential image results
%fname = 'seq_image_rslt_1214_1.mat';
fname = 'seq_image_rslt_calib2.mat';
% rslt(step,:) = [step, deltPosPix, dy_inches, snr_db];
load(fname);

% start and end image by image number
img_start = 0;
img_end = 141;
rng = (img_start+1):(img_end+1);

total_Y = sum(rslt(rng,4));
fprintf('Total distance travelled, y = %0.4f m\n',total_Y);
fprintf('\n');

figure(1), clf
plot(rslt(rng,1),rslt(rng,4))
ylabel('Distance per Frame Pair (m)');
xlabel('Image Number')
title('12/14/17 Test Calibration')

% find distance travelled for the calibration training set
% set image range as roughly half of the set of images that have the tape measure
% clearly visible in the frame.  This is done by processing the whole
% calibration data set with proc_seq_image.m and examining the saved result
% using plot_seqImg_rslt to see which frames had vehicle movement.

% set the range of images for calibration
startImage = 'img_2017-12-14-100226_49.tmp';
endImage = 'img_2017-12-14-100239_110.tmp';
img_start = 50;
img_end = 110;
rng = (img_start+1):(img_end+1);

% compute the total pixel shift from saved processed result
pixx = sum(rslt(rng,3));
pixy = sum(rslt(rng,2));

if doCal
    % examine the start and end images to read the positions from the tape
    disp 'manually examine images to measure distance'
    fprintf('Estimate position for start image');
    disp(startImage)
    plot_sing_img(imgPath,startImage);
    y1 = input('enter registration line position for image in cm (132.2):');
    disp(endImage)
    plot_sing_img(imgPath,endImage);
    y2 = input('enter registration line position for image in cm (60.29):');
    
    total_Y = y2 - y1;
    
    fprintf('Calibration sequence\n');
    fprintf('Total pixel transition, x = %d pix\n',-pixx);
    fprintf('Total pixel transition, y = %d pix\n',-pixy);
    fprintf('Total distance travelled, x = %0.4f m\n',total_X);
    fprintf('Total distance travelled, y = %0.4f m\n\n',total_Y);
end


% before the code below makes any sense you must
% apply calibration obtained from above and reprocess 
% then evaluate validation set below

% set range for validation
img_start = 110;
img_end = 141;
rng = (img_start+1):(img_end+1);
startImage = 'img_2017-12-14-100238_109.tmp';
endImage = 'img_2017-12-14-100245_141.tmp';

% estimate the distance travelled by measure on tape in image
disp 'manually examine images to measure distance'
fprintf('Estimate position for start image');
disp(startImage)
plot_sing_img(imgPath,startImage);
y1 = input('enter registration line position for image in cm (60.88):');
disp(endImage)
plot_sing_img(imgPath,endImage);
y2 = input('enter registration line position for image in cm (6.62):');
delt_y = -(y2 - y1);

    
total_Y = sum(rslt(rng,4));
total_X = sum(rslt(rng,5));
pixx = sum(rslt(rng,3));
pixy = sum(rslt(rng,2));


fprintf('Validation sequence\n');
fprintf('Number of measurements, N = %d\n',length(rng));
fprintf('Total pixel transition, x = %d pix\n',-pixx);
fprintf('Total pixel transition, y = %d pix\n',-pixy);
fprintf('Total distance travelled, x = %0.2f cm\n',total_X*100);
fprintf('Total distance travelled, y = %0.2f cm\n',total_Y*100);
fprintf('Total distance validation, y = %0.2f cm\n',delt_y);
fprintf('Error, e = %0.4f cm\n',(total_Y*100 - delt_y));
fprintf('Estimate of error per measurement, en = %0.4f cm\nn',(total_Y*100 - delt_y)/sqrt(length(rng)));


