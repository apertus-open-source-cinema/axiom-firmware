function rgb_cam_n_apertus = match_hues(colors_nikon, colors_apertus, wb_nikon, wb_apertus)
    % Nikon ColorMatrix2 for D65:
    % Color Matrix 2                  : 0.7866 -0.2108 -0.0555 -0.4869 1.2483 0.2681 -0.1176 0.2069 0.7501
    cam_xyz_nikon = [0.7866 -0.2108 -0.0555; -0.4869 1.2483 0.2681; -0.1176 0.2069 0.7501];
    [rgb_cam_nikon, pre_mul_nikon, rgb_cam_n_nikon] = calc_rgb_cam(cam_xyz_nikon);

    % apply Nikon color matrix
    hues_nikon = calc_hues(colors_nikon, wb_nikon, rgb_cam_n_nikon);
    
    % find Apertus color matrix
    % optimize for the first two columns, and compute the third by normalization
    % try a few random starting points, just in case
    ebest = 100;
    for i = 0:100
        [rgb_cam_n,e] = fminsearch(@(x) eval_hues(x, colors_apertus, wb_apertus, hues_nikon), ...
            rgb_cam_n_nikon(:,1:2) + randn(3,2) * rand * i / 100);
        if e < ebest,
            rgb_cam_n_apertus = normalize_rgb_cam(rgb_cam_n);
            ebest = e;
        end
    end
    
    rgb_cam_n_apertus
    ebest
end

function rgb_cam = normalize_rgb_cam(rgb_cam)
    % normalize so that rgb_cam * [1;1;1] = [1;1;1]
    % that is, white and gray are not affected by the color matrix
    for i = 1:3
        rgb_cam(i,3) = 1 - sum(rgb_cam(i,1:2));
    end
end

function e = eval_hues(rgb_cam_n_apertus, colors_apertus, wb_apertus, hues_nikon)
    % compare Apertus hues obtained with any matrix, with the Nikon hues
    % lower score = better match (useful for minimization)
    rgb_cam_n_apertus = normalize_rgb_cam(rgb_cam_n_apertus);
    hues_apertus = calc_hues(colors_apertus, wb_apertus, rgb_cam_n_apertus);
    e = norm(hues_apertus - hues_nikon);
end

function hues = calc_hues(colors, wb, rgb_cam_n)
    % convert color patches into "hues" (red/green and blue/green ratio, in stops)
    N = size(colors, 1);
    hues = zeros(N, 2);
    for i = 1:N
        cam_wb = (colors(i,:) .* wb)';
        rgb = rgb_cam_n * cam_wb;
        hues(i,:) = log2([rgb(1),rgb(3)] / rgb(2));
    end
end
