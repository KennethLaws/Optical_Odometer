function deltPosMeters = optCompShift(deltPosPix,imageTime,meanRng,rngOffset,...
    lensScalefactor)
% Project           :: Optical Odometer
% Author            :: Kenneth Laws
%                   :: Here Technologies
% Creation Date     :: 4/26/2018
% Modified          :: 
%

% Part of optimization routine (find_rangefinder_params.m) this function to 
% estimate the distance between two points in the image frame in meters
% using active calibration based on range finder data, modified to take
% rangefinder parameters as inputs and to include the rangefinder
% calibration
%
% Change Log:
% 5/1/18 changed range input to be the mean range over each image interval


% compute the calibration factor
% temporary approximation for linear calibration
emprclCalFctr = lensScalefactor;      % empirical calibration factor derived from training data
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

end


