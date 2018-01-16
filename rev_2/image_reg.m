% register the position of a subframe on a reference image

% old function
% function [ypeak, xpeak, c, max_c] = image_reg(yPix,xPix,background,template)
% 
% %     template = image_1(y1:(y1+h-1),x1:x1+w-1); 
% 
% 
% Ga = fft2(background,yPix,xPix);
% Gb = fft2(template,yPix,xPix);
% c = real(ifft2((Ga.*conj(Gb))./abs(Ga.*conj(Gb))));
% 
% % find peak correlation
% % xpeak and ypeak are the bottom left corner of the matched window
% 
% max_c = max(abs(c(:)));
% [ypeak, xpeak] = find(c == max(c(:)));
% 
% return

function [ypeak, xpeak, c, max_c] = image_reg(yPix,xPix,image_2,image_1,x1,y1,h,w)

template = image_1(y1:(y1+h-1),x1:x1+w-1); 


Ga = fft2(image_2,yPix,xPix);
Gb = fft2(template,yPix,xPix);
c = real(ifft2((Ga.*conj(Gb))./abs(Ga.*conj(Gb))));

% find peak correlation
% xpeak and ypeak are the bottom left corner of the matched window

max_c = max(abs(c(:)));
if max_c < inf
    [ypeak, xpeak] = find(c == max(c(:)));
else
    ypeak = NaN;
    xpeak = NaN;
end

return