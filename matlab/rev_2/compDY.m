% function to estimate the distance between two points in the image frame
% using numerical integration and function obtained from calibration data

function DY = compDY(yref,ypos,p)
y = ypos-yref;
DY = polyval(p,y);
% convert from cm to m
DY = DY/100;


