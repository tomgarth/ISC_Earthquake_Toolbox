function [transectOutput,eq_dist,eq_depth,topo_dist,transect_topo] = earthquakeTransectCalc(transectInput,linelat1,linelon1,linelat2,linelon2,transect_width)

% Transect input is [EventID, OrigID, lat, long, depth]
% e.g. transectInput = allPrimes(:,[20 19 4 5 9])

% load topography

load topo.mat;

% Setup transect arrays

eq_dist = [];
eq_depth = [];
transect_topo = [];

% Convert transect width to metres

tw = transect_width*1000;

% Set coordinate system

wgs84 = wgs84Ellipsoid("m");

% Calculate bearing of the transect and length of the transect

[line_distance,line_bearing] = distance(linelat1,linelon1,linelat2,linelon2,wgs84);

% Create bounding box arrays

bblat = [];
bblon = [];

[bblat(end+1),bblon(end+1)] = reckon(linelat1,linelon1,50000,0,wgs84);
[bblat(end+1),bblon(end+1)] = reckon(linelat1,linelon1,tw,90,wgs84);
[bblat(end+1),bblon(end+1)] = reckon(linelat1,linelon1,tw,180,wgs84);
[bblat(end+1),bblon(end+1)] = reckon(linelat1,linelon1,tw,270,wgs84);

[bblat(end+1),bblon(end+1)] = reckon(linelat2,linelon2,tw,0,wgs84);
[bblat(end+1),bblon(end+1)] = reckon(linelat2,linelon2,tw,90,wgs84);
[bblat(end+1),bblon(end+1)] = reckon(linelat2,linelon2,tw,180,wgs84);
[bblat(end+1),bblon(end+1)] = reckon(linelat2,linelon2,tw,270,wgs84);

% Get edges of bounding box

max_bblat = max(bblat);
min_bblat = min(bblat);
max_bblon = max(bblon);
min_bblon = min(bblon);

% Sample topography every 50 km

topo_samples = ceil(line_distance/50000);

% Get lat and lon of sample points along the transect

[topo_lat,topo_lon] = track1(linelat1,linelon1,line_bearing,line_distance,wgs84,'degrees',topo_samples);

% Loop over transect sample points

for ii = 1:numel(topo_lat)

    % Get topography for each lat and lon along transect 
    
    transect_topo(end+1) = topo(round(topo_lat(ii)+91),wrapTo360(round(topo_lon(ii))));

end

% Create output table

transectOutput = table;

% Loop over input data

for i = 1:height(transectInput)

    % Get lat, lon, depth of each input event

    point_lat = transectInput{i,3};
    point_lon = transectInput{i,4};
    point_depth = transectInput{i,5};

    % Check if event inside bounding box

    if point_lat > max_bblat || point_lat < min_bblat
        continue
    end
    if point_lon > max_bblon || point_lon < min_bblon
        continue
    end

    % Calculate distance and bearing from start of transect to event

    [point_dist,point_bearing] = distance(linelat1,linelon1,point_lat,point_lon,wgs84);

    % Calculate difference in bearing between transect and event

    bearing_diff = deg2rad(point_bearing) - deg2rad(line_bearing);

    % Calculate straight line distance between point and transect

    dist_across = asin(sin((point_dist/6371000))*sin(bearing_diff))*6371000;

    % Calculate distance along transect that straight line intersects

    dist_along = acos(cos(point_dist/6371000)/cos(dist_across/6371000))*6371000;

    % If event is within transect length get distance along transect and depth 

    if dist_across <= (tw) && dist_along <= line_distance && dist_along > 0
        eq_dist = [eq_dist, dist_along]; %#ok<AGROW>
        eq_depth = [eq_depth, point_depth]; %#ok<AGROW>
        transectOutput = [transectOutput; transectInput(i,:)]; %#ok<AGROW>
    end

end

tiledlayout(2,1)

% Plot transect topography

nexttile
topo_dist = linspace(0,line_distance,topo_samples);
plot(topo_dist,transect_topo)
xlim([0 line_distance])

% Plot transect events

nexttile
scatter(eq_dist,eq_depth)
axis ij
xlim([0 line_distance])