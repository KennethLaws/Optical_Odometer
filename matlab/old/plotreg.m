%plotrg
% plot registration marks at the lower left corner of the subframe

function plotreg(x,y,fignum)
figure(fignum);
plot([x-100,x],[y, y],'k');
plot([x, x],[y-100, y],'k');
return;
