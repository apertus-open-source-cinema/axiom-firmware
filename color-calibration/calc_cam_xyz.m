function calc_cam_xyz(pre_mul, rgb_cam_n)
    xyz_rgb = [0.412453, 0.357580, 0.180423; 0.212671, 0.715160, 0.072169; 0.019334, 0.119193, 0.950227];
    cam_rgb_n = inv(rgb_cam_n);

    % cam_rgb_n = cam_rgb .* (1 ./ (pre_mul * [1 1 1])) =>
    cam_rgb = cam_rgb_n ./ (1 ./ (pre_mul * [1 1 1]));
    % cam_rgb = cam_xyz * xyz_rgb =>
    cam_xyz = cam_rgb / xyz_rgb;
    cam_xyz

    % check the math (should print 1):
    [rgb_cam_check, pre_mul_check] = calc_rgb_cam(cam_xyz);
    norm(inv(cam_rgb) - rgb_cam_check) < 1e-15
    norm(pre_mul - pre_mul_check) < 1e-15

    % print in CHDK format (to paste directly into raw2dng)
    cam_xyz_lin = cam_xyz';
    cam_xyz_lin = cam_xyz_lin(:);
    disp(sprintf(['#define CAM_COLORMATRIX1                          \\\n' ...
    '   %5d, 10000,    %5d, 10000,   %5d, 10000, \\\n' ...
    '   %5d, 10000,    %5d, 10000,   %5d, 10000, \\\n'...
    '   %5d, 10000,    %5d, 10000,   %5d, 10000'], ...
        round(cam_xyz_lin * 10000)))


end
