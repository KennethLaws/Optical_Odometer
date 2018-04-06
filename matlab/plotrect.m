% function plot rectangle
function plotrect(x,y,w,h,fignum)

figure(fignum);

% plot the rectangle
plot([x,x+w],[y y],'r');
plot([x,x],[y y+h],'r');
plot([x,x+w],[y+h y+h],'r');
plot([x+w,x+w],[y y+h],'r');

return;


