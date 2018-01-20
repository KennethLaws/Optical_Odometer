
function [reject,fracSat,fracBlk,normDiff] = data_reject(ypeak,xpeak,yPix,xPix,image_1,image_2,x1,y1,h,w)
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

    reject = 0;
    
    template = image_1(y1:(y1+h-1),x1:x1+w-1); 
    template = template(:);
    target = image_2(ypeak:(ypeak+h-1),xpeak:xpeak+w-1);
    target = target(:);

    % check for target region saturated or black
    sat = 254;
    blk = 2;
    satLim = .95;
    blkLim = .95;
    top = 1;
    bottom = 2;
    left = 3;
    right = 4;
    
    
    n = length(template(:));
    fracSat = length(template(template>sat))/n;
    fracBlk = length(template(template<blk))/n;
    if fracSat > satLim || fracBlk > blkLim
        reject = 1;
    end

    % check for solution at or past edge of reference image
    if (ypeak + h) >= yPix
        edge = top;
        reject = 1;
    else
        edge = 0;
    end
    
    % check for a poor match between template and target
    missMatchLim = 10000;
    normTrg = target - mean(target);
    normTrg = normTrg/max(normTrg);
    normTmplt = template - mean(template);
    normTmplt = normTmplt/max(normTmplt);
    normDiff = sum(abs(normTrg-normTmplt));
    
    if normDiff > missMatchLim
        reject = 1;
    end


return