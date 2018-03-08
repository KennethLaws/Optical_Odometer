% function to estimate the distance between two points in the image frame
% using linear calibration

function deltMeters = compDY(deltPix,p)
deltMeters = polyval(p,deltPix);
end


