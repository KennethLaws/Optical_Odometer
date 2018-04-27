function deltPosMeters = optCompShift(deltPosPix,imageTime,rngTime,rng,rngOffset,...
    lensScalefactor)
% Project           :: Optical Odometer
% Author            :: Kenneth Laws
%                   :: Here Technologies
% Creation Date     :: 4/26/2018
% Modified          :: 
%

% function to estimate the distance between two points in the image frame
% using active calibration based on range finder data, modified to take
% rangefinder parameters as inputs and to include the rangefinder
% calibration
%
% Change Log:
% 

% find the range offset from rangefinder data
idx = find(rngTime >= imageTime(1) & rngTime <= imageTime(2));
d = mean(rng(idx),'omitnan');

% compute the calibration factor
% temporary approximation for linear calibration
emprclCalFctr = lensScalefactor;      % empirical calibration factor derived from training data
lensAngle = [70.6 48]*emprclCalFctr;     % viewing angle in degrees https://www.baslerweb.com/en/products/tools/lens-selector/
cameraRes = [1920 1200];    % camera resolution

H = (8 + rngOffset) * 2.54;   % standoff of the rangefinder, depends on model (inches converted to cm)
R = (H + d) / 100;  % distance from camera to ground (m)
theta = lensAngle * pi/180;     %
metersPerPix = (R * theta)./cameraRes;

% for now, just return one resolution
% the horizontal and vertical should be the same but are not quite  

metersPerPix = metersPerPix(1);
deltPosMeters = deltPosPix * metersPerPix;

end


