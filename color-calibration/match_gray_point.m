function pre_mul_apertus = match_gray_point(wb_nikon, wb_apertus)
    % Nikon ColorMatrix2 for D65:
    % Color Matrix 2                  : 0.7866 -0.2108 -0.0555 -0.4869 1.2483 0.2681 -0.1176 0.2069 0.7501
    cam_xyz_nikon = [0.7866 -0.2108 -0.0555; -0.4869 1.2483 0.2681; -0.1176 0.2069 0.7501];
    [rgb_cam_nikon, pre_mul_nikon, rgb_cam_n_nikon] = calc_rgb_cam(cam_xyz_nikon);

    % find pre_mul_apertus so that WB matches with Nikon
    % assume wb_nikon .* pre_mul_nikon == wb_apertus .* pre_mul_apertus
    % proof: exercise to the reader (or: I don't know how to prove it, but it works)
    pre_mul_apertus = wb_nikon(:) .* pre_mul_nikon(:) ./ wb_apertus(:);
    pre_mul_apertus = pre_mul_apertus * norm(pre_mul_nikon) / norm(pre_mul_apertus);
end
