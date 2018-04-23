
function plot_seqImg_rslt(fname)
% plot_seqImg_rslt


dataPath = 'data/';
if nargin == 0
    fname = 'seq_image_rslt_Test_Drive_041718.mat';
end

% set name to save or read filtered data set
gapFillName = ['gapFill_',fname];

% load in the raw sequential image processed data
load([dataPath fname]);

% % start and end image by image number
% img_start = 0;
% img_end = 141;
% rng = (img_start+1):(img_end+1);

timeStep = 10/1562;     % colelcted 1562 images per 10 sec
vehDy = rslt(:,4)';
vehSpd = vehDy/timeStep;
imgNum = rslt(:,1)' - 1;


dataGaps = imgNum(rslt(:,6) == 1);

figure(4), clf, hold on
ylabel('Vehicle Speed (m/s)');
xlabel('Image Number')
title(fname, 'Interpreter', 'none' ) 
plot(rslt(:,1),vehSpd)
plot(rslt(rslt(:,6) == 1,1),vehSpd(rslt(:,6) == 1),'r.')


figure(5), clf
plot(rslt(:,1),rslt(:,7))
ylabel('SNR (dB)');
xlabel('Image Number')

% apply bad data rejection
rslt(rslt(:,6) == 1,4) = NaN;
vehSpd(rslt(:,6) == 1) = NaN;
vehDy(rslt(:,6) == 1) = NaN;

% either load filtered data or filter the raw data to reject bad points ad
% fill with interpolated data points
if exist([dataPath gapFillName])
    s = input('Use existing filtered data file? (Y/n)','s');
    if s == 'n'
        disp 'computing gap filling filter data' 
        compFilt = 1;
    else
        disp 'using existing gap filling filter data'
        compFilt = 0;
    end
else
    compFilt = 1;
end

if compFilt == 1

    % add a new bad data filter to test
    
%     % find data with low snr over ambiguities
%     idx = find(   (rslt(:,15) > 40 | rslt(:,16) > 40) & rslt(:,17) < .5        );
%     vehSpd(idx) = NaN;
%     rslt(idx,6) = 1;

    
    % fill gaps
    % sweep through data range fitting data where there are gaps avoiding
    % extrapolation

    % could do simple average between adjacent points (and probably should have)
    gapIdx = find(isnan(vehSpd));
    fitSpan = 150;
    fitRng = fitSpan/3;
    N = length(vehSpd)/fitRng;
    N = floor(N);

    % fill gaps in the first region, here we might not be able to avoid
    % extrapolation
    startSpan = 1;
    endSpan = startSpan + fitSpan/2-1;
    fitPnts = startSpan:endSpan;
    fillPnts = 1:(fitRng);
    gapPnts = find(isnan(vehSpd(fillPnts)));
    fitSpd = vehSpd(fitPnts);
    if ~isempty(gapPnts)
        x = fitPnts(~isnan(fitSpd));
        y = fitSpd(~isnan(fitSpd));
        p = polyfit(x,y,2);
        y = polyval(p,x);
        gaps = fillPnts(gapPnts);
        vehSpd(gaps) = polyval(p,gaps);
    %     figure(10), clf, hold on;
    %     plot(fitPnts,fitSpd,'*');
    %     plot(x,y,'k');
    %     plot(gaps,vehSpd(gaps),'r*');
    end


    % fill gaps for set of sections in middle of data where we can interpolate 
    startSpan = 1;
    for nSpan = 1:N-2
        endSpan = startSpan + fitSpan-1;
        fitPnts = startSpan:endSpan;
        fillPnts = fitRng+((startSpan:(startSpan+fitRng-1)));
        fitSpd = vehSpd(fitPnts);
        gapPnts = find(isnan(vehSpd(fillPnts)));
        if ~isempty(gapPnts)
            x = fitPnts(~isnan(fitSpd));
            y = fitSpd(~isnan(fitSpd));
            p = polyfit(x,y,2);
            y = polyval(p,x);
            gaps = fillPnts(gapPnts);
            vehSpd(gaps) = polyval(p,gaps);
    %         figure(10), clf, hold on;
    %         plot(fitPnts,fitSpd,'*');
    %         plot(x,y,'k');
    %         plot(gaps,vehSpd(gaps),'r*');

        end
        startSpan = startSpan + fitRng; 
    end

    % fill gaps in last section of data
    endSpan = length(vehSpd);
    fitPnts = startSpan:endSpan;
    fillPnts = fitPnts;
    fitSpd = vehSpd(fitPnts);
    gapPnts = find(isnan(vehSpd(fillPnts)));
    if ~isempty(gapPnts)
        x = fitPnts(~isnan(fitSpd));
        y = fitSpd(~isnan(fitSpd));
        p = polyfit(x,y,2);
        y = polyval(p,x);
        gaps = fillPnts(gapPnts);
        vehSpd(gaps) = polyval(p,gaps);
    %     figure(10), clf, hold on;
    %     plot(fitPnts,fitSpd,'*');
    %     plot(x,y,'k');
    %     plot(gaps,vehSpd(gaps),'r*');
    end
    
    vehDy(rslt(:,6) == 1) = vehSpd(rslt(:,6) == 1)*timeStep;
    save([dataPath gapFillName],'vehSpd', 'vehDy');
end

load([dataPath gapFillName],'vehSpd', 'vehDy');

%total_Y = sum(rslt(rng,4));
total_Y = sum(vehDy);
fprintf('Total distance travelled, y = %0.2f m\n',total_Y);

figure(6), clf, hold on
plot(imgNum,vehSpd,'b-')
plot(imgNum,vehSpd,'b.')
idx = find(rslt(:,6) == 1);

% indicate data with reject codes
plot(imgNum(idx),vehSpd(idx),'r.');

% compute fraction of rejected data points
numReject = length(idx);
fracReject = numReject/length(vehSpd)*100;
fprintf('fraction of data rejected = %0.2f\n',fracReject);

% indicate data with low snr over ambiguities
% idx = find(   (rslt(:,15) > 40 | rslt(:,16) > 40) & rslt(:,17) < .5        );
% plot(imgNum(idx),vehSpd(idx),'g.')

ylabel('Vehicle Speed (m/s)');
xlabel('Image Number')
title(fname, 'Interpreter', 'none' ) 

    %rslt(step,:) = [step,deltPosPix,deltPosMeters,reject,snr_db,fracSat,fracBlk,normDiff,edgeLim,BLK,SAT,MSMTCH,deltPosAmbg,snrAmbg];

% figure(7), clf, hold on
% plot(rslt(:,1),rslt(:,11),'b.')
% plot(rslt(:,1),rslt(:,14),'g.')
% ylabel('reject codes');
% xlabel('Image Number')

figure(8), clf, hold on
plot(rslt(:,1),rslt(:,6),'b.')
plot(rslt(rslt(:,6) == 1,1),rslt(rslt(:,6) == 1,6),'r.')
ylabel('reject codes');
xlabel('Image Number')
title('Data Rejected')



