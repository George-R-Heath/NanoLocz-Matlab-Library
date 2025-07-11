%% Load, stack and process AFM images from two time-lapse files using the phase channel for masking

% Paths to the two AFM image data files (change to your file locations)
image_name1 = 'folder1/subfolder/data/filename1';
image_name2 = 'folder1/subfolder/data/filename2';

% Define the AFM channels to be read from the data files
channel1 = 'Lock-In Phase -Trace';  % Lock-In Phase channel for phase info
channel2 = 'Height -Trace';          % Height channel for topography

%% Read Lock-In Phase images from both files

[im1, ~] = ReadAFMFile(image_name1, channel1);
[im2, ~] = ReadAFMFile(image_name2, channel1);

% Concatenate phase images along the 3rd dimension (stack)
Img_phase = cat(3, im1, im2);

% Threshold phase images to generate a mask for weighted leveling
% Using 'otsu edges' method for automatic edge detection threshold
imgt = thresholder(Img_phase, 'otsu edges', [], 0);

%% Read Height images from both files

[im1, ImageInfo1] = ReadAFMFile(image_name1, channel2);
[im2, ImageInfo2] = ReadAFMFile(image_name2, channel2);

% Concatenate height images to form a stack
Img = cat(3, im1, im2);

%% Level each height image in the stack using weighted leveling techniques

for i = 1:size(Img,3)
    % Apply plane leveling weighted by the threshold mask (imgt)
    r(:,:,i) = level_weighted(Img(:,:,i), 1, 1, 'plane', imgt(:,:,i));
    
    % Apply median line leveling weighted by the threshold mask
    r(:,:,i) = level_weighted(r(:,:,i), 0, 0, 'med_line', imgt(:,:,i));
    
    % Repeat plane leveling to improve flattening
    r(:,:,i) = level_weighted(r(:,:,i), 1, 1, 'plane', imgt(:,:,i));
    
    % Repeat median line leveling for fine correction
    r(:,:,i) = level_weighted(r(:,:,i), 0, 0, 'med_line', imgt(:,:,i));
    
    % Final global mean plane leveling (no weighting)
    r(:,:,i) = level(r(:,:,i), 0, 0, 'mean_plane');
end

%% Prepare output structure to store processed data and metadata

[~, name, ext] = fileparts(image_name1); % Extract base file name from first image file

Data.ImageName = name;         % Store image base name
Data.Channel = channel2;       % Store channel name (height)
Data.Imagedata = r;            % Store leveled image stack

% Combine metadata from both image files
Data.ImageInfo = ImageInfo1;
Data.ImageInfo.n = ImageInfo1.n + ImageInfo2.n;              % Total number of images (frames)
ImageInfo2.time = ImageInfo2.time + ImageInfo1.time(end);   % Adjust time vector for second file
Data.ImageInfo.time = [ImageInfo1.time, ImageInfo2.time];    % Concatenate time info
Data.ImageInfo.ScanSize = [ImageInfo1.ScanSize, ImageInfo2.ScanSize];    % Concatenate scan sizes
Data.ImageInfo.PixelPerNm = [ImageInfo1.PixelPerNm, ImageInfo2.PixelPerNm]; % Concatenate pixel sizes

% Initialize empty fields for locations and references (if used later)
Data.ImageLocs = [];
Data.ref = [];
