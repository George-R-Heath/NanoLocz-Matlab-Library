 
[im, ImageInfo] = ReadAFMFile('Rotate test.tif', 'Height');
d = im;
ccr_thresh = 0.8;   
filt_ccr = 1;     %CCR cut off to remove worst particles 
filt_img = 1;     %filtering
ex_edge = 0;
angles = -40:10:40;
fastdetect = 1;

%%
ref = ref_selector(d);
[locs] = Detector(im, 'ccr', ref, filt_img, filt_ccr, ccr_thresh, ex_edge, fastdetect, angles);
Part.Locs = locs;
Part.Image = ref;
Part.Image  = ConstructParticleStack(d, Part,1);
[Part, ref2] = align_iterate(d,ref,Part, 2,'FFT cross',10, 2,'Rotation corr', 10, 0,1);

viewstack(Part.Image)

figure(2)
imagesc(im)
hold on
plot(Part.Locs(:,1),Part.Locs(:,2),'kx')