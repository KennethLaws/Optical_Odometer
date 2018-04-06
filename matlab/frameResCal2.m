% Process a selected calibration image to determine x y shift in position
% this is a laborious process by hand of reading a tape measure in the
% optical frame over a range of pixel shifts.  I probably could of used
% much fewer points and still been certian ov linearity.
%   After calibration is complete a function call retrieves the saved
% result to use for computing shifts.  
%
% Returns
% p = [intercept slope]  in cm

% Kenneth Laws
% 01/05/2017

function p = Test_Drive_1214_calib2

doplot = 0;

if ~exist(['data/' 'calibData.mat'])
    % define a subframe (smaller than maximum)
    imageRes = [1920, 1200];
    w = 256;    % width of subframe
    h = 128;    % height of subframe
    xPix = 1200;    % matrix dimensions for image processing factor of 2^n
    yPix = 1920;
    x1 = (imageRes(2) - w)/2;
    %y1 = imageRes(1) - h;          % this location at the top of the frame did
    %not work since the orientation of the camera apparrently has the top and
    %bottom of fram reversed
    y1 = 100;   % this location near the bottom of the image should allow for some reverse motion of
    % vehicle and hopefully enough top image overlap
    % evaluate frame calibration
    
    fileNum = 70;       % select the index of the first image
    
    if exist('/Volumes/M2Ext/Test_Drive_1214/calib2/')
        imgPath = '/Volumes/M2Ext/Test_Drive_1214/calib2/';
    elseif exist('/media/earthmine/M2Ext/Test_Drive_1214/calib2/')
        imgPath = '/media/earthmine/M2Ext/Test_Drive_1214/calib2/';
    else
        error('Image folder not found, update image path in script');
    end
    
    flist = dir([imgPath '*.*']);
    % extract a cell array of logicals (1 if is directory)
    dirset = {flist.isdir};
    % convert this to an array of logicals
    dirset = cell2mat(dirset);
    % use this to get all folder names
    foldNames = {flist(dirset).name};
    
    fileNames = {flist(~dirset).name};
    nFiles = length(fileNames);
    
    f1 = strcat(imgPath, fileNames(fileNum));
    f2 = strcat(imgPath, fileNames(fileNum + 1));
    fnames = [f1 f2];
    
    % load in the images
    % just making it simple by reusing old code.  Only need to use one image
    [image_1, image_2] = load_images(fnames);
    
    % plot the first image
    figure(1), clf, hold on, colormap gray
    pcolor(image_1);
    shading interp;
    
    % plot the subframe
    plotrect(x1,y1,w,h,1);
    
    %plot a registration line
    plot([800, 1200],[y1 y1],'r');
    %axis([800 1000 50 150]);
    %axis equal
    
    startPoint = 126.18;  % position in cm at pix = 100
    startPoint_in = 49 + 9.6/16;
    ycalib = [];
    ypix = [];

    load('calibData', 'ypix', 'ycalib');

    % step through calib points    for dy = 430:30:700
    for dy = 1230:30:1500
        
        %replot registration line
        plot([800, 1200],[y1+dy y1+dy],'r');
        axis([800 1000 dy 400+dy]);
        sprintf('getting location for position %d pixels\n',y1+dy);
        y = input('Enter registration line location (cm): ');
        y = y*2.54;     % inch to cm convertion
        ycalib = [ycalib y];
        ypix = [ypix y1+dy];
        
    end
    
    save('calibData', 'ypix', 'ycalib');
end
    
load('calibData', 'ypix', 'ycalib');

% fit an analytic function to the measured resolution c(x)
p = polyfit(ypix,ycalib,1);


if doplot
    fitVals = polyval(p,ypix);
    figure(2), clf, hold on
    plot(ypix,ycalib,'*');
    
    plot(ypix,fitVals)
    xlabel('Distance from frame maximum (pixels)')
    ylabel('Image resolution (pixels/inch)')
    % 
    txt = {};    
    txt{1} = sprintf('c1 = %0.3e, c0 = %0.3e',p);
    % txt{2} = sprintf('Frame Maximum = %d',fc);
    text(600,175,txt)
    
    
end


return