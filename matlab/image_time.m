function imageTime = image_time(fname)
% Project           :: Optical Odometer
% Author            :: Kenneth Laws
%                   :: Here Technologies
% Creation Date     :: 4/11/2018
%
% gets the file time from the file name. It is expected that the file name
% is that of the second image.  The time corresponds to the point in time
% when the translation from the first image location to the second image
% location has been completed.
% the file name must follow the convention that the 13 digits preceding the
% '.' are a valid time number the corresponds to the time of the image.
% For now, I am not sure of the time format or pivot year, this will need
% to be worked out
% change log:
%

idx = strfind(fname,'.');

imageTime = str2double(fname(idx-13:idx));

return

