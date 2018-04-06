function rslt = template_shift(yPix,xPix,image_2,image_1,x,y,h,w,calib,step,doplot)
% given two images and a definition of template region, determine the shift
% 
% Autors: Kenneth Laws
%         Here Technologies
%
% Date:   02/18/2018

    % do image registration
    [ypeak, xpeak, c, max_c] = image_reg(yPix,xPix,image_2,image_1,x,y,h,w);
    
    % bad data rejection
    [reject,fracSat,fracBlk,normDiff,edgeLim,BLK,SAT,MSMTCH,deltPosAmbg,ambgRatio] = data_reject(c,ypeak,xpeak, max_c,yPix,xPix,image_1,image_2,x,y,h,w); 

    % compute shift
    deltPosPix = [ypeak-y,xpeak-x];
    
    % transform to caibrated measure of translation (m)
    deltPosMeters = compShift(deltPosPix,calib);

    % generate plots and outputs
    if doplot
        % plot the first image
        figure(1), clf, hold on, colormap gray
        pcolor(image_1);
        shading interp;

        % plot the subframe
        plotrect(x,y,w,h,1);

        %plot a registration line
        plot([800, 1200],[y y],'r');

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
        plot([800, 1200],[y y],'g--');
        
        figure(3); clf; surf(abs(c)), shading interp;   
    end

    % estimate signal to noise
    s = reshape(c,[size(c,1)*size(c,2),1]);  % power spectrum
    solutionPk = max(s);
    snr_db = 10*log10(solutionPk/std(s));    % signal to noise of power spectrum
    
        % print results
    fprintf('template size: %d x %d \n',w,h);
    fprintf('template lower left corner position: (%d, %d)\n', y,x);
    fprintf('processing matrix dimensions: (%d, %d)\n',yPix,xPix);
    fprintf('retrieved position: (%d, %d)\n',xpeak,ypeak);
    fprintf('retrieved position shift: dy = %d pix, dx = %d pix\n',deltPosPix);
    fprintf('retrieved position shift: dy = %0.3e m, dx = %0.3e m\n',deltPosMeters);
    fprintf('Power spectrum statistics: std=%0.1E peak=%0.1E snr=%0.1f dB\n', ...
        std(s), max(s), snr_db);
    fprintf('\n');
    %fprintf('reading files took %0.3E sec\n',et1);
    %fprintf('analysis took %0.3E sec\n',et);  
    
     rslt = [step,deltPosPix,deltPosMeters,reject,snr_db,fracSat,fracBlk,normDiff,edgeLim,BLK,SAT,MSMTCH,deltPosAmbg,ambgRatio];

return
