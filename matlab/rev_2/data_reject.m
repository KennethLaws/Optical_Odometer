
function [reject,fracSat,fracBlk,normDiff,TOP,BLK,SAT,MSMTCH] = data_reject(ypeak,xpeak,yPix,xPix,image_1,image_2,x1,y1,h,w)
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
    TOP = 0;
    BLK = 0;
    SAT = 0;
    MSMTCH = 0;

    if isnan(ypeak) 
        reject = 1;
        return;
    end
    
    template = image_1(y1:(y1+h-1),x1:x1+w-1); 
    template = template(:);
    n = length(template);

    % set limits
    sat = 254;
    satLim = .95;
    blk = 2;
    blkLim = .95;
    
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
    
        
    % check for solution at or past edge of reference image
    if (ypeak + h) >= yPix
        reject = 1;
        TOP = 1;
        return;
    else
        TOP = 0;
    end
    

    % check for a poor match between template and target
    target = image_2(ypeak:(ypeak+h-1),xpeak:xpeak+w-1);
    target = target(:);
    missMatchLim = 10000;
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