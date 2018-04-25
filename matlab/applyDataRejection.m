function adjTranslt = applyDataRejection(rslt)
% Project           :: Optical Odometer
% Author            :: Kenneth Laws
%                   :: Here Technologies
% Creation Date     :: 4/23/2017
% Modified          ::
%
% fills the gaps created by bad data rejection
%

% set maximum fraction of gaps in section to try and fill
maxGaps = 0.2; % max fraction

% apply bad data rejection
% set the rejected point dx and dy to NaN
rslt(rslt(:,6) == 1,2:3) = NaN;

dl = rslt(:,2);    % dy values (parallel to vehicle axis) pixels
d2 = rslt(:,3);    % dx value perp to vehicle pixels

adjTranslt = zeros(size(rslt(:,2:3)));

for idx = 2:3
    % dl values (2:parallel to vehicle axis, 3: perpendicular)
    dl = rslt(:,idx);
    
    % could do simple average between adjacent points (and probably should have)
    gapIdx = find(isnan(dl));
    fitSpan = 50;  % 150
    fitRng = floor(fitSpan/3);
    N = length(dl)/fitRng;
    N = floor(N);
    
    % fill gaps in the first region, here we might not be able to avoid
    % extrapolation
    startSpan = 1;
    endSpan = startSpan + floor(fitSpan/2)-1;
    fitPnts = startSpan:endSpan;
    fillPnts = 1:(fitRng);
    gapPnts = find(isnan(dl(fillPnts)));
    fitDl = dl(fitPnts);
    if ~isempty(gapPnts)
        gaps = fillPnts(gapPnts);
        if length(gapPnts)/length(fillPnts) > maxGaps
            dl(gaps) = NaN;
        else
            x = fitPnts(~isnan(fitDl));
            y = fitDl(~isnan(fitDl))';
            p = polyfit(x,y,2);
            y = polyval(p,x);
            dl(gaps) = polyval(p,gaps);
        end
    end
    
    
    % fill gaps for set of sections in middle of data where we can interpolate
    startSpan = 1;
    for nSpan = 1:N-2
        endSpan = startSpan + fitSpan-1;
        fitPnts = startSpan:endSpan;
        fillPnts = fitRng + ((startSpan:(startSpan+fitRng-1)));
        fitDl = dl(fitPnts);
        gapPnts = find(isnan(dl(fillPnts)));
        if ~isempty(gapPnts)
            gaps = fillPnts(gapPnts);
            if length(gapPnts)/length(fillPnts) > maxGaps
                dl(gaps) = NaN;
            else
                x = fitPnts(~isnan(fitDl));
                y = fitDl(~isnan(fitDl))';
                p = polyfit(x,y,2);
                y = polyval(p,x);
                dl(gaps) = polyval(p,gaps);
            end
        end
        startSpan = startSpan + fitRng;
    end
    
    % fill gaps in last section of data
    endSpan = length(dl);
    fitPnts = startSpan:endSpan;
    fillPnts = fitPnts;
    fitDl = dl(fitPnts);
    gapPnts = find(isnan(dl(fillPnts)));
    if ~isempty(gapPnts)
        gaps = fillPnts(gapPnts);
        if length(gapPnts)/length(fillPnts) > maxGaps
            dl(gaps) = NaN;
        else
            x = fitPnts(~isnan(fitDl));
            y = fitDl(~isnan(fitDl))';
            p = polyfit(x,y,2);
            y = polyval(p,x);
            dl(gaps) = polyval(p,gaps);
        end
    end
    
    adjTranslt(:,idx-1) = dl;
    
end


end