%% Batch Processing AFM Images with NanoLocz

% Set input and output directories
dataFolder = 'path/to/your/AFM/images';       % <-- USER UPDATE this
outputDir = 'path/to/save/output/images';     % <-- USER UPDATE this

imageFiles = dir(data_folder);
imageFiles = imageFiles(~ismember({imageFiles(:).name},{'.','..','.DS_Store'}));
fileList = {imageFiles.name};
count =0;
for i = 1:numel(fileList)
    fileName = [data_folder '/'  fileList{i}];
    [~, ~, ext] = fileparts(fileName);
    if ~strcmpi(ext, '.mat') %skip processed mat files
        try
        %Read files
        [im{i-count}, imageinfo{i-count}] = ReadAFMFile(fileName);
         
        %Auto level images
        im_lev{i-count} = level_auto(im{i-count},1:numel(im{i-count}(1,1,:)),'multi-plane-otsu');

        %Output to png/gif
        [~, name, ~] = fileparts(fileList{i});
        name = strrep(name, '.', '_');
        outputPath = fullfile(outputDir, name);
        CreateGif(im_lev{i-count}, outputPath, imageinfo{i-count}, true);

        %Output to tiff
        outputPath = fullfile(outputDir, [name, '.tiff']);
        exporter(im_lev{i-count}, '.tiff', outputPath)

        catch ME
        warning(['⚠️  Failed to process: ', fileNames{i}, ' — ', ME.message]);
        end
    else
        count = count+1;
    end
end