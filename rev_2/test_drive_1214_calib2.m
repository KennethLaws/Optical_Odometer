% Calibration  
% Kenneth Laws
% 01/05/2017
% Uses a set of images taken with tape measure in the image frames.  Frames
% are first examined to make find range of images with good usable image of
% tape measure in frame, then processed using proc_seq_image.  About half
% of the images are used for calibraiton and the other half for validation.
% The calibration image range results give total pixels travelled.  The
% range of images are then manually examined to measure the difference in
% positions of the registration mark on the tape between the first and last
% images, giving the total distance translation.  The individual pixel 
% translations for each image pair are summed to find the total pixel 
% translation.  The calibration is returned as p = [slope, int=0] m/pix


function p = test_Drive_1214_calib2

dataSet = 'Test_Drive_1214/calib2';
calibRangeStep = 50:110;
startImage = 'img_2017-12-14-100226_49.tmp';
endImage = 'img_2017-12-14-100239_110.tmp';

% distance travelled measured from sequential image shifts
pixx = 10;      % translation x pix
pixy = 2054;    % translation y pix

% distance travelled measured directly from tape
total_X = 0.0035;   % translation x m
total_Y = 0.7191;   % translation y m

slope = total_Y/pixy; % calibrated slope m/pix

p = [slope, 0];

return