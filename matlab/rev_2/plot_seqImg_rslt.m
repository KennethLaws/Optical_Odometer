
function plot_seqImg_rslt(fname)
% plot_seqImg_rslt



if nargin == 0
    fname = 'seq_image_rslt_101400.mat';
end

% rslt(step,:) = [step, deltPosPix, dy_inches, snr_db];
load(fname);

% % start and end image by image number
% img_start = 0;
% img_end = 141;
% rng = (img_start+1):(img_end+1);

%total_Y = sum(rslt(rng,4));
total_Y = sum(rslt(:,4));
fprintf('Total distance travelled, y = %0.4f m\n',total_Y);

timeStep = 10/1562;     % colelcted 1562 images per 10 sec
vehSpd = rslt(:,4)/timeStep;

figure(3), clf
plot(rslt(:,1),rslt(:,2))
ylabel('Position Shift (pix)');
xlabel('Image Number')

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
goodRslt = rslt;
goodRslt(rslt(:,6) == 1,4) = NaN;


% recalculate speed
vehSpd = goodRslt(:,4)/timeStep;

% fill gaps
minGood = 5;    % minimum number of good points between gaps to do interpolationusing curve fit
goodFactor = 3;  % to do curve fitting, number of adjacent good data must be 3x size of gap
gapIdx = find(isnan(vehSpd));
gapDif = diff(gapIdx);
gapSet = find(gapDif >1);

startGapIdx = 1;
for n = 1: length(gapSet)
    gapDifIdx = gapSet(n);
    startGap = gapIdx(startGapIdx);
    endGap = gapIdx(gapDifIdx);
    gapSize = endGap-startGap;
    if (startGap-minGood > 0) & (endGap+minGood <= length(vehSpd))
        % can fill gap
        span = (startGap-gapSize*3):(endGap+minGood);

    end
end

figure(6), clf
plot(goodRslt(:,1),vehSpd)
ylabel('Vehicle Speed (m/s)');
xlabel('Image Number')
title(fname, 'Interpreter', 'none' ) 



