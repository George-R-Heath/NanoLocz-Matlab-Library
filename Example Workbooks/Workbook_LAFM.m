
clear
[img, ImageInfo] = ReadAFMFile('AqpZ_128.tif', 'Height');
load('AFM_luts_full.mat');
LAFM_thresh = 0;
pixperfeat = 1;

locs = [];
for i = 1:numel(img(1,1,:))
li = Fast_peaks2D(img(:,:,i), LAFM_thresh, 1);
li = [li, i*ones(numel(li(:,1)),1)];
locs = [locs; li];
end

locs = localize(img, locs, 'bicubic', pixperfeat);
LAFM_full = LAFM_renderer(locs, 2, 5, AFM_Gold, 0 ,[0.1 1],'Exc outliers' );

LAFM_plotter(LAFM_full)

[q, frc_mean, av_resolution, sd_resolution] = measureFRC(locs,10,20,5);