function [gpsX gpsY gpsZ] = latlon2xyz(gpsPos)
% Project           :: Optical Odometer
% Author            :: Kenneth Laws
%                   :: Here Technologies
% Creation Date     :: 04/24/2018
% Modified          :: 
%
% converts lat lon position measurements to horizontal position in meters
% relative to the center point of the lat lon positions plus altitude, in
% meters

lat = gpsPos(:,2)';
lon = gpsPos(:,3)';
gpsZ = gpsPos(:,4)';

% use apprx for small area of earth with lattitude ~= to mean lattitude
% use the mean of the lat and lon as the reference point (0,0) in meters
clat = mean(lat);
clon = mean(lon);

% compute the difference in lattitude from the reference lat (mean)
dlat = lat - clat;
dlon = lon - clon;

%  dy = lat_to_m(dlat,alat)
% dy   = latitude difference in meters
% dlat = latitude difference in degrees
% clat = average latitude 
% Reference: American Practical Navigator, Vol II, 1975 Edition, p 5 

rlat = clat * pi/180;
m = 111132.09 * ones(size(rlat)) - ...
    566.05 * cos(2 * rlat) + 1.2 * cos(4 * rlat);
gpsY = dlat .* m ;

% dx = lon_to_m(dlon, alat)
% dx   = longitude difference in meters
% dlon = longitude difference in degrees
% alat = average latitude between the two fixes

p = 111415.13 * cos(rlat) - 94.55 * cos(3 * rlat);
gpsX = dlon .* p;

return

  
