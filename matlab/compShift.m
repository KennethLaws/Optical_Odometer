function deltPosMeters = compShift(deltPosPix,imageTime,meanRng)
% Project           :: Optical Odometer
% Author            :: Kenneth Laws
%                   :: Here Technologies
% Creation Date     :: 01/05/2017
%
% function to calibrate the distance between two points in the image frame
% using active calibration based on range finder data.
% Converts pixels to meters
%
% Change Log:
% 4/11/2018 modified calibration to use range finder
% Calibration is done using part of the calibration/validation drive data set
% as a training set.  It is assumed that the calibration of distance per
% pixel is constant over the frame and given by
% m/pix = R*sin(theta/2) / nPix/2
% 5/3/18 Puts the calibration function here


% compute the calibration factor
rngOffset = -5.97617;      % offset between camera effective height and rangefinder height
emprclCalFctr = 3.57617;      % empirical calibration factor derived from training data
lensAngle = [70.6 48]*emprclCalFctr;     % viewing angle in degrees https://www.baslerweb.com/en/products/tools/lens-selector/
cameraRes = [1920 1200];    % camera resolution

H = (8 + rngOffset) * 2.54;   % standoff of the rangefinder, depends on model (inches converted to cm)
R = (H + meanRng) / 100;  % distance from camera to ground (m)
theta = lensAngle * pi/180;     %

% do the calibration based on the long image dimension only
metersPerPix = (R * theta(1))./cameraRes(1);

% for now, just return one resolution
% the horizontal and vertical should be the same but are not quite  
deltPosMeters = ones(size(metersPerPix));
deltPosMeters(:,1) = deltPosPix(:,1) .* metersPerPix;
deltPosMeters(:,2) = deltPosPix(:,2) .* metersPerPix;
return


