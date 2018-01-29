
function plot_seqImg_rslt(fname)
% plot_seqImg_rslt



if nargin == 0
    fname = 'seq_image_rslt_Drive_1214.mat';
end

% set name to save or read filtered data set
filterName = ['filter_',fname];

% load in the raw sequential image processed data
load(fname);

% % start and end image by image number
% img_start = 0;
% img_end = 141;
% rng = (img_start+1):(img_end+1);

%total_Y = sum(rslt(rng,4));
total_Y = sum(rslt(:,4));
fprintf('Total distance travelled, y = %0.4f m\n',total_Y);

timeStep = 10/1562;     % colelcted 1562 images per 10 sec
vehSpd = (rslt(:,4)/timeStep)';
imgNum = rslt(:,1)';
dataGaps = imgNum(rslt(:,6) == 1);

figure(4), clf
plot(rslt(:,1),vehSpd)
ylabel('Vehicle Speed (m/s)');
xlabel('Image Number')
title(fname, 'Interpreter', 'none' ) 

figure(5), clf
plot(rslt(:,1),rslt(:,7))
ylabel('SNR (dB)');
xlabel('Image Number')

% apply bad data rejection
rslt(rslt(:,6) == 1,4) = NaN;
vehSpd(rslt(:,6) == 1) = NaN;


% either load filtered data or filter the raw data to reject bad points ad
% fill with interpolated data points
if ~exist(filterName)
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
    save(filterName,'vehSpd');
end

load(filterName,'vehSpd');

figure(6), clf, hold on
plot(imgNum,vehSpd,'b-')
plot(imgNum,vehSpd,'b.')
idx = find(rslt(:,6) == 1);
plot(imgNum(idx),vehSpd(idx),'r.');
ylabel('Vehicle Speed (m/s)');
xlabel('Image Number')
title(fname, 'Interpreter', 'none' ) 

figure(3), clf, hold on
plot(rslt(:,1),rslt(:,11),'b.')
plot(rslt(:,1),rslt(:,14),'g.')
ylabel('reject codes');
xlabel('Image Number')



