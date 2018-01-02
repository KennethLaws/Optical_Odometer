% Process images to determine x y shift in position
% Kenneth Laws
% 10/16/2017

% adds calculation of resolution in pix/m from measured frame size
% adds printout of setup parameters
% removes use of camera height and resolution calculation (pix/m) these
% depend on the experiment parameters and this script is more general

clear all;
doplot = 1;

% specify camera lens and setup
% camera = 'BLFY-PGE-20E4C-CS';
% lens = '8MM 1/1.8 ir mp';   % this lens has much lower distortion than previous

% define a subframe (smaller than maximum)
imageRes = [1920, 1200];
w = 256;    % width of subframe
h = 128;    % height of subframe
xPix = 1200;    % matrix dimensions for image processing factor of 2^n
yPix = 1920;
x1 = (imageRes(2) - w)/2;
y1 = imageRes(1) - h;

imgPath = '/Volumes/M2Ext/Test_Drive_1214/calib2/';

step = 1;       % keep track of image step

while 1
    % set the file names
    [p,fnames, done] = get_file_names(imgPath);
    if done, break; end
    
    % load in the images
    [image_1, image_2] = load_images(fnames);
  
    % process image pair
    %[ypeak, xpeak, c, max_c] = image_reg(yPix,xPix,image_2,subFrame1);
    [ypeak, xpeak, c, max_c] = image_reg(yPix,xPix,image_2,image_1,x1,y1,h,w);

    % compute shift
    deltPosPix = [y1 - ypeak,x1 - xpeak];
    
    dy_inches = dpix2dcm(y1,ypeak)

    % generate plots and outputs
    if doplot
        % plot the first image
        figure(4), clf, hold on, colormap gray
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
        plot([800, 1200],[ypeak ypeak],'r');

        % plot the subframe
        plotrect(xpeak,ypeak,w,h,2);


        %plot the original registration line
        figure(2)
        plot([800, 1200],[y1 y1],'g--');
        
        figure(3); clf; surf(abs(c)), shading interp;   
    end
    
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
    %fprintf('reading files took %0.3E sec\n',et1);
    %fprintf('analysis took %0.3E sec\n',et);



    % estimate signal to noise
    rsqr = c.^2;
    log_rsqr = log10(rsqr);
    en = mean(mean(log_rsqr(1:100,1:100)));
    sig = max(max(log_rsqr));

    fprintf('corellation statistics: mean = %0.2E, std = %0.2E peak = %0.2E \n', ...
        mean(c(100:1500)), std(c(100:1500)), max_c);
    fprintf('Signal to noise ratio = %0.3f dB\n', sig-en);
    fprintf('\n');

    rslt(step,:) = [step, deltPosPix, dy_inches];
    step = step + 1;
end

save('seq_image_rslt', 'rslt');


        



