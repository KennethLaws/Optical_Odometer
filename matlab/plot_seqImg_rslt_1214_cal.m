% Project           :: Optical Odometer
% Author            :: Kenneth Laws
%                   :: Here Technologies
% Creation Date     :: 10/16/2017
%
% load in result data saved by proc_seq_image and make some plots
% used for calibration and validation for data set 12/14/17

clear;
pathName = 'data/';
%fname = 'seq_image_rslt_1214_1.mat';
fname = 'seq_image_rslt.mat';
% rslt(step,:) = [step, deltPosPix, dy_inches, snr_db];
load([pathName fname]);

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

% find distance travelled for training set
img_start = 50;
img_end = 110;
rng = (img_start+1):(img_end+1);

total_Y = sum(rslt(rng,4));
total_X = sum(rslt(rng,5));
pixx = sum(rslt(rng,3));
pixy = sum(rslt(rng,2));

fprintf('Calibration sequence\n');
fprintf('Total pixel transition, x = %d pix\n',-pixx);
fprintf('Total pixel transition, y = %d pix\n',-pixy);
fprintf('Total distance travelled, x = %0.4f m\n',total_X);
fprintf('Total distance travelled, y = %0.4f m\n\n',total_Y);

% before the code below makes any sense you must
% apply calibration and reprocess then evaluate validation set below
img_start = 110;
img_end = 141;
rng = (img_start+1):(img_end+1);

total_Y = sum(rslt(rng,4));
total_X = sum(rslt(rng,5));
pixx = sum(rslt(rng,3));
pixy = sum(rslt(rng,2));

fprintf('Validation sequence\n');
fprintf('Total pixel transition, x = %d pix\n',-pixx);
fprintf('Total pixel transition, y = %d pix\n',-pixy);
fprintf('Total distance travelled, x = %0.4f m\n',total_X);
fprintf('Total distance travelled, y = %0.4f m\n\n',total_Y);

disp 'manually examine images to measure distance'
y1 = input('enter registration line position for image in cm:');


