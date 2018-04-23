function[imgPath rngFndrPath gpsPath dataSetID] = getImgPath
% Project           :: Optical Odometer
% Author            :: Kenneth Laws
%                   :: Here Technologies
% Creation Date     :: 4/11/2018
%
% get the path to the image data and gps and rangefinder data
% specify the path in the data folder, folder may contain only image files,
% or only subfolders that contain only image files.  Subfolder names must
% be consecutive so that they sort properly when reading files
%
% change log:
% 04/11/2018 - changed path definition structure, modify to return gps and
% rangefinder paths as well

dataSetID = 'Test_Drive_041718';
imgFld = [dataSetID '/partial/'];
%imgFld = 'images/';
rngfndrFile = 'Test_Drive_041718/rangefinder/';
%rngfndrFile = 'rangefinder/';
% gpsFile = 'Test_Drive_041018/gps/';
gpsFile = 'gps/';
% specify the data location
if exist('/Volumes/M2Ext/')
    rootFld = '/Volumes/M2Ext/';
    imgPath = [rootFld imgFld];
    rngFndrPath = [rootFld rngfndrFile];
    gpsPath = [rootFld gpsFile];
elseif exist('/media/kip/M2Ext/')
    rootFld = '/media/kip/M2Ext/';
% elseif exist('/media/kip/960Pro/')
%     rootFld = '/media/kip/960Pro/';
    imgPath = [rootFld imgFld];
    rngFndrPath = [rootFld rngfndrFile];
    gpsPath = [rootFld gpsFile];
elseif exist('C:\Users\klaws\Desktop\Drive')
    rootFld = 'C:\Users\klaws\Desktop\Drive\';
    imgPath = [rootFld 'Test_Drive_041018\images\'];
    rngFndrPath = [rootFld 'Test_Drive_041018\rangefinder\'];
    gpsPath = [rootFld 'Test_Drive_041018\gps\'];
else
    error('Image folder not found, update image path in script');
end



