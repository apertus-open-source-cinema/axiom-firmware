function im = read_cr2(filename, also_ob)
    if nargin < 2,
        also_ob = 0;
    end
    if also_ob
        dcraw = 'dcraw -c -4 -E';
    else
        dcraw = 'dcraw -c -4 -D';
    end
    system(sprintf('%s "%s" > tmp.pgm', dcraw, filename));
    im = double(imread('tmp.pgm'));
    system('rm tmp.pgm');
end
