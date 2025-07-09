
image_name1 = '/Users/fbsgh/Library/CloudStorage/OneDrive-UniversityofLeeds/_PAPERS/TMSD paper/Movies_and_jpkdata_for_TMSD_MS/Movie_4/imaging-21.53.25.263';
image_name2 = '/Users/fbsgh/Library/CloudStorage/OneDrive-UniversityofLeeds/_PAPERS/TMSD paper/Movies_and_jpkdata_for_TMSD_MS/Movie_4/imaging-22.01.13.928';

channel1 = 'Lock-In Phase -Trace';
channel2 = 'Height -Trace';

[im1, ImageInfo1] = ReadAFMFile(image_name1, channel1);
[im2, ImageInfo2] = ReadAFMFile(image_name2, channel1);

Img_phase = cat(3, im1, im2);

imgt = thresholder(Img_phase, 'otsu edges',[],0);

[im1, ImageInfo1] = ReadAFMFile(image_name1, channel2);
[im2, ImageInfo2] = ReadAFMFile(image_name2, channel2);

Img = cat(3, im1, im2);
for i = 1:size(Img,3)
    r(:,:,i) = level_weighted(Img(:,:,i), 1, 1, 'plane', imgt(:,:,i));
    r(:,:,i) = level_weighted(r(:,:,i), 0, 0, 'med_line', imgt(:,:,i));
    r(:,:,i) = level_weighted(r(:,:,i), 1, 1, 'plane', imgt(:,:,i));
    r(:,:,i) = level_weighted(r(:,:,i), 0, 0, 'med_line', imgt(:,:,i));
    r(:,:,i) = level(r(:,:,i),0,0,'mean_plane');
end

[~, name, ext] = fileparts(image_name1);
Data.ImageName = name;
Data.Channel = channel2;
Data.Imagedata = r;
Data.ImageInfo = ImageInfo1;
Data.ImageInfo.n = ImageInfo1.n + ImageInfo2.n;
ImageInfo2.time = ImageInfo2.time+ImageInfo1.time(end);
Data.ImageInfo.time = [ImageInfo1.time,ImageInfo2.time];
Data.ImageInfo.ScanSize = [ImageInfo1.ScanSize,ImageInfo2.ScanSize];
Data.ImageInfo.PixelPerNm = [ImageInfo1.PixelPerNm,ImageInfo2.PixelPerNm];
Data.ImageLocs =[];
Data.ref =[];

