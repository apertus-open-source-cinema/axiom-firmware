function [rgb_cam, pre_mul, rgb_cam_n] = calc_rgb_cam(cam_xyz)
    % notations from dcraw
    xyz_rgb = [0.412453, 0.357580, 0.180423; 0.212671, 0.715160, 0.072169; 0.019334, 0.119193, 0.950227];
    cam_rgb = cam_xyz * xyz_rgb;
    pre_mul = cam_rgb * [1;1;1];
    cam_rgb_n = cam_rgb .* (1 ./ (pre_mul * [1 1 1]));
    rgb_cam_n = inv(cam_rgb_n);
    rgb_cam = inv(cam_rgb);
end
