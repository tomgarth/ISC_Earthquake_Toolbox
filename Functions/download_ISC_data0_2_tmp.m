function [allPrimes, allHypocentres, allMagnitudes, allPhases] = download_ISC_data0_2( ...
        start_year, start_month, start_day, start_hour, start_minute, start_second, ...
        end_year, end_month, end_day, end_hour, end_minute, end_second, ...
        min_depth, max_depth, min_mag, max_mag, magnitude_type, ...
        magnitude_author, min_phases, max_phases, ...
        output_prime_hypocentres_only, include_phases, ...
        include_magnitudes, include_links, include_headers, ...
        include_comments, request, poly_string)

    % %UNTITLED23 Summary of this function goes here
    % %   Detailed explanation goes here
    % outputArg1 = inputArg1;
    % outputArg2 = inputArg2;
    % end

    start_time = sprintf('%1.0f%%3A%1.0f%%3A%1.0f', start_hour, start_minute, start_second);
    end_time = sprintf('%1.0f%%3A%1.0f%%3A%1.0f', end_hour, end_minute, end_second);

%     disp (' ');
%     disp ('!!!!!');
%     disp (' ');
%     disp (' ');
%     disp (' ');

%     disp ('start_time:');
%     disp (start_time);
%     disp ('end_time:');
%     disp (end_time);
% 
%     disp('start_year:');  disp(start_year);
%     disp('start_month:'); disp(start_month);
%     disp('start_day:');   disp(start_day);
%     
%     disp('end_year:');  disp(end_year);
%     disp('end_month:'); disp(end_month);
%     disp('end_day:');   disp(end_day);
% 
%     end_year = sprintf('%1.0f', end_year);
%     end_month = sprintf('%1.0f', end_month);
%     end_day = sprintf('%1.0f', end_day);

%     disp('end_year:');  disp(end_year);
%     disp('end_month:'); disp(end_month);
%     disp('end_day:');   disp(end_day);

%     disp (' ');
%     disp (' ');
%     disp (' ');
%     disp ('!!!!!');
%     disp (' ');
% 
%     start_year = sprintf('%1.0f', start_year);
%     start_month = sprintf('%1.0f', start_month);
%     start_day = sprintf('%1.0f', start_day);

    % Set minimum and maximum depths
    min_depth = sprintf('%1.0f', min_depth);
    max_depth = sprintf('%1.0f', max_depth);

    % Set minimum and maximum magnitudes
    min_mag = sprintf('%1.0f', min_mag);
    max_mag = sprintf('%1.0f', max_mag);

    % Set minimum and maximum number of phases
    if numel(min_phases) == 0
        min_phases = min_phases;
    else
        min_phases = sprintf('%1.0f', min_phases);
    end

    if numel(min_phases) == 0
        max_phases = max_phases;
    else
        max_phases = sprintf('%1.0f', max_phases);
    end

    % Define search shape
    search_shape = strtrim(request);

    % Define start and end time
    start_time_string = strsplit(start_time, '%3A');
    start_hour = str2double(start_time_string{1});
    start_minute = str2double(start_time_string{2});
    start_second = str2double(start_time_string{3});
    end_time_string = strsplit(end_time, '%3A');
    end_hour = str2double(end_time_string{1});
    end_minute = str2double(end_time_string{2});
    end_second = str2double(end_time_string{3});

    % Define start and end datetime of data
    t1 = datetime(start_year, start_month, start_day, start_hour, ...
        start_minute, start_second);
    t2 = datetime(end_year, end_month, end_day, end_hour, ...
        end_minute, end_second);

    % Define steps for time domain batch db calls
    t_diff = t2 - t1;
    num_steps = 100;
    t_step = days(t_diff)/num_steps;
    t_diff = days(t_diff);
    if t_step < 1
        num_steps = num_steps*t_step;
        t_step = 1;
    else
        t_step = floor(t_step) + 1;
    end
    t_stop  = 0;
    t_start = t1 - 1;
    t_end   = t_start + t_step;

    % Set the tables
    allPrimes = table;
    allHypocentres = table;
    % if strcmp(include_phases, 'on') == 1
    allPhases = table;
    % if strcmp(include_magnitudes, 'on') == 1
    allMagnitudes = table;

    % Loop through ISC webpage calls (~100 iterations)
    progress = 0;

    %     prog_str = sprintf('     Downloading part %i of %i', progress, num_steps, num_steps);
    %     disp(prog_str);
    %     fprintf('\n!Downloading part %i of %i\n', progress, num_steps);

    prog_str = sprintf('Download %1.0f %% complete', ...
        (progress/num_steps*num_steps));
    x = progress/num_steps;
    f = waitbar(x, prog_str);

    while t_stop < 1

        % Calculate prgoress bar (figure)
        progress = progress + 1;
        prog_str = sprintf('Download %1.0f %% complete', ...
            (progress/num_steps*100));
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
        if t_end >= t2
            t_end = t2;
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
        if request == 'GLOBAL   '

            % Define an ISC web request
        
            [ISC_URL_string] = build_ISC_URL0_5(... 
                'start_year', start_year, 'start_month', start_month, ...
                'start_day', start_day, 'start_time', start_time, ...
                'end_year', end_year, 'end_month', end_month, ...
                'end_day', end_day, 'end_time', end_time, ...
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

            [allPrimes, allHypocentres, allMagnitudes, allPhases] = readISCData(text_data, ...
                allPrimes, allHypocentres, allMagnitudes, allPhases, ...
                include_phases, include_magnitudes);
        end

        % Define and make web request for specific polygon area
        if request == 'POLYGON  '

            % Define an ISC web request
%             disp('Start POLYGON download ...');

            search_shape = request(1:7);
%             disp(search_shape)
%             disp(poly_string)
            
            [ISC_URL_string] = build_ISC_URL0_5(...
                'start_year', start_year, 'start_month', start_month, ...
                'start_day', start_day, 'start_time', start_time, ...
                'end_year', end_year, 'end_month', end_month, ...
                'end_day', end_day, 'end_time', end_time, ...
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

%             disp(ISC_URL_string);
            [text_data] = readISCwebdata(ISC_URL_string);
%             disp(text_data);

%             disp(allPrimes);
%             disp(allHypocentres);
%             disp(allMagnitudes);
%             disp(allPhases);
%             [allPrimes, allHypocentres, allMagnitudes, allPhases] = readISCData(text_data);
% 
%             disp(allPrimes);
%             disp(allHypocentres);
%             disp(allMagnitudes);
%             disp(allPhases);

            [allPrimes, allHypocentres, allMagnitudes, allPhases] = readISCData(text_data, ...
                allPrimes, allHypocentres, allMagnitudes, allPhases, ...
                include_phases, include_magnitudes);
        
        end
    end
end
