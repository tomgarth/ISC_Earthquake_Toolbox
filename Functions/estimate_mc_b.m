function [a, b, mag_distr, xmags, h_mag, ab_fit] = estimate_mc_b(magnitudes, ...
    mb_min_overwrite, mb_max_overwrite, plot_figures)

% A function that gives a rather coartse esimate of b-value
% T Garth, 2023
%
% Inputs
% - Earthquake magnitudes
% - Min and max magniudes if you want to overwrite the automatically 
%   determined values
%
% Outputs:
% - a-value 
% - b-value
% - magntude distrubution
% - cumaltive magntude distrubution
% - fit to the cumaltive magnitude distribution

%% Find minimum and maximum magnitudes
min_mag = min(magnitudes);
max_mag = max(magnitudes);

%% Make a histogram to of magnitudes
n = (((max_mag+0.1) - (min_mag-0.1))*10) + 1;
xmags = linspace((min_mag-0.1), (max_mag+0.1), n);
xbins = xmags-0.05;
h_mag = hist(magnitudes, xbins);
mag_distr = h_mag;

%% Calculate the cumilative magnitude distribution
h_cumilative = 0;
for n = numel(h_mag):-1:1
    h_cumilative = h_cumilative + h_mag(n);
    h_mag_cumulative(n) = h_cumilative;
end
h_mag = h_mag_cumulative;

%% Fit the histogram to get Mc and b-value

% Find the maximum magnitude to fit
max_h = 0;
mb_max = 0;
for n = 1:numel(h_mag)
    if (mb_max == 0 && h_mag(n) == 0)
        if n == 1
            mb_max = xbins(n);
            mb_max_n = n;
        else
            mb_max = xbins(n-1);
            mb_max_n = n;
        end
    end
end
if (mb_max == 0)
    mb_max = xbins(n);
    mb_max_n = n;
end

% Overwrite with user input maximum magnitude if defined
if (mb_max_overwrite ~= 0)
    mb_max = mb_max_overwrite;
    mag_diff = inf;
    for n = 1:numel(xbins)
        if mag_diff > abs(mb_max-xbins(n))
            mag_diff = mb_max-xbins(n);
            mb_max_n = n;
        end
    end
end

% Find the minimum magnitude to fit
mb_grad = gradient(log10(h_mag));
mb_min = mb_max;
for n = 1:numel(h_mag)
    if (mb_min == mb_max) && (mb_grad(n) < -0.1) && (mb_grad(n) > -0.2)
        mb_min = xbins(n);
        mb_min_n = n;
    end
end

% Overwrite with user input minimum magnitude if defined
if (mb_min_overwrite ~= 0)
    mb_min = mb_min_overwrite;
    mag_diff = inf;
    for n = 1:numel(xbins)
        if mag_diff > abs(mb_min-xbins(n))
            mag_diff = mb_min-xbins(n);
            mb_min_n = n;
        end
    end
end

% Find the number of magnitudes
x_mags = xmags(mb_min_n:mb_max_n);
num_mags = h_mag(mb_min_n:mb_max_n);
log10_num_mags = log10(h_mag(mb_min_n:mb_max_n));

% Set infintie values to NaN
x_mags(isinf(log10_num_mags)) = NaN;
num_mags(isinf(log10_num_mags)) = NaN;
log10_num_mags(isinf(log10_num_mags)) = NaN;

% Remove NaN values
x_mags = rmmissing(x_mags);
num_mags = rmmissing(num_mags);
log10_num_mags = rmmissing(log10_num_mags);

% Fit the magntude distribution
ft = fittype('b*x+a');
a_start = 10.0; b_start = -1.0;
ft = fit(x_mags', log10_num_mags', ft, 'StartPoint', [b_start, a_start]);
a = ft.a; b = ft.b;
ab_fit = ft.a + (ft.b*x_mags);

% Plot fit if plot_figures is true
if (plot_figures == 1)
    figure; hold on;
    scatter(xmags, h_mag, 'filled');
    scatter(x_mags, 10.^log10_num_mags, 'filled');
    plot(x_mags, 10.^ab_fit);
    set(gca, 'Yscale', 'log');

    text_line = sprintf(['\n\n\n\na   = %1.2f\nb   = %1.2f\nm_c = %1.2f'], ...
        ft.a, abs(ft.b), mb_min);
    text(mb_max-0.5, max(h_mag), text_line);
    
    xlabel('Earthquake Magnitude');
    ylabel('Cumilative Earthquake Frequency');

end
