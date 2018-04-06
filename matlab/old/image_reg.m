% register the position of a subframe on a reference image

function [ypeak, xpeak, c, max_c] = image_reg(yPix,xPix,background,template)



Ga = fft2(background,yPix,xPix);
Gb = fft2(template,yPix,xPix);
c = real(ifft2((Ga.*conj(Gb))./abs(Ga.*conj(Gb))));

% find peak correlation
% xpeak and ypeak are the bottom left corner of the matched window

max_c = max(abs(c(:)));
[ypeak, xpeak] = find(c == max(c(:)));

return