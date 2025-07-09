% USAGE EXAMPLE:
%   A = ImageTarget;
%   xy = round(Part.Locs(:,1:2));
%   directions = [1, 1, 1, 1];  % enable all directions
%   max_radius = 15;
%   widthRef = 'local height';
%
%   [Rmin, Rmax, Rmean, p] = Lineprofiler(A, xy, max_radius, directions, widthRef);
%
%   figure;
%   imagesc(A); colormap(jet); hold on;
%   plot(xy(:,1), xy(:,2), 'ko');
%   for j = 1:numel(xy(:,1))
%       plot(p{j,1}(:,1), xy(j,2)*ones(size(p{j,1}(:,1))), 'w-'); % x-profiles
%   end
%