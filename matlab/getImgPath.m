function imgPath = getImagPath
% Project           :: Optical Odometer
% Author            :: Kenneth Laws
%                   :: Here Technologies
% Creation Date     :: 4/11/2018
%
% get the path to the image data
% specify the path in the data folder, folder may contain only image files,
% or only subfolders that contain only image files.  Subfolder names must
% be consecutive so that they sort properly when reading files


% specify the data location
if exist('/Volumes/M2Ext/Test_Drive_1214/')
    imgPath = '/Volumes/M2Ext/Test_Drive_1214/';
elseif exist('/media/kip/M2Ext/Test_Drive_1214/')
    imgPath = '/media/kip/M2Ext/Test_Drive_1214/';
else
    error('Image folder not found, update image path in script');
end

