function [data] = readISCwebdata(url)

%% Read webpage data very simply
% Needs more detail adding soon .....

% Read in data for a set of events
% disp('Request data from ISC website ....');
if numel(url) == 0
    url = 'http://www.isc.ac.uk/cgi-bin/web-db-run?request=COMPREHENSIVE&out_format=ISF2&bot_lat=&top_lat=&left_lon=&right_lon=&ctr_lat=&ctr_lon=&radius=&max_dist_units=deg&searchshape=GLOBAL&srn=&grn=&start_year=2021&start_month=2&start_day=01&start_time=00%3A00%3A00&end_year=2021&end_month=3&end_day=01&end_time=00%3A00%3A00&min_dep=&max_dep=&min_mag=5.0&max_mag=&req_mag_type=&req_mag_agcy=GCMT&min_def=&max_def=&include_magnitudes=on&include_links=off&include_headers=on&include_comments=on';
end

options = weboptions('Timeout', 3600); % Times out after 1 hour
data = webread(url,options);

end