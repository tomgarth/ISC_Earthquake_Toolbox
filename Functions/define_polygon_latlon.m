
function [poly_lats, poly_lons] = define_polygon_latlon()

%% define_polygon_latlon
% Define a list of polygons by picking points on a map
% T Garth, 2023
% 
% Inputs
% - From interactive map
%
% Outputs:
% - poly_lats - a list of polygon Latitudes
% - poly_lons - a list of polygon Longitudes

% Load in global large earthquakes for plotting
load Data/Example_ISC_Data/Global_2020_mw5_8plus.mat;
eq_lons = allPrimes.Longitude;
eq_lats = allPrimes.Latitude;
eq_depths = allPrimes.Depth;
clear all*;

% Plot the global map for polygon selection
figure;
geoscatter(eq_lats, eq_lons, 10, eq_depths);
geobasemap landcover;

% Draw the polygon
h1 = drawpolygon('FaceAlpha');
poly_lats = h1.Position(:,1);
poly_lons = h1.Position(:,2);