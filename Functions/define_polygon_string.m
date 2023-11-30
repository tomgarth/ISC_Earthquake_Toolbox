
function [poly_string] = define_polygon_string(poly_lats, poly_lons)

%% define_polygon_string
% Define the string of polygons needed to request a polygon from the ISC
% website
% T Garth 2023
% 
% Inputs
% - poly_lats, poly_lons
%
% Outputs:
% - polygon strring foramatted for ISC webcall

poly_string = sprintf('%1.3f%%2C%1.3f%%2C',poly_lats(1),poly_lons(1));
for n = 2:(numel(poly_lats)+1)
    if n < numel(poly_lats)+1
        poly_stringN = sprintf('%s%1.3f%%2C%1.3f%%2C', poly_string, poly_lats(n), poly_lons(n));
    else
        poly_stringN = sprintf('%s%1.3f%%2C%1.3f', poly_string, poly_lats(1), poly_lons(1));
    end
    poly_string = poly_stringN;
end
end