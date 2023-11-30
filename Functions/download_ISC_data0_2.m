function [Primes, Hypocentres, Magnitudes, Phases] = download_ISC_data0_2( ...
        start_datetime, end_datetime, depth_limits, magnitude_limits, ...
        phases_limits, magnitude_type, magnitude_author, NameValueArgs)

    arguments
        start_datetime (1,1) datetime
        end_datetime (1,1) datetime
        depth_limits (1,2) double {mustBeInRange(depth_limits,0,700), ...
                                   mustBeIncreasing}
        magnitude_limits (1,2) double {mustBeInRange(magnitude_limits,-1,10), ...
                                       mustBeIncreasing}
        phases_limits (1,2) double 
        magnitude_type (1,1) string {mustBeTextScalar}
        magnitude_author (1,1) string {mustBeTextScalar}
              
        NameValueArgs.IncludePhases (1,1) string {mustBeOnOff} = "off"
        NameValueArgs.IncludeMagnitudes (1,1) string {mustBeOnOff} = "on"
        NameValueArgs.IncludeLinks (1,1) string {mustBeOnOff} = "off"
        NameValueArgs.IncludeHeaders (1,1) string {mustBeOnOff} = "on"
        NameValueArgs.IncludeComments (1,1) string {mustBeOnOff} = "on"
        NameValueArgs.Request (1,1) string ...
            {mustBeMember(NameValueArgs.Request,["GLOBAL","POLYGON"])} = "GLOBAL"
        NameValueArgs.PolyString (1,:) string {mustBeTextScalar} = ""
        NameValueArgs.OutputPrimeHypocentresOnly (1,1) string {mustBeOnOff} = "off"
    end

    % Optional inputs
    include_phases = NameValueArgs.IncludePhases;
    include_magnitudes = NameValueArgs.IncludeMagnitudes;
    include_links = NameValueArgs.IncludeLinks;
    include_headers = NameValueArgs.IncludeHeaders;
    include_comments = NameValueArgs.IncludeComments;
    request = NameValueArgs.Request;
    poly_string = NameValueArgs.PolyString;
    if poly_string == ""
        poly_string= [];
    end
    output_prime_hypocentres_only = NameValueArgs.OutputPrimeHypocentresOnly;

    % Set minimum and maximum depths
    min_depth = sprintf('%1.0f', depth_limits(1));
    max_depth = sprintf('%1.0f', depth_limits(2));

    % Set minimum and maximum magnitudes
    min_mag = sprintf('%1.0f', magnitude_limits(1));
    max_mag = sprintf('%1.0f', magnitude_limits(2));

    % Set minimum and maximum number of phases
    if ~isfinite(phases_limits(1))
        min_phases = '';
    else
        min_phases = sprintf('%1.0f', phases_limits(1));
    end
    if ~isfinite(phases_limits(2))
        max_phases = '';
    else
        max_phases = sprintf('%1.0f', phases_limits(2));
    end

    % Define search shape
    search_shape = strtrim(request);

    % Define start and end time  
    start_hour = hour(start_datetime); 
    start_minute = minute(start_datetime); 
    start_second = second(start_datetime); 
    
    end_hour = hour(end_datetime);
    end_minute = minute(end_datetime);
    end_second = second(end_datetime);

    start_time_str = sprintf('%1.0f%%3A%1.0f%%3A%1.0f', start_hour, ...
        start_minute, start_second);
    end_time_str = sprintf('%1.0f%%3A%1.0f%%3A%1.0f', end_hour, ...
        end_minute, end_second);

    % Define steps for time domain batch db calls
    t_diff = end_datetime - start_datetime;
    num_steps = 100; %TODO change back to 100;
    t_step = days(t_diff)/num_steps;
    t_diff = days(t_diff);
    if t_step < 1
        num_steps = num_steps*t_step;
        t_step = 1;
    else
        t_step = floor(t_step) + 1;
    end
    t_stop  = 0;
    t_start = start_datetime - t_step;
    t_end   = t_start + t_step;

    % Set the tables
    Primes = table;
    Hypocentres = table;
    Phases = table;
    Magnitudes = table;

    % Loop through ISC webpage calls (~100 iterations)
    progress = 0;

    prog_str = sprintf('Download %1.0f %% complete', ...
        (progress/num_steps*num_steps));
    x = progress/num_steps;
    f = waitbar(x, prog_str);

    while t_stop < 1

        % Calculate prgoress bar (figure)
        progress = progress + 1;
        prog_str = sprintf('Download %1.0f %% complete', ...
            (progress/num_steps*100));
%         disp(prog_str)
        x = progress/num_steps;

        if progress == 0
            f = waitbar(x, prog_str);
        else progress < num_steps;
            waitbar(x, f, prog_str);
        end
        if progress >= num_steps
            close(f)
        end
        
        % Step forward the start and end
        t_start = t_start + t_step;
        t_end   = t_end + t_step;
        if t_end >= end_datetime
            t_end = end_datetime;
            t_stop = 1;
        end

        % Set start times
        start_year  = year(t_start);
        start_month = month(t_start);
        start_day   = day(t_start);
        start_year  = sprintf('%1.0f', start_year);
        start_month = sprintf('%1.0f', start_month);
        start_day   = sprintf('%1.0f', start_day);

        % Set end times
        end_year  = year(t_end);
        end_month = month(t_end);
        end_day   = day(t_end);
        end_year  = sprintf('%1.0f', end_year);
        end_month = sprintf('%1.0f', end_month);
        end_day   = sprintf('%1.0f', end_day);

        % Define and make Global web request
        if request == "GLOBAL"

            % Define an ISC web request
            [ISC_URL_string] = build_ISC_URL0_5(...  %TODO remove _new
                'start_year', start_year, 'start_month', start_month, ...
                'start_day', start_day, 'start_time', start_time_str, ...
                'end_year', end_year, 'end_month', end_month, ...
                'end_day', end_day, 'end_time', end_time_str, ...
                'min_dep', min_depth, 'max_dep', max_depth, ...
                'min_mag', min_mag, 'max_mag', max_mag, ...
                'req_mag_type', magnitude_type, 'req_mag_agcy', magnitude_author, ...
                'min_def',  min_phases, 'max_def', max_phases, ...
                'include_magnitudes', include_magnitudes, ...
                'include_links', include_links, ...
                'include_headers', include_headers, ...
                'include_comments', include_comments, ...
                'include_phases', include_phases);

            [text_data] = readISCwebdata(ISC_URL_string);

            [Primes, Hypocentres, Magnitudes, Phases] = readISCData(...
                text_data, Primes, Hypocentres, Magnitudes, Phases, ...
                include_phases, include_magnitudes);
        end

        % Define and make web request for specific polygon area
        if request == "POLYGON"

            % Define an ISC web request
            search_shape = char(request);
            
            [ISC_URL_string] = build_ISC_URL0_5(...
                'start_year', start_year, 'start_month', start_month, ...
                'start_day', start_day, 'start_time', start_time_str, ...
                'end_year', end_year, 'end_month', end_month, ...
                'end_day', end_day, 'end_time', end_time_str, ...
                'min_dep', min_depth, 'max_dep', max_depth, ...
                'min_mag', min_mag, 'max_mag', max_mag, ...
                'req_mag_type', magnitude_type, 'req_mag_agcy', magnitude_author, ...
                'min_def',  min_phases, 'max_def', max_phases, ...
                'include_magnitudes', include_magnitudes, ...
                'include_links', include_links, ...
                'include_headers', include_headers, ...
                'include_comments', include_comments, ...
                'include_phases', include_phases, ...
                'searchshape', search_shape, ...
                'coordvals', poly_string);

            [text_data] = readISCwebdata(ISC_URL_string);

            [Primes, Hypocentres, Magnitudes, Phases] = readISCData(text_data, ...
                Primes, Hypocentres, Magnitudes, Phases, ...
                include_phases, include_magnitudes);
        
        end
    end
end

function mustBeOnOff(prop)
 mustBeMember(prop,["on","off"]);
end
function mustBeIncreasing(prop)
if prop(1) > prop(2)
    error("Lower limit must be below upper limit value")
end
end