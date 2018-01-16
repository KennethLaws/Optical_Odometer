% plot_seqImg_rslt

function plot_seqImg_rslt(fname)

if nargin == 0
    fname = 'seq_image_rslt_101400.mat';
end

% rslt(step,:) = [step, deltPosPix, dy_inches, snr_db];
load(fname);

% % start and end image by image number
% img_start = 0;
% img_end = 141;
% rng = (img_start+1):(img_end+1);

%total_Y = sum(rslt(rng,4));
total_Y = sum(rslt(:,4));
fprintf('Total distance travelled, y = %0.4f m\n',total_Y);

timeStep = 10/1562;     % colelcted 1562 images per 10 sec
vehSpd = rslt(:,4)/timeStep;

figure(1), clf
%plot(rslt(rng,1),rslt(rng,4))
plot(rslt(:,1),vehSpd)
ylabel('Vehicle Speed (m/s)');
xlabel('Image Number')

figure(2), clf
plot(rslt(:,1),rslt(:,6))
ylabel('SNR (dB)');
xlabel('Image Number')


