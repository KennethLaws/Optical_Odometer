% plot_seqImg_rslt
clear;

fname = 'seq_image_rslt';
% rslt(step,:) = [step, deltPosPix, dy_inches, snr_db];
load(fname);

figure(1), clf
plot(rslt(:,1),rslt(:,4))