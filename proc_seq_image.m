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
fprintf('Camera = %s\n',camera);
fprintf('installed lens = %s\n', lens);
fprintf('*************************************************\n');

% load the first image
image_1 = imread('../../images/Driveway2/10172917_run4_2017-10-17-100449-0000.pgm')';

% read in the second image
image_2 = imread('../../images/Driveway2/10172917_run4_2017-10-17-100454-0000.pgm')';


resolution = size(image_1);
% imageRes = resolution./imageSize;
fprintf('Resolution = %d x %d\n',resolution);
% fprintf('Image size = %0.2E x %0.2E\n',imageRes);

% % normalize the images
% image_1 = image_1./max(image_1);
% image_2 = image_2./max(image_2);

% simulation parameters
% ************************************************************************

% define a subframe (smaller than maximum)
w = 400;    % width of subframe
h = 200;    % height of subframe
x1 = 450;   % bottom left corner of initial subframe at top center of pix frame
y1 = 1300;
fprintf('template size: %d x %d \n',w,h);
fprintf('template lower left corner position: (%d, %d)\n', x1,y1);

% plot the first image
figure(1), clf, hold on, colormap gray
pcolor(image_1);
shading interp;

% plot the subframe
plotrect(x1,y1,w,h,1);

%plot a registration line
plot([800, 1200],[1300 1300],'r');



% plot the second image
figure(2), clf, hold on, colormap gray
pcolor(image_2);
shading interp;


% compute the registration point of the subframe in the second image 
% y2 = y1-pix_shift(1);
% x2 = x1-pix_shift(2);
% 
% % plot the registration marks at the shifted location
% plotreg(x2,y2,2);

% grab the subframe image
subFrame1 = image_1(y1:(y1+h),x1:x1+w); 

% perform the matching
template = subFrame1;
background = image_2;

[by, bx] = size(image_2);
[ty, tx] = size(template);

%start performance timer
tic;

Ga = fft2(background);
Gb = fft2(template, by, bx);
c = real(ifft2((Ga.*conj(Gb))./abs(Ga.*conj(Gb))));

% find peak correlation
% xpeak and ypeak are the bottom left corner of the matched window

[max_c, imax]   = max(abs(c(:)));
[ypeak, xpeak] = find(c == max(c(:)));

et = toc;

% check results
% compute shift
deltPosPix = [y1 - ypeak,x1 - xpeak];
%deltPos = deltPosPix./frame_res_pix;

%plot a registration line
plot([800, 1200],[ypeak-4 ypeak-4],'r');

%plot the original registration line
plot([800, 1200],[1300 1300],'r');

% print resutls
fprintf('retrieved position: (%d, %d)\n',xpeak,ypeak);
fprintf('retrieved position shift: dy = %d pix, dx = %d pix\n',deltPosPix);
% fprintf('retrieved position shift: dy = %0.2E m, dx = %0.2E m\n',deltPosPix./imageRes);
% fprintf('retrieved position shift: dy = %0.4f m, dx = %0.4f m\n',deltPos);
% retErr = deltPos - [dy, dx];
% fprintf('retrieved position error: delty = %.2E m, deltx = %0.2E m\n',retErr);

fprintf('analysis took %0.2E sec\n',et);


% New - no need to offset the coordinates anymore
figure(3); surf(abs(c)), shading interp;
%figure(3); pcolor(c), shading interp;
plotrect(xpeak, ypeak, w, h,2);

% estimate signal to noise
rsqr = c.^2;
log_rsqr = log10(rsqr);
en = mean(mean(log_rsqr(1:100,1:100)));
sig = max(max(log_rsqr));
% figure(4)
% surf(log_rsqr), shading interp;

fprintf('corellation statistics: mean = %0.2E, std = %0.2E peak = %0.2E \n', ...
    mean(c(100:1500)), std(c(100:1500)), max_c);
fprintf('Signal to noise ratio = %0.3f dB\n', sig-en);
fprintf('\n');