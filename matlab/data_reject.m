
function [reject,fracSat,fracBlk,normDiff,edgeLim,BLK,SAT,MSMTCH,deltPosAmbg,rat] = data_reject(c,ypeak,xpeak, max_c,yPix,xPix,image_1,image_2,x1,y1,h,w)
% data rejection function
% Uses inputs 
% xPix, yPix area of input images to process 
% image_1, image_2, input image data, gray scale, 8 bit
% x1, y1, lower left corner of target region
% h, w, height and width of target region
% Returns a reject flag, 1 if rejected otherwise 0;
% fracBlk, fracktion of blck pixels in target
% fracSat, fraction of saturated pixels in region
% normDiff, mismatch parmeter value


    reject = 0; % default, data not rejected
    fracSat = 0;
    fracBlk = 0;
    normDiff = 0;
    edgeLim = 0;
    BLK = 0;
    SAT = 0;
    MSMTCH = 0;
    rat = NaN;
    deltPosAmbg = [NaN, NaN];

    if isnan(ypeak) 
        reject = 1;
        return;
    end
    
    template = image_1(y1:(y1+h-1),x1:x1+w-1); 
    template = template(:);
    n = length(template);

    % set limits
    sat = 254;
    satLim = .80;
    blk = 2;
    blkLim = .95;
    TOP = 1;
    EDGE = 2;
    BOTTOM = 3;
    expsrMin = 12;
    
    % set rejection codes
%     TOP = 1;        % target at top
%     BOT = 2;        % target at bottom
%     LFT = 3;        % target at left
%     RHT = 4;        % target at right
%     SAT = 5;        % template saturated
%     BLK = 6;        % template black
%     MSMTCH = 7;     % missmatch
    
    % check saturation
    fracSat = length(template(template>sat))/n;
    if fracSat > satLim 
        reject = 1;
        SAT = 1;
    else
        SAT = 0;
    end
    
    % check black
    fracBlk = length(template(template<blk))/n;
    if fracBlk > blkLim
        reject = 1;
        BLK = 1;
    else
        BLK = 0;
    end
    
    % check underexposed, for now use the same code as black to flag
    expsr = mean(template);
    if expsr < expsrMin
        reject = 1;
        BLK = 1;
    else
        BLK = 0;
    end
    
        
    % check for solution at or past edge of reference image
%     if (ypeak + h) >= yPix
%         reject = 1;
%         edgeLim = TOP;
%         return;
%     elseif (xpeak <= 1) || ((xpeak+w-1) >= xPix)
%         reject = 1;
%         edgeLim = EDGE;
%         return;
%     elseif ypeak <= 1
%         reject = 1;
%         edgeLim = BOTTOM;
%         return;
%     else   
%         edgeLim = 0;
%     end
    edgeLim = 0;
    
    % process ambiguity snr rejection
    minAmbgRat = 1.5;   % minimum limit ratio over next ambiguity
    if max_c == 1       % since c is normalized, if max != 1 there was no peak

        % clear the region around the solution peak
        [ypeak, xpeak] = find(c == max(c(:)));
        ypeak = ypeak(1);
        xpeak = xpeak(1);
        c(ypeak-2:ypeak+2,xpeak-2:xpeak+2) = 0;

    %     figure(10)
    %     pcolor(c(ypeak-20:ypeak+20,xpeak-20:xpeak+20))

        %find the highest ambiguity peak
        s = c(:);    
        [ypeakAmbg, xpeakAmbg] = find(c == max(c(:)));
        ypeakAmbg = ypeakAmbg(1);
        xpeakAmbg = xpeakAmbg(1);

        deltPosAmbg = [ypeak-ypeakAmbg,xpeak-xpeakAmbg];
        rat = max_c/max(s);

        if rat < minAmbgRat, reject = 1; end
    else
        rat = NaN;
        deltPosAmbg = [NaN, NaN];
    end

    % check for a poor match between template and target
    target = image_2(ypeak:(ypeak+h-1),xpeak:xpeak+w-1);
    target = target(:);
    missMatchLim = 100000;
    normTrg = target - mean(target);
    normTrg = normTrg/max(normTrg);
    normTmplt = template - mean(template);
    normTmplt = normTmplt/max(normTmplt);
    normDiff = sum(abs(normTrg-normTmplt));
    
    if normDiff > missMatchLim
        reject = 1;
        MSMTCH = 1;
    else
        MSMTCH = 0;
    end
    


return