% plot_seqImg_rslt
clear;

%fname = 'seq_image_rslt_1214_1.mat';
fname = 'seq_image_rslt.mat';
% rslt(step,:) = [step, deltPosPix, dy_inches, snr_db];
load(fname);

% start and end image by image number
img_start = 0;
img_end = 141;
rng = (img_start+1):(img_end+1);

total_Y = sum(rslt(rng,4));
fprintf('Total distance travelled, y = %0.4f m\n',total_Y);

figure(1), clf
plot(rslt(rng,1),rslt(rng,4))
ylabel('Distance per Frame Pair (m)');
xlabel('Image Number')
title('12/14/17 Test Calibration')