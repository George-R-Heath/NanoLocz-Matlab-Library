%% NanoLocz-lib Workbook - Automatic line profiling for width/height analysis

% This example demonstrates how to:
% - Load an AFM image
% - Apply background leveling
% - Detect peaks (particles) 
% - Measure particle sizes with automatic line profiling

[im, ImageInfo] = ReadAFMFile('0.0_00003.spm','Height');  % Read AFM file (Bruker .spm format) and extract Height data
im2 = level_auto(im,1,'iterative fit peaks');  % Apply automated leveling using iterative peak-fitting method
im3 = scar_fill(im2, 0.05, 0.5, 3); % Apply scar fill to remove thin horizontal scars/artifacts
im3 = imgaussfilt(im3, 2);  % Apply Gaussian smoothing to reduce noise

thresh = 2;          % Minimum height threshold (nm)
kernel_size = 5;     % Local neighbourhood size (pixels)
locs = Fast_peaks2D(im3, thresh, kernel_size);   % Run peak detection

directions = [1, 1, 1, 1];  % enable all directions
max_radius = 50;
widthRef = 'z = 0';
[Rmin, Rmax, Rmean, p] = Lineprofiler(im3, locs(:,1:2), max_radius, directions, widthRef); % Run Auto Profile for width analysis

%% Plot Width and Height Distributions
widths = Rmean;
heights = locs(:,3);

% Plot Width Distribution
figure;
histogram(widths, 20, 'FaceColor', [0.2, 0.4, 0.6], 'EdgeColor', 'k');
xlabel('Width (nm)');
ylabel('Count');
title('Particle Width Distribution');
grid on;

% Plot Height Distribution
figure;
histogram(heights, 20, 'FaceColor', [0.8, 0.4, 0.2], 'EdgeColor', 'k');
xlabel('Height (nm)');
ylabel('Count');
title('Particle Height Distribution');
grid on;

figure;
plot(widths,heights,'o')
xlabel('Width (nm)');
ylabel('Height (nm)');
title('Particle Width Height Distribution');
grid on;