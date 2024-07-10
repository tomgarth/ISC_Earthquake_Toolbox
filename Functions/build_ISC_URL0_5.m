
function [ISC_URL_string] = build_ISC_URL0_5(varargin)

%% build_ISC_URL0_5
%
% A function to build the URL that allows data to be requested via the ISC
% website. The inputs must be a string with the variable name, followed by
% a stirng with the variable value.
% T Garth, R Adams, 2023


%% Set blank of default variables for when parameters are un-definced

% Variables for ALL searches
request        = 'COMPREHENSIVE';
out_format     = 'ISF2';
srn            = '';
grn            = '';

% Default start and end time are 2 years behind real time (i.e. latest data 
% month released by the ISC)
t_end = datetime-742;
[y_end,m_end,d_end] = ymd(t_end);
t_start = t_end-d_end-1;
[y_start,m_start,d_start] = ymd(t_start); %clear d_start;
start_year     = sprintf('%04.0f', y_start);
start_month    = sprintf('%02.0f', m_start);
start_day      = '01';
start_time     = '00%3A00%3A00&';
end_year       = sprintf('%04.0f', y_end);
end_month      = sprintf('%02.0f', m_end);
end_day        = '01';
end_time       = '00%3A00%3A00&';

% Depth variables
min_dep = '';
max_dep = '';

% Magnitude variables
min_mag = '5.5';
max_mag = '9.0';
req_mag_type = '';
req_mag_agcy = 'GCMT';

% Define number of defining phases
min_def = '';
max_def = '';

% Define data types to include
include_magnitudes = 'on';
include_links      = 'off';
include_headers    = 'on';
include_comments   = 'on';
include_phases     = 'on';

% Define spatial parameters (blank if not required)
searchshape    = 'GLOBAL'; % Set search type to GLOBAL
bot_lat        = '';       % Set spatial search parameters to blank
top_lat        = '';
left_lon       = '';
right_lon      = '';
ctr_lat        = '';
ctr_lon        = '';
radius         = '';
max_dist_units = 'deg';
coordvals      = '';      % The coordinate values (poly_lat and poly_lon) 
                          % that a re needed if the search is defined as a 
                          % polygon

%% Search for input arguments
for n = 1:numel(varargin)

    if strcmp(varargin{n}, 'request')
        request = varargin{n+1};
    elseif strcmp(varargin{n}, 'out_format')
        out_format = varargin{n+1};
    elseif strcmp(varargin{n}, 'srn')
        srn = varargin{n+1};
    elseif strcmp(varargin{n}, 'grn')
        grn = varargin{n+1};

    elseif strcmp(varargin{n}, 'start_year')
        start_year = varargin{n+1};
    elseif strcmp(varargin{n}, 'start_month')
        start_month = varargin{n+1};
    elseif strcmp(varargin{n}, 'start_day')
        start_day = varargin{n+1};
    elseif strcmp(varargin{n}, 'start_time')
        start_time = varargin{n+1};

    elseif strcmp(varargin{n}, 'end_year')
        end_year = varargin{n+1};
    elseif strcmp(varargin{n}, 'end_month')
        end_month = varargin{n+1};
    elseif strcmp(varargin{n}, 'end_day')
        end_day = varargin{n+1};
    elseif strcmp(varargin{n}, 'end_time')
        end_time = varargin{n+1};

    elseif strcmp(varargin{n}, 'min_dep')
        min_dep = varargin{n+1};
    elseif strcmp(varargin{n}, 'max_dep')
        max_dep = varargin{n+1};

    elseif strcmp(varargin{n}, 'min_mag')
        min_mag = varargin{n+1};
    elseif strcmp(varargin{n}, 'max_mag')
        max_mag = varargin{n+1};

    elseif strcmp(varargin{n}, 'req_mag_type')
        req_mag_type = varargin{n+1};
    elseif strcmp(varargin{n}, 'req_mag_agcy')
        req_mag_agcy = varargin{n+1};

    elseif strcmp(varargin{n}, 'min_def')
        min_def = varargin{n+1};
    elseif strcmp(varargin{n}, 'max_def')
        max_def = varargin{n+1};

    elseif strcmp(varargin{n}, 'include_magnitudes')
        include_magnitudes = varargin{n+1};
    elseif strcmp(varargin{n}, 'include_links')
        include_links = varargin{n+1};
    elseif strcmp(varargin{n}, 'include_headers')
        include_headers = varargin{n+1};
    elseif strcmp(varargin{n}, 'include_comments')
        include_comments = varargin{n+1};
    elseif strcmp(varargin{n}, 'include_phases')
        include_phases = varargin{n+1};

    elseif strcmp(varargin{n}, 'searchshape')
        searchshape = varargin{n+1};
    elseif strcmp(varargin{n}, 'bot_lat')
        bot_lat = varargin{n+1};
    elseif strcmp(varargin{n}, 'top_lat')
        top_lat = varargin{n+1};
    elseif strcmp(varargin{n}, 'left_lon')
        left_lon = varargin{n+1};
    elseif strcmp(varargin{n}, 'ctr_lat')
        ctr_lat = varargin{n+1};
      
    elseif strcmp(varargin{n}, 'radius')
        radius = varargin{n+1};
    elseif strcmp(varargin{n}, 'max_dist_units')
        max_dist_units = varargin{n+1};
    elseif strcmp(varargin{n}, 'coordvals')
        coordvals = varargin{n+1};
        poly_string = coordvals;
    end
end

%% Define the ISC web call
searchshapedelineator = searchshape(1:4); %disp(searchshapedelineator)

% For a GLOBAL, RECTANGULAR or CIRCLULAR search
if (searchshapedelineator == 'GLOB') | (searchshapedelineator == 'RECT') | (searchshapedelineator == 'CIRC')

    ISC_URL_string = sprintf(['http://www.isc.ac.uk/cgi-bin/web-db-ml?' ...
        'request=%s&out_format=%s' ...
        '&bot_lat=%s&top_lat=%s&left_lon=%s&right_lon=%s' ...
        '&ctr_lat=%s&ctr_lon=%s&radius=%s&max_dist_units=%s' ...
        '&searchshape=%s&srn=&grn=' ...
        '&start_year=%s&start_month=%s&start_day=%s&start_time=%s' ...
        '&end_year=%s&end_month=%s&end_day=%s&end_time=%s' ...
        '&min_dep=%s&max_dep=%s' ...
        '&min_mag=%s&max_mag=%s&req_mag_type=%s&req_mag_agcy=%s' ...
        '&min_def=%s&max_def=%s' ...
        '&include_phases=%s&include_magnitudes=%s&include_links=%s' ...
        '&include_headers=%s&include_comments=%s'], ...
        request, out_format, ...
        bot_lat, top_lat, left_lon, right_lon, ...
        ctr_lat, ctr_lon, radius, max_dist_units, searchshape, ...
        start_year, start_month, start_day, start_time, ...
        end_year, end_month, end_day, end_time, ...
        min_dep, max_dep, ...
        min_mag, max_mag, ...
        req_mag_type, req_mag_agcy, ...
        min_def, max_def, ...
        include_phases, include_magnitudes, include_links, ...
        include_headers, include_comments);
end

% For a POLYGON search
if (searchshapedelineator == 'POLY')

    url = sprintf(['http://www.isc.ac.uk/cgi-bin/web-db-ml?searchshape=%s&' ...
        'coordvals=%s' ...
        '&request=%s&out_format=ISF2' ...
        '&start_year=%s&start_month=%s&start_day=%s&start_time=%s' ...
        '&end_year=%s&end_month=%s&end_day=%s&end_time=%s' ...
        '&min_dep=%s&max_dep=%s' ...
        '&min_mag=%s&max_mag=%s&req_mag_type=%s&req_mag_agcy=%s' ...
        '&min_def=%s&max_def=%s' ...
        '&include_phases=%s&include_magnitudes=%s&include_links=%s' ...
        '&include_headers=%s&include_comments=%s'], ...
        searchshapedelineator, poly_string, request, ...
        start_year, start_month, start_day, start_time, ...
        end_year, end_month, end_day, end_time, ...
        min_dep, max_dep, ...
        min_mag, max_mag, ...
        req_mag_type, req_mag_agcy, ...
        min_def, max_def, ...
        include_phases, include_magnitudes, include_links, ...
        include_headers, include_comments);
    ISC_URL_string = url;
end
