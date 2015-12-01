function pick_points(raw_nikon, raw_apertus)

    % Pick points from the two images (interactive)
    pick_all_points(raw_nikon, 'reference');
    pick_all_points(raw_apertus, 'test');
    
    % Now, all points will be saved in ref_points.mat and tst_points.mat.
    % Next step, run match_images.
end

function pick_all_points(raw_image, image_type)
    % Load and display the reference image
    disp(sprintf('Reading %s image %s...', image_type, raw_image));
    im = read_cr2(raw_image);
    clf; hold off;
    show_raw(im, 0, max(im(:)), 1/8);
    
    % Zoom on the color chart
    pick_message('Please pick color chart bounding box to zoom on it (two diagonal corners).');
    [x,y] = ginput(2);
    x = sort(x); y = sort(y);
    x = x * 16; y = y * 16;
    x = round(x/2)*2; y = round(y/2) * 2;
    x1 = x(1)+1; y1 = y(1)+1; x2 = x(2); y2 = y(2);
    show_raw(im(y1:y2, x1:x2), 0, max(im(:)), 1);
    hold on;

    % Pick the size of a box on the color chart
    pick_message('Please pick box size (two diagonal corners).');
    [x,y] = ginput(2);
    dx = diff(x);
    dy = diff(y);
    diag = norm([dx dy]);
    size = diag / sqrt(2);
    radius = round(size / 3);
    disp(sprintf('Using box radius: %d px.', radius));

    % Pick gray and color boxes, to match the colors
    pick_message('Please pick gray boxes (centers). Press ENTER when finished.');
    [Xgray, Ygray] = pick_boxes(radius, 'k');

    pick_message('Please pick color boxes (centers). Press ENTER when finished.');
    [Xcolor, Ycolor] = pick_boxes(radius, 'r');
    
    % Save points
    % Note that points returned were picked on a half-resolution image, so multiply by 2
    out.Xgray = Xgray * 2 + x1;
    out.Ygray = Ygray * 2 + y1;
    out.Xcolor = Xcolor * 2 + x1;
    out.Ycolor = Ycolor * 2 + y1;
    out.radius = radius * 2;
    
    if strcmp(image_type, 'reference'),
        ref_points = out;
        save ref_points.mat ref_points
    else
        tst_points = out;
        save tst_points.mat tst_points
    end
    
    disp('Done.');
end

function pick_message(msg)
    disp(msg);
    title(msg);
end

function [X,Y] = pick_boxes(radius, marker_color)
    X = [];
    Y = [];
    while 1,
        [x,y] = ginput(1);
        plot([x - radius, x + radius, x + radius, x - radius, x - radius], [y - radius, y - radius, y + radius, y + radius, y - radius], marker_color);
        text(x, y, num2str(length(X)+1), 'fontsize', 8, 'color', marker_color, 'horizontalalignment', 'center', 'verticalalignment', 'middle');
        if isempty(x), break, end
        X(end+1) = x;
        Y(end+1) = y;
    end
end
