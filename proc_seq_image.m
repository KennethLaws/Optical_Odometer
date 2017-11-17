% Process images to determine x y shift in position
% Kenneth Laws
% 10/16/2017

% adds calculation of resolution in pix/m from measured frame size
% adds printout of setup parameters
% removes use of camera height and resolution calculation (pix/m) these
% depend on the experiment parameters and this script is more general

clear all;

% specify camera lens and setup
camera = 'BLFY-PGE-20E4C-CS';
lens = '8MM 1/1.8 ir mp';   % this lens has much lower distortion than previous

% define a subframe (smaller than maximum)
imageRes = [1600, 1200];
w = 256;    % width of subframe
h = 128;    % height of subframe
xPix = 1024;    % matrix dimensions for image processing factor of 2^n
yPix = 1024;
x1 = (imageRes(2) - w)/2;
y1 = imageRes(1) - h;

% set the file names
imgFile1 = '../../images/Driveway2/10172917_run4_2017-10-17-100449-0000.pgm';
imgFile2 = '../../images/Driveway2/10172917_run4_2017-10-17-100454-0000.pgm';

% load in the images
tic;
[image_1, image_2, subFrame1] = load_images(imgFile1,imgFile2,x1,y1,h,w);
et1=toc;

% process image pair
tic;
[ypeak, xpeak, c, max_c] = image_reg(yPix,xPix,image_2,subFrame1);
et = toc;

% compute shift
deltPosPix = [y1 - ypeak,x1 - xpeak];

%******************************************************


% generate plots and outputs

% plot the first image
figure(1), clf, hold on, colormap gray
pcolor(image_1);
shading interp;

% plot the subframe
plotrect(x1,y1,w,h,1);

%plot a registration line
plot([800, 1200],[y1 y1],'r');

% plot the second image
figure(2), clf, hold on, colormap gray
pcolor(image_2);
shading interp;


%plot a registration line
plot([800, 1200],[ypeak-4 ypeak-4],'r');

%plot the original registration line
plot([800, 1200],[y1 y1],'r');

% print results
fprintf('Camera = %s\n',camera);
fprintf('installed lens = %s\n', lens);
fprintf('image size: %d x %d\n',size(image_1));
fprintf('*************************************************\n');
fprintf('template size: %d x %d \n',w,h);
fprintf('template lower left corner position: (%d, %d)\n', y1,x1);
fprintf('processing matrix dimensions: (%d, %d)\n',yPix,xPix);
fprintf('retrieved position: (%d, %d)\n',xpeak,ypeak);
fprintf('retrieved position shift: dy = %d pix, dx = %d pix\n',deltPosPix);
fprintf('reading files took %0.3E sec\n',et1);
fprintf('analysis took %0.3E sec\n',et);


figure(3); surf(abs(c)), shading interp;
plotrect(xpeak, ypeak, w, h,2);

% estimate signal to noise
rsqr = c.^2;
log_rsqr = log10(rsqr);
en = mean(mean(log_rsqr(1:100,1:100)));
sig = max(max(log_rsqr));

fprintf('corellation statistics: mean = %0.2E, std = %0.2E peak = %0.2E \n', ...
    mean(c(100:1500)), std(c(100:1500)), max_c);
fprintf('Signal to noise ratio = %0.3f dB\n', sig-en);
fprintf('\n');