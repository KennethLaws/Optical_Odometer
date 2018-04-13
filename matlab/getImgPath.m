function imgPath = getImgPath
% Project           :: Optical Odometer
% Author            :: Kenneth Laws
%                   :: Here Technologies
% Creation Date     :: 4/11/2018
%
% get the path to the image data
% specify the path in the data folder, folder may contain only image files,
% or only subfolders that contain only image files.  Subfolder names must
% be consecutive so that they sort properly when reading files
%
% change log:
% 04/11/2018 - changed path definition structure

imgFld = 'Test_Drive_041018/images/';
% specify the data location
if exist('/Volumes/M2Ext/')
    rootFld = '/Volumes/M2Ext/';
    imgPath = [rootFld imgFld];
elseif exist('/media/kip/M2Ext/')
    rootFld = '/media/kip/M2Ext/Test_Drive_1214/';
    imgPath = [rootFld imgFld];
elseif exist('C:\Users\klaws\Desktop\Drive')
    rootFld = 'C:\Users\klaws\Desktop\Drive\';
    imgPath = [rootFld 'Test_Drive_041018\images\'];
else
    error('Image folder not found, update image path in script');
end



