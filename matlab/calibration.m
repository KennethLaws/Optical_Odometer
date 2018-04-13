function P = calibration
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
% dres_pix = R*theta/Npix
% where R is the distance to the ground and theta is the full width angle
% of the lens, and Npix is the number of pixels in the given dimension.  
% We can define a constant
% C = theta/Npix
% and then have 
% dres_pix = R*C
% and then define
% R = d' + H 
% where d' is the reading of the rangefinder (height above offset, offset =
% 8" for the demo unit AR700-8 RP) and H is the rangefinder offset.  This
% Then, if we define the total translation D,
% D = sum( l_i ) = sum( n_i * dres_pix) = sum( n_i * R_i * C)
% where l_i are the individual displacements, and n is the number of pixels
% D = 1 * sum( n_i*C * ((d_i'+ H) )
% D = * C * [ sum(n_i * (d_i + H)) ]
% C = D / [sum(n_i * (d_i + H))]

% temporary approximation for liinear claibration
slope = 1/2000;
intcpt = 0;
P = [slope intcpt];

return