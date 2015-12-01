function match_images(raw_nikon, raw_apertus)
    clf, hold off
    
    % load test images
    ref = load_image(raw_nikon, 'reference');
    tst = load_image(raw_apertus, 'test');
    tst = tst(2:end,:);   % convert Apertus image to RGBG
    
    % load points picked from the color charts
    load ref_points.mat
    load tst_points.mat
    
    % crop the images to keep the color chart only
    [ref_points, ref] = crop_chart(ref_points, ref);
    [tst_points, tst] = crop_chart(tst_points, tst);
  
    % extract colors from the test images
    subplot(121);
    show_raw(ref, 0, max(ref(:)), 1); hold on;
    Gref = extract_colors(ref, ref_points.Xgray, ref_points.Ygray, ref_points.radius, 'k');
    Cref = extract_colors(ref, ref_points.Xcolor, ref_points.Ycolor, ref_points.radius, 'r');

    subplot(122);
    show_raw(tst, 0, max(tst(:)), 1); hold on;
    Gtst = extract_colors(tst, tst_points.Xgray, tst_points.Ygray, tst_points.radius, 'k');
    Ctst = extract_colors(tst, tst_points.Xcolor, tst_points.Ycolor, tst_points.radius, 'r');
    
    % compute black level
    disp(' ')
    disp('Black level that minimizes color variation in gray patches:')
    black_ref = find_black_level(Gref);
    black_tst = find_black_level(Gtst);
    disp(['Nikon  : ', num2str(black_ref)])
    disp(['Apertus: ', num2str(black_tst)])
    disp(' ')
    
    % adjust black level
    ref = ref - black_ref;
    tst = tst - black_tst;

    % extract the color patches again, after fixing the black level
    hold off;
    Gref = extract_colors(ref, ref_points.Xgray, ref_points.Ygray, ref_points.radius, 'k');
    Cref = extract_colors(ref, ref_points.Xcolor, ref_points.Ycolor, ref_points.radius, 'r');
    Gtst = extract_colors(tst, tst_points.Xgray, tst_points.Ygray, tst_points.radius, 'k');
    Ctst = extract_colors(tst, tst_points.Xcolor, tst_points.Ycolor, tst_points.radius, 'r');
    
    % alright, now we can match those colors!
    wb_nikon = [Gref(:,2) ./ Gref(:,1), Gref(:,2) ./ Gref(:,2), Gref(:,2) ./ Gref(:,3)];
    wb_apertus = [Gtst(:,2) ./ Gtst(:,1), Gtst(:,2) ./ Gtst(:,2), Gtst(:,2) ./ Gtst(:,3)];
    disp('White balance (median, on all gray patches):')
    wb_nikon = median(wb_nikon);
    wb_apertus = median(wb_apertus);
    disp(['Nikon  : ', mat2str(wb_nikon,5)]);
    disp(['Apertus: ', mat2str(wb_apertus,5)]);
    disp(' ')
    
    % find pre_mul by matching gray point between the two cameras
    pre_mul_apertus = match_gray_point(wb_nikon, wb_apertus);
    pre_mul_apertus
    
    % after applying white balance, find the normalized color matrix rgb_cam_n
    % that matches the hues between the two cameras
    rgb_cam_n_apertus = match_hues(Cref, Ctst, wb_nikon, wb_apertus);
    
    % combine the two matrix components (pre_mul and rgb_cam_n)
    calc_cam_xyz(pre_mul_apertus, rgb_cam_n_apertus)

    % that's it!
end

function im = load_image(raw_image, image_type)
    disp(sprintf('Reading %s image %s...', image_type, raw_image));
    im = read_cr2(raw_image);
end

function [points, im] = crop_chart(points, im)
    % find crop window from picked points
    Xmin = min([min(points.Xgray), min(points.Xcolor)]) - points.radius * 2;
    Xmax = max([max(points.Xgray), max(points.Xcolor)]) + points.radius * 2;
    Ymin = min([min(points.Ygray), min(points.Ycolor)]) - points.radius * 2;
    Ymax = max([max(points.Ygray), max(points.Ycolor)]) + points.radius * 2;
    
    % round crop window
    Xmin = round(Xmin / 2) * 2;
    Xmax = round(Xmax / 2) * 2;
    Ymin = round(Ymin / 2) * 2;
    Ymax = round(Ymax / 2) * 2;
    
    % crop image
    im = im(Ymin+1:Ymax, Xmin+1:Xmax);
    
    % adjust points
    points.Xgray = points.Xgray - Xmin;
    points.Ygray = points.Ygray - Ymin;
    points.Xcolor = points.Xcolor - Xmin;
    points.Ycolor = points.Ycolor - Ymin;
end

function [r,g,b] = raw_to_rgb(im)
    r  = im(1:2:end,1:2:end);
    g1 = im(1:2:end,2:2:end);
    g2 = im(2:2:end,1:2:end);
    b  = im(2:2:end,2:2:end);
    g = (g1 + g2) / 2;
end

function raw = rgb_to_raw(r,g,b)
    raw(1:2:end,1:2:end) = r;
    raw(1:2:end,2:2:end) = g;
    raw(2:2:end,1:2:end) = g;
    raw(2:2:end,2:2:end) = b;
end

function C = extract_colors(im, X, Y, radius, marker_color)
    C = [];
    
    % convert raw data to rgb (without debayering, just half-res)
    [R,G,B] = raw_to_rgb(im);
    
    % we will work on a half-res image
    X = round(X/2); Y = round(Y/2); radius = round(radius/2);
    
    % extract color patches and compute median color
    for i = 1:length(X)
        x = X(i); y = Y(i);
        if ishold, plot([x - radius, x + radius, x + radius, x - radius, x - radius], [y - radius, y - radius, y + radius, y + radius, y - radius], marker_color), end
        r = R(y-radius:y+radius, x-radius:x+radius);
        g = G(y-radius:y+radius, x-radius:x+radius);
        b = B(y-radius:y+radius, x-radius:x+radius);
        C(end+1,:) = [median(r(:)), median(g(:)), median(b(:))];
    end
end

function e = eval_black_level(black, gray_patches)
    % apply black level correction
    gray_patches = gray_patches - black;

    % find "hue" in each gray patch, as difference in stops from the green channel
    r = gray_patches(:,1);
    g = gray_patches(:,2);
    b = gray_patches(:,3);
    dr = log2(r ./ g);
    db = log2(b ./ g);
    
    % find the black level that minimizes the color variation in the gray patches
    % (so, doing white balance in any of them will give consistent results)
    e = std(dr) + std(db);
end

function black = find_black_level(G)
    black = fminsearch(@(x) eval_black_level(x,G), 0);
end
