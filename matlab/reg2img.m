% Process two selected images to determine x y shift in position
% Kenneth Laws
% 01/04/2017

clear all;

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
[image_1, image_2] = load_images(fnames);


[ypeak, xpeak, c, max_c] = image_reg(yPix,xPix,image_2,image_1,x1,y1,h,w);

% compute shift
deltPosPix = -[y1 - ypeak,x1 - xpeak];

dy_inches = dpix2dcm(y1,ypeak);

% plot the first image
figure(1), clf, hold on, colormap gray
pcolor(image_1);
shading interp;

% plot the subframe
plotrect(x1,y1,w,h,1);

%plot a registration line
plot([800, 1200],[y1 y1],'r');
axis equal

% plot the second image
figure(2), clf, hold on, colormap gray
pcolor(image_2);
shading interp;


%plot a registration line
plot([800, 1200],[ypeak ypeak],'r');

% plot the subframe
plotrect(xpeak,ypeak,w,h,2);


%plot the original registration line
figure(2)
plot([800, 1200],[y1 y1],'g--');
axis equal

figure(3); clf; surf(abs(c)), shading interp;


% print results
%fprintf('Camera = %s\n',camera);
%fprintf('installed lens = %s\n', lens);
fprintf('*************************************************\n');
fprintf('file 1: %s\n',fnames{1});
fprintf('file 2: %s\n',fnames{2});
fprintf('image size: %d x %d\n',size(image_1));
fprintf('template size: %d x %d \n',w,h);
fprintf('template lower left corner position: (%d, %d)\n', y1,x1);
fprintf('processing matrix dimensions: (%d, %d)\n',yPix,xPix);
fprintf('retrieved position: (%d, %d)\n',xpeak,ypeak);
fprintf('retrieved position shift: dy = %d pix, dx = %d pix\n',deltPosPix);
fprintf('retrieved y position shift: dy = %0.1e in\n',dy_inches);
%fprintf('reading files took %0.3E sec\n',et1);
%fprintf('analysis took %0.3E sec\n',et);



% estimate signal to noise
s = reshape(c,[size(c,1)*size(c,2),1]);  % power spectrum
snr_db = 10*log10(max(s)/std(s));        % signal to noise of power spectrum

fprintf('Power spectrum statistics: std=%0.1E peak=%0.1E snr=%0.1f dB\n', ...
    std(s), max(s), snr_db);
fprintf('\n');
    
    

