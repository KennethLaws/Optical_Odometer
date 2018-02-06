
function [ypeak, xpeak, c, max_c] = image_reg(yPix,xPix,image_2,image_1,x1,y1,h,w)
% Image registration function
% Uses inputs 
% xPix, yPix area of input images to process 
% image_1, image_2, input image data, gray scale, 8 bit
% x1, y1, lower left corner of target region
% h, w, height and width of target region
% Returns
% ypeak, xpeak, location of target on reference image (image_2)
% c, matrix of cross-correlation power spectrum
% max_c, maximum value (value at ypeak, xpeak) 


% apply a Han window
% image_1 = HanWindow2d(image_1);
% image_2 = HanWindow2d(image_2);


template = image_1(y1:(y1+h-1),x1:x1+w-1);

% template = HanWindow2d(template);

Ga = fft2(image_2,yPix,xPix);
Gb = fft2(template,yPix,xPix);
c = real(ifft2((Ga.*conj(Gb))./abs(Ga.*conj(Gb))));
c = abs(c);


% zero out edge regions to compensate for edge effects that cause
% anomolusly high error retrievals
c((yPix-h-1):end,:) = 0;
c(1:2,:) = 0;
c(:,1:2) = 0;
c(:,(xPix-w-1):end) = 0;

% normalize 
c = c - min(c(:));
c = c/max(c(:));


% find peak correlation
% xpeak and ypeak are the bottom left corner of the matched window

max_c = max(c(:));
if max_c < inf
    [ypeak, xpeak] = find(c == max_c);
    % avoid multiple identicle peak values
    xpeak = xpeak(1);
    ypeak = ypeak(1);
else
    ypeak = NaN;
    xpeak = NaN;
end

return