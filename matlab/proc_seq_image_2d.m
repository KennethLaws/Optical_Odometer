% Process images to determine x y shift in position
% Uses two template sections, on opposite sides of the image frame.
% Differences in the shift from opposite sides of the image are used to
% determine change of heading
% Kenneth Laws
% 2/18/2018

% Calculation of heading angular resolution:

clear all;
doplot = 0;

% specify the path in the data folder, folder may contain only image files,
% or only subfolders that contain only image files.  Subfolder names must
% be consecutive so that they sort properly when reading files
folderSpec = 'temp/';  

% specify the data folder
if exist('/Volumes/M2Ext/Test_Drive_1214/')
    imgPath = '/Volumes/M2Ext/Test_Drive_1214/';
elseif exist('/media/earthmine/M2Ext/Test_Drive_1214/')
    imgPath = '/media/earthmine/M2Ext/Test_Drive_1214/';
else
    error('Image folder not found, update image path in script');
end

imgPath = strcat(imgPath,folderSpec);

% specify camera lens and setup
% camera = 'BLFY-PGE-20E4C-CS';
% lens = '8MM 1/1.8 ir mp';   % this lens has much lower distortion than previous

% define a subframe (smaller than maximum)
imageRes = [1920, 1200];
xPix = 1200;    % matrix dimensions for image processing factor of 2^n
yPix = 1920;

%set location and size of template region 1 (Starboard side of frame)
w1 = 256;    % width of subframe
h1 = 128;    % height of subframe
% coordinates of lower left corner
x1 = imageRes(2) - w1 - 10;
y1 = 100;

%set location and size of template region 2 (port side of frame)
w2 = 256;    % width of subframe
h2 = 128;    % height of subframe
% coordinates of lower left corner
x2 = 10;
y2 = 100;

%compute the difference in radius based on template location
delta_r = -(x2 - x1);

% get calibration data
calib = test_drive_1214_calib2;

% begin processing selected data set
step = 0;       % keep track of image step
while 1
    step = step + 1;

    % set the file names
    [p,fnames, done] = get_file_names(imgPath);
    if done, break; end
    
    %debugging test
    if step == 291
        disp stop;
    end
    
    % load in the images
    [image_1, image_2] = load_images(fnames);

    fprintf('step = %d\n',step);
    fprintf('*************************************************\n');
    fprintf('file 1: %s\n',fnames{1});
    fprintf('file 2: %s\n',fnames{2});
    fprintf('image size: %d x %d\n',size(image_1));

    % process image pair for both template regions
    rslt1(step,:) = template_shift(yPix,xPix,image_2,image_1,x1,y1,h1,w1,calib,step,doplot);   
    rslt2(step,:) = template_shift(yPix,xPix,image_2,image_1,x2,y2,h2,w2,calib,step,doplot);   

end

% fill gaps created by data rejection


rsltFile = ['seq_image2d_rslt_',date];
if exist([rsltFile '.mat'])
    s = input('result file exists, overwrite (y/n): ','s');
else
    s = 'y';
end
if s == 'y'
    save(rsltFile, 'rslt1', 'rslt2', 'delta_r');
end

% check the results
%plot_seqImg_rslt([rsltFile, '.mat'])



