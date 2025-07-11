%% Localization AFM Map Generation

% This code assumes the starting point is a aligned 3D stack of images
% To detect particle and perform alignment see the Particle_detect Workbook

[im, ImageInfo] = ReadAFMFile('0375 spi_sim 0375.tiff'); % Loading example data 
load('AFM_luts_full.mat');   %colormap for LAFM rendering

LAFM_thresh = 0.5;       % Peak detection threshold
pixperfeat = 1;          % Pixels per feature for localization
im2 = filter_movie(im, 'Gaussian', 0.2, 'Laplacian', 50); %Apply Filtering to reduce noise/enhance Features

%Detect Peaks in Each Frame
locs = [];
for i = 1:numel(im2(1,1,:))
    li = Fast_peaks2D(im2(:,:,i), LAFM_thresh, 1);
    li = [li, i * ones(numel(li(:,1)),1)]; % Append frame index
    locs = [locs; li];
end

locs = localize(im2, locs, 'bicubic', pixperfeat);  %Refine Peak Localizations


render_point_sz = 1;
render_image_expansion = 5;
LAFM_full = LAFM_renderer(locs, render_point_sz, render_image_expansion, Rainbow, 0, [], 'Exc outliers'); % Render the Localized AFM Map (LAFM)
LAFM_plotter(LAFM_full); % Display the LAFM Map

% Measure Resolution using Fourier Ring Correlation (FRC)
pixpernm = 1;
runs = 20;
[q, frc_mean, av_resolution, sd_resolution] = measureFRC(locs, pixpernm, runs, render_image_expansion);
fprintf('Average Resolution: %.2f nm\n', av_resolution);
fprintf('Resolution SD: %.2f nm\n', sd_resolution);