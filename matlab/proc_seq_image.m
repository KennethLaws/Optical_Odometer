% Process images to determine x y shift in position
% Kenneth Laws
% 10/16/2017

% adds calculation of resolution in pix/m from measured frame size
% adds printout of setup parameters
% removes use of camera height and resolution calculation (pix/m) these
% depend on the experiment parameters and this script is more general
% includes outlier rejection and gap filling

clear all;
doplot = 0;

% specify the path in the data folder, folder may contain only image files,
% or only subfolders that contain only image files.  Subfolder names must
% be consecutive so that they sort properly when reading files
folderSpec = 'Drive/';  

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

%set location and size of template region
w = 256;    % width of subframe
h = 128;    % height of subframe
x1 = (imageRes(2) - w)/2;
y1 = 100;



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
    
    % process image pair
    %[ypeak, xpeak, c, max_c] = image_reg(yPix,xPix,image_2,subFrame1);
    [ypeak, xpeak, c, max_c] = image_reg(yPix,xPix,image_2,image_1,x1,y1,h,w);
    
    % bad data rejection
    [reject,fracSat,fracBlk,normDiff,edgeLim,BLK,SAT,MSMTCH,deltPosAmbg,ambgRatio] = data_reject(c,ypeak,xpeak, max_c,yPix,xPix,image_1,image_2,x1,y1,h,w); 

    % compute shift
    deltPosPix = [ypeak-y1,xpeak-x1];
    
    % transfor to caibrated measure of translation (m)
    %deltY = compDY(y1,ypeak,calib);
    %deltY = deltY * 2.67/2.59;
    %deltX = compDY(x1,xpeak,calib);
    %deltX = deltX * 2.67/2.59;
    %deltPosPix = [72 35]  % debug test
    deltPosMeters = compShift(deltPosPix,calib);

    % generate plots and outputs
    if doplot
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
    fprintf('step = %d\n',step);
    fprintf('file 1: %s\n',fnames{1});
    fprintf('file 2: %s\n',fnames{2});
    fprintf('image size: %d x %d\n',size(image_1));
    fprintf('template size: %d x %d \n',w,h);
    fprintf('template lower left corner position: (%d, %d)\n', y1,x1);
    fprintf('processing matrix dimensions: (%d, %d)\n',yPix,xPix);
    fprintf('retrieved position: (%d, %d)\n',xpeak,ypeak);
    fprintf('retrieved position shift: dy = %d pix, dx = %d pix\n',deltPosPix);
    fprintf('retrieved position shift: dy = %0.3e m, dx = %0.3e m\n',deltPosMeters);
    %fprintf('reading files took %0.3E sec\n',et1);
    %fprintf('analysis took %0.3E sec\n',et);

    % debugging test
    %if deltY > .025
    %    pause
    %end

    % estimate signal to noise
    s = reshape(c,[size(c,1)*size(c,2),1]);  % power spectrum
    solutionPk = max(s);
    snr_db = 10*log10(solutionPk/std(s));    % signal to noise of power spectrum
    
    fprintf('Power spectrum statistics: std=%0.1E peak=%0.1E snr=%0.1f dB\n', ...
        std(s), max(s), snr_db);
    fprintf('\n');

    rslt(step,:) = [step,deltPosPix,deltPosMeters,reject,snr_db,fracSat,fracBlk,normDiff,edgeLim,BLK,SAT,MSMTCH,deltPosAmbg,ambgRatio];
end

% fill gaps created by data rejection

pathName = 'data/';
rsltFile = [pathName 'seq_image_rslt_',date];
if exist([rsltFile '.mat'])
    s = input('result file exists, overwrite (y/n): ','s');
else
    s = 'y';
end
if s == 'y'
    save(rsltFile, 'rslt');
end

% check the results
plot_seqImg_rslt([rsltFile, '.mat'])



