function show_raw(im, black, white, scale)
    r  = im(1:2:end,1:2:end);
    g1 = im(1:2:end,2:2:end);
    g2 = im(2:2:end,1:2:end);
    b  = im(2:2:end,2:2:end);
    g = (g1 + g2) / 2;
    
    scale = round(1/scale);
    r = r(1:scale:end, 1:scale:end);
    g = g(1:scale:end, 1:scale:end);
    b = b(1:scale:end, 1:scale:end);
    
    show_raw_rgb(r, g, b, black, white);
end

function show_raw_rgb(r, g, b, black, white)
    r = r - black;
    g = g - black;
    b = b - black;
    white = white - black;
    m = log2(white);

    IM(:,:,1) = (log2(max(1,r*2)) / m).^3;
    IM(:,:,2) = (log2(max(1,g)) / m).^3;
    IM(:,:,3) = (log2(max(1,b*1.5)) / m).^3;
    imshow(IM,[]);
end
