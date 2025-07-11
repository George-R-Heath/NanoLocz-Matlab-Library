%% AFM Particle Detection and Alignment Walkthrough
% This script demonstrates the steps of detecting and aligning particles
% in an AFM image using cross-correlation and rotational correction methods.

% Read and prepare the AFM image
[im, ImageInfo] = ReadAFMFile('Rotate test.tif', 'Height');  % Load AFM image and metadata
d = im;  % Assign image to variable 'd' for later use

% Select reference particle manually from the image
ref = ref_selector(d);  % User clicks to select a reference particle and then hit enter

% Detect particles in the image using the reference
% Set parameters for particle detection and filtering
ccr_thresh = 0.8;    % Cross-correlation threshold: higher values = stricter match to reference
filt_img = 1;        % Gaussian filtering strength on image
filt_ccr = 1;        % Gaussian filtering strength on cross-correlation image
ex_edge = 0;         % Exclude particles near image edge? (1 = yes, 0 = no)
angles = -40:10:40;  % Angles (in degrees) to rotate reference for rotational matching
fastdetect = 1;      % Enable fast detection (1 = on, 0 = off)
[locs] = Detector(im, 'ccr', ref, filt_img, filt_ccr, ccr_thresh, ex_edge, fastdetect, angles);

% Store detection results in structure
Part.Locs = locs;       % Store particle locations (x, y)
Part.Image = ref;       % Store reference particle image

% Build a stack of detected particles
Part.Image = ConstructParticleStack(d, Part, 1);  % Stack particles into single 3D array (x, y, particle index)

% Align particles using iterative alignment with FFT cross-correlation and rotational correction
trans_iter = 2;
search_win = 10; %pixels
rotational_iter = 2;
rot_search_win = 10; %degrees
[Part, ref2] = align_iterate(d, ref, Part, ...
    trans_iter, 'FFT cross', search_win, ...      
    rotational_iter, 'Rotation corr', rot_search_win, ...  
    0, 1);                    

% View the aligned particle stack
viewstack(Part.Image)

% Plot detected particle locations over original image
figure(2)
imagesc(im)  % Display original AFM image
hold on
plot(Part.Locs(:,1), Part.Locs(:,2), 'kx')  % Overlay particle locations as black 'x' markers
