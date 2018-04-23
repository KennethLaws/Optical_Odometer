function deltPosMeters = compShift(deltPosPix,imageTime,rngTime,rng)
% Project           :: Optical Odometer
% Author            :: Kenneth Laws
%                   :: Here Technologies
% Creation Date     :: 01/05/2017
% Modified          :: 04/11/2018
%

% function to estimate the distance between two points in the image frame
% using active calibration based on range finder data
%
% Change Log:
% 

% find the range offset from rangefinder data
idx = find(rngTime >= imageTime(1) & rngTime <= imageTime(2));
d = mean(rng(idx),'omitnan');

% compute the calibration factor
metersPerPix = calibration(d);

deltPosMeters = deltPosPix * metersPerPix;

end


