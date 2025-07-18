%  Function written for NanoLocz GUI and NanoLocz-lib (2025)
%  sym_ptCloud - Generate rotationally symmetric copies of point coordinates
%
% Inputs:
%   fold       - Symmetry fold (number of rotational repeats)
%   input_img  - Reference image (used for centering points)
%   Locs       - Nx2 array of (x, y) point coordinates
%
% Output:
%   sym_locs   - Symmetrized point cloud including original and rotated points

function sym_locs = sym_ptCloud(fold, input_img, Locs)

sd = size(input_img);
Locs(:,1) =  Locs(:,1) - sd(2)/2;
Locs(:,2) =  Locs(:,2) - sd(1)/2;
sym_locs = Locs;
for i=1:(fold-1)
    locs_rotated = Locs;
    angle = i*360/fold;
    v=[Locs(:,1)';Locs(:,2)'];
    R = [cos(angle*pi/180) sin(angle*pi/180); -sin(angle*pi/180) cos(angle*pi/180)];
    so = R*v;
    locs_rotated = Locs;
    locs_rotated(:,1) = so(1,:);
    locs_rotated(:,2) = so(2,:);
sym_locs = [sym_locs; locs_rotated];
end

sym_locs(:,1) =  sym_locs(:,1) + sd(2)/2;
sym_locs(:,2) =  sym_locs(:,2) + sd(1)/2;