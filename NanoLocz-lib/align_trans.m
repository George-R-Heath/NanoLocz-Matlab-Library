% Function written for NanoLocz-lib 2025 
% DESCRIPTION: 
%   Calculates translational shifts between an image stack and a reference
%   image using either spatial cross-correlation or frequency domain
%   cross-correlation (FFT-based). Supports optional sub-pixel alignment.
%
% USAGE:
%   [x, y] = align_trans(img, ref, pixel_shift, sub_pix, method)
%
% INPUTS:
%   img         - 3D image stack (height, width, frames)
%   ref         - 2D reference image
%   pixel_shift - Maximum pixel shift allowed for local alignment (positive integer)
%   sub_pix     - Sub-pixel refinement flag (1 = enabled, 0 = disabled)
%   method      - Alignment method: 'Cross corr' or 'FFT cross'
%
% OUTPUTS:
%   x           - Array of x shifts (in pixels) for each frame
%   y           - Array of y shifts (in pixels) for each frame

function [x,y] = align_trans(img, ref, pixel_shift, sub_pix, method)

sz = size(img);
img(isnan(img)) = 0;
window = round(pixel_shift);
FAn =fft2(ref);
n = sz(3);
refimg = ref;
for i = 1:n

    switch method
        case 'Cross corr'

            ccr = normxcorr2(refimg, img(:,:,i));
            ccr_sz = size(ccr);
            %
            % if filt_cr>0
            %     ccr = imgaussfilt(ccr , filt_cr);
            % end
            [~,imax] = max(abs(ccr(:)));
            [y(i),x(i)] = ind2sub(size(ccr),imax(1));

            if pixel_shift>0 && i >1
                if (y(i-1)-window+1)>0 && (y(i-1)+window-1)< ccr_sz(1) && (x(i-1)-window+1) > 0 && x(i-1)+window-1 < ccr_sz(2)
                    ccr_p  = ccr(y(i-1)-window+1:y(i-1)+window-1,x(i-1)-window+1:x(i-1)+window-1);
                    [~,imax] = max(abs(ccr_p(:)));
                    [yw(i),xw(i)] = ind2sub(size(ccr_p),imax(1));  %find position of max cross correlation

                    xw(i) = xw(i) - window;
                    yw(i) = yw(i) - window;

                    x(i) = x(1) + sum(xw(1:i));
                    y(i) = y(1) + sum(yw(1:i));
                    try
                        if sub_pix == 1
                            c_wind = 3;
                            clip_c = ccr(y(i)-c_wind+1:y(i)+c_wind-1,x(i)-c_wind+1:x(i)+c_wind-1);
                            c_zoom = imresize(clip_c, 100, 'bicubic');

                            [~,imax] = max(abs(c_zoom(:)));
                            [ypeak2,xpeak2] = ind2sub(size(c_zoom),imax(1));
                            ypeak2 = ypeak2-1;
                            xpeak2 = xpeak2-1;
                            x_offset_2(i) = (xpeak2-size(c_zoom,2)/2)/100;
                            y_offset_2(i) = (ypeak2-size(c_zoom,1)/2)/100;
                        else
                            x_offset_2(i) = 0;
                            y_offset_2(i) = 0;
                        end
                    catch
                        x_offset_2(i) = 0;
                        y_offset_2(i) = 0;
                    end

                else
                end
            end

            if i ==1 || pixel_shift == 0
                if sub_pix == 1
                    c_wind = 3;
                    clip_c = ccr(y(i)-c_wind+1:y(i)+c_wind-1,x(i)-c_wind+1:x(i)+c_wind-1);
                    c_zoom = imresize(clip_c, 100, 'bilinear');
                    [~,imax] = max(abs(c_zoom(:)));
                    [ypeak2,xpeak2] = ind2sub(size(c_zoom),imax(1));
                    ypeak2 = ypeak2-1;
                    xpeak2 = xpeak2-1;
                    x_offset_2(i) = (xpeak2-size(c_zoom,2)/2)/100;
                    y_offset_2(i) = (ypeak2-size(c_zoom,1)/2)/100;
                else
                    x_offset_2(i) = 0;
                    y_offset_2(i) = 0;
                end
            else
            end

        case 'FFT cross'

            FBn =fft2(img(:,:,i));
            [output, Greg] = dftregistration(FAn, FBn, 100);

            x(i) = -output(4);
            y(i) = -output(3);
    end

end

switch method
    case 'Cross corr'
        x = x' + x_offset_2(:)-sz(2);
        y = y' + y_offset_2(:)-sz(1);
    case 'FFT cross'
        x = x';
        y=y';
end


function [output, Greg] = dftregistration(buf1ft,buf2ft,usfac)
% function [output Greg] = dftregistration(buf1ft,buf2ft,usfac);
% Efficient subpixel image registration by crosscorrelation. This code
% gives the same precision as the FFT upsampled cross correlation in a
% small fraction of the computation time and with reduced memory
% requirements. It obtains an initial estimate of the crosscorrelation peak
% by an FFT and then refines the shift estimation by upsampling the DFT
% only in a small neighborhood of that estimate by means of a
% matrix-multiply DFT. With this procedure all the image points are used to
% compute the upsampled crosscorrelation.
% Manuel Guizar - Dec 13, 2007
%
% Rewrote all code not authored by either Manuel Guizar or Jim Fienup
% Manuel Guizar - May 13, 2016
%
% Citation for this algorithm:
% Manuel Guizar-Sicairos, Samuel T. Thurman, and James R. Fienup,
% "Efficient subpixel image registration algorithms," Opt. Lett. 33,
% 156-158 (2008).
%
% Inputs
% buf1ft    Fourier transform of reference image,
%           DC in (1,1)   [DO NOT FFTSHIFT]
% buf2ft    Fourier transform of image to register,
%           DC in (1,1) [DO NOT FFTSHIFT]
% usfac     Upsampling factor (integer). Images will be registered to
%           within 1/usfac of a pixel. For example usfac = 20 means the
%           images will be registered within 1/20 of a pixel. (default = 1)
%
% Outputs
% output =  [error,diffphase,net_row_shift,net_col_shift]
% error     Translation invariant normalized RMS error between f and g
% diffphase     Global phase difference between the two images (should be
%               zero if images are non-negative).
% net_row_shift net_col_shift   Pixel shifts between images
% Greg      (Optional) Fourier transform of registered version of buf2ft,
%           the global phase difference is compensated for.
%
%
% Copyright (c) 2016, Manuel Guizar Sicairos, James R. Fienup, University of Rochester
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
%     * Neither the name of the University of Rochester nor the names
%       of its contributors may be used to endorse or promote products derived
%       from this software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
if ~exist('usfac','var')
    usfac = 1;
end
[nr,nc]=size(buf2ft);
Nr = ifftshift(-fix(nr/2):ceil(nr/2)-1);
Nc = ifftshift(-fix(nc/2):ceil(nc/2)-1);
if usfac == 0
    % Simple computation of error and phase difference without registration
    CCmax = sum(buf1ft(:).*conj(buf2ft(:)));
    row_shift = 0;
    col_shift = 0;
elseif usfac == 1
    % Single pixel registration
    CC = ifft2(buf1ft.*conj(buf2ft));
    CCabs = abs(CC);
    [row_shift, col_shift] = find(CCabs == max(CCabs(:)));
    CCmax = CC(row_shift,col_shift)*nr*nc;
    % Now change shifts so that they represent relative shifts and not indices
    row_shift = Nr(row_shift);
    col_shift = Nc(col_shift);
elseif usfac > 1
    % Start with usfac == 2
    CC = ifft2(FTpad(buf1ft.*conj(buf2ft),[2*nr,2*nc]));
    CCabs = abs(CC);
    [row_shift, col_shift] = find(CCabs == max(CCabs(:)),1,'first');
    CCmax = CC(row_shift,col_shift)*nr*nc;
    % Now change shifts so that they represent relative shifts and not indices
    Nr2 = ifftshift(-fix(nr):ceil(nr)-1);
    Nc2 = ifftshift(-fix(nc):ceil(nc)-1);
    row_shift = Nr2(row_shift)/2;
    col_shift = Nc2(col_shift)/2;
    % If upsampling > 2, then refine estimate with matrix multiply DFT
    if usfac > 2,
        %%% DFT computation %%%
        % Initial shift estimate in upsampled grid
        row_shift = round(row_shift*usfac)/usfac;
        col_shift = round(col_shift*usfac)/usfac;
        dftshift = fix(ceil(usfac*1.5)/2); %% Center of output array at dftshift+1
        % Matrix multiply DFT around the current shift estimate
        CC = conj(dftups(buf2ft.*conj(buf1ft),ceil(usfac*1.5),ceil(usfac*1.5),usfac,...
            dftshift-row_shift*usfac,dftshift-col_shift*usfac));
        % Locate maximum and map back to original pixel grid
        CCabs = abs(CC);
        [rloc, cloc] = find(CCabs == max(CCabs(:)),1,'first');
        CCmax = CC(rloc,cloc);
        rloc = rloc - dftshift - 1;
        cloc = cloc - dftshift - 1;
        row_shift = row_shift + rloc/usfac;
        col_shift = col_shift + cloc/usfac;
    end
    % If its only one row or column the shift along that dimension has no
    % effect. Set to zero.
    if nr == 1,
        row_shift = 0;
    end
    if nc == 1,
        col_shift = 0;
    end

end
rg00 = sum(abs(buf1ft(:)).^2);
rf00 = sum(abs(buf2ft(:)).^2);
error = 1.0 - abs(CCmax).^2/(rg00*rf00);
error = sqrt(abs(error));
diffphase = angle(CCmax);
output=[error,diffphase,row_shift,col_shift];
% Compute registered version of buf2ft
if (nargout > 1)&&(usfac > 0),
    [Nc,Nr] = meshgrid(Nc,Nr);
    Greg = buf2ft.*exp(1i*2*pi*(-row_shift*Nr/nr-col_shift*Nc/nc));
    Greg = Greg*exp(1i*diffphase);
elseif (nargout > 1)&&(usfac == 0)
    Greg = buf2ft*exp(1i*diffphase);
end
return
function out=dftups(in,nor,noc,usfac,roff,coff)
% function out=dftups(in,nor,noc,usfac,roff,coff);
% Upsampled DFT by matrix multiplies, can compute an upsampled DFT in just
% a small region.
% usfac         Upsampling factor (default usfac = 1)
% [nor,noc]     Number of pixels in the output upsampled DFT, in
%               units of upsampled pixels (default = size(in))
% roff, coff    Row and column offsets, allow to shift the output array to
%               a region of interest on the DFT (default = 0)
% Recieves DC in upper left corner, image center must be in (1,1)
% Manuel Guizar - Dec 13, 2007
% Modified from dftus, by J.R. Fienup 7/31/06
% This code is intended to provide the same result as if the following
% operations were performed
%   - Embed the array "in" in an array that is usfac times larger in each
%     dimension. ifftshift to bring the center of the image to (1,1).
%   - Take the FFT of the larger array
%   - Extract an [nor, noc] region of the result. Starting with the
%     [roff+1 coff+1] element.
% It achieves this result by computing the DFT in the output array without
% the need to zeropad. Much faster and memory efficient than the
% zero-padded FFT approach if [nor noc] are much smaller than [nr*usfac nc*usfac]
[nr,nc]=size(in);
% Set defaults
if exist('roff', 'var')~=1, roff=0;  end
if exist('coff', 'var')~=1, coff=0;  end
if exist('usfac','var')~=1, usfac=1; end
if exist('noc',  'var')~=1, noc=nc;  end
if exist('nor',  'var')~=1, nor=nr;  end
% Compute kernels and obtain DFT by matrix products
kernc=exp((-1i*2*pi/(nc*usfac))*( ifftshift(0:nc-1).' - floor(nc/2) )*( (0:noc-1) - coff ));
kernr=exp((-1i*2*pi/(nr*usfac))*( (0:nor-1).' - roff )*( ifftshift([0:nr-1]) - floor(nr/2)  ));
out=kernr*in*kernc;
return
function [ imFTout ] = FTpad(imFT,outsize)
% imFTout = FTpad(imFT,outsize)
% Pads or crops the Fourier transform to the desired ouput size. Taking
% care that the zero frequency is put in the correct place for the output
% for subsequent FT or IFT. Can be used for Fourier transform based
% interpolation, i.e. dirichlet kernel interpolation.
%
%   Inputs
% imFT      - Input complex array with DC in [1,1]
% outsize   - Output size of array [ny nx]
%
%   Outputs
% imout   - Output complex image with DC in [1,1]
% Manuel Guizar - 2014.06.02
if ~ismatrix(imFT)
    error('Maximum number of array dimensions is 2')
end
Nout = outsize;
Nin = size(imFT);
imFT = fftshift(imFT);
center = floor(size(imFT)/2)+1;
imFTout = zeros(outsize);
centerout = floor(size(imFTout)/2)+1;
% imout(centerout(1)+[1:Nin(1)]-center(1),centerout(2)+[1:Nin(2)]-center(2)) ...
%     = imFT;
cenout_cen = centerout - center;
imFTout(max(cenout_cen(1)+1,1):min(cenout_cen(1)+Nin(1),Nout(1)),max(cenout_cen(2)+1,1):min(cenout_cen(2)+Nin(2),Nout(2))) ...
    = imFT(max(-cenout_cen(1)+1,1):min(-cenout_cen(1)+Nout(1),Nin(1)),max(-cenout_cen(2)+1,1):min(-cenout_cen(2)+Nout(2),Nin(2)));
imFTout = ifftshift(imFTout)*Nout(1)*Nout(2)/(Nin(1)*Nin(2));
return
