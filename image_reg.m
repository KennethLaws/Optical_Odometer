% register the position of a subframe on a reference image

function [ypeak, xpeak, c, max_c] = image_reg(by,bx,background,template)

Ga = fft2(background);
Gb = fft2(template, by, bx);
c = real(ifft2((Ga.*conj(Gb))./abs(Ga.*conj(Gb))));

% find peak correlation
% xpeak and ypeak are the bottom left corner of the matched window

[max_c, imax]   = max(abs(c(:)));
[ypeak, xpeak] = find(c == max(c(:)));

return