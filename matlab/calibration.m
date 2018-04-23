function metersPerPix = calibration(d)
% Project           :: Optical Odometer
% Author            :: Kenneth Laws
%                   :: Here Technologies
% Creation Date     :: 01/05/2017
% Modified          :: 04/11/2018
%
% set calibration in meters per pixel
%
% Change Log:
% 4/11/2018 modified calibration to use range finder
% Calibration is done using part of the calibration/validation drive data set
% as a training set.  It is assumed that the calibration of distance per
% pixel is constant over the frame and given by
% m/pix = R*sin(theta/2) / nPix/2

% temporary approximation for linear calibration
lensAngle = [70.6 48];     % viewing angle in degrees https://www.baslerweb.com/en/products/tools/lens-selector/
cameraRes = [1920 1200];    % camera resolution

H = 8 * 2.54;   % standoff of the rangefinder, depends on model (inches converted to cm)
R = (H + d) / 100;  % distance from camera to ground (m)
theta = lensAngle * pi/180;     %
metersPerPix = (R * theta)./cameraRes;

% for now, just return one resolution
% he horizontal and vertical should be the same but are not quite  

metersPerPix = metersPerPix(1);

return