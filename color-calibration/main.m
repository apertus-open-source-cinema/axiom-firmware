% Main script for performing color calibration.

% You will need a test image taken with the Apertus camera,
% and a reference image taken with another camera (e.g. Nikon).
raw_nikon = 'CC3.dng';
raw_apertus = 'CC3.DNG';

% Octave setup
more off
pkg load image

% First, pick some points on a color chart.
% This interactive step is required only once; the results are saved to file.
% That means, you may just comment it out, to make it easier to debug the next step.
pick_points(raw_nikon, raw_apertus);

% Next, match the colors from the picked points and compute a color matrix.
match_images(raw_nikon, raw_apertus);

% That's it, folks!
