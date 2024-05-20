
function [Primes, Hypocentres, Magnitudes, Phases] = readISCData(textData, ...
    Primes, Hypocentres, Magnitudes, Phases, ...
    include_phases, include_magnitudes)

% Extract the number of events in the data
nEvents = regexp(textData,'Events found: (\d*)','once','tokens');
try
    nEvents = str2double(nEvents{1});
catch
    return
end

% Remove headers and footers
textData = regexprep(textData, '^.*DATA_TYPE EVENT','','once');
textData = regexprep(textData, 'STOP.*$', '','once');

% Idetify event blocks 
eventPattern = 'Event +\d+';
[starts, ends] = regexp(textData,eventPattern,'start','end');
if numel(starts) == 0
    return
end

% Set the evid
for n = 1:numel(starts)
    evid_text = textData(starts(n):ends(n));
    evid = evid_text(7:numel(evid_text));
    evid = str2double(evid);
    eventIds(n) = evid;
end

for iEvent = 1:nEvents

    % Get event text
    if iEvent < nEvents
%         disp ('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
%         disp (textData(ends(iEvent)+1:starts(iEvent+1)-1));
        eventTxt = textData(ends(iEvent)+1:starts(iEvent+1)-1);
    else
        eventTxt = textData(ends(iEvent)+1:end);
    end

    % Identify the data for the prime event information
    % Get the line preceding the word 'PRIME'
    primeText = regexp(eventTxt,'([^\r\n]*)[\r\n]+[ ]*\(\#PRIME\)', ...
        'once','tokens');

    %disp(eventTxt)

    % Get the line preceding the word 'PRIME' as this is the event line if 
    % prime is a HYPOCENTRE

    if isempty(primeText)
        % If PRIME doesnt exist, return NaNs
        prime = readHypocentreData({});

    else
        try
            % In most cases, define PRIME hypocentre here
            prime = readHypocentreData(primeText{1});

        catch
            try
                % Catch here if PRIME is a CENTROID (e.g. often gCMT)
                prime = readHypocentreData(primeText{1});

            catch
                if numel(primeText{1}) > 182
                    % Catch here if print line is to  long
                    prime = primeText{1}; 
                    prime = prime(numel(prime)-181:numel(prime)); 
                    prime = readHypocentreData(prime);

                end
            end
        end
    end

%     disp('prime:')
%     disp(prime)

%     disp(allPrimes)
    prime.EventID = eventIds(iEvent);
%     allPrimes = [allPrimes; prime]; %#ok<AGROW> 

    Primes = [Primes; prime]; %#ok<AGROW> 
  
    % Remove text inside brackets from the event data
    eventTxt = regexprep(eventTxt,'\s*\([^\)]*\)','');

    % Extract Hypocentre data
    startOfHypoData = regexp(eventTxt,'\d{4}/\d{2}/\d{2}','once','start');
    endOfHypoData = regexp(eventTxt,'(Year|Magnitude|Sta|Event|STOP) ', ...
        'once', 'start')-1;
    hypocentreData = deblank(eventTxt(startOfHypoData:endOfHypoData));

    for n = 1:((numel(hypocentreData)+1)/140)
        hyp_end = (140*n)-1;
        hyp_start = 1+(140*(n-1));
        hypocentreData_part = hypocentreData(hyp_start:hyp_end);
        hyp_line_true = (hypocentreData_part(5)=='/') ...
            *(hypocentreData_part(8)=='/')*(hypocentreData_part(14)==':') ...
            *(hypocentreData_part(17)==':');

        while hyp_line_true == 0

            hyp_start = hyp_start + 1;
            hyp_end = hyp_end + 1;
            hypocentreData_part = hypocentreData(hyp_start:hyp_end);
            hyp_line_true = (hypocentreData_part(5)=='/') ...
                *(hypocentreData_part(8)=='/')*(hypocentreData_part(14)==':') ...
                *(hypocentreData_part(17)==':');
        end

        if hyp_line_true == 1
            hypo_part = readHypocentreData(hypocentreData_part);
        end
        if n == 1
            hypo = table;
        end
        hypo = [hypo;hypo_part]; %#ok<AGROW> 
    end

    hypo.EventID(:) = eventIds(iEvent);
    Hypocentres = [Hypocentres;hypo]; %#ok<AGROW> 

    % Extract magnitude data
    if strcmp(include_magnitudes, 'on') == 1
        startOfMagnitude = regexp(eventTxt,'Magnitude[\w\s]*OrigID','end')+1;
%         endOfMagnitude = regexp(eventTxt,'(Sta|Event|STOP|$)','once','start')-1;
        endOfMagnitude = regexp(eventTxt,'(Sta|$)','once','start')-1;
        if strcmp(include_phases, 'on') == 0
            magnitudeData = strtrim(eventTxt(startOfMagnitude:end));
        end
        if strcmp(include_phases, 'on') == 1
            magnitudeData = strtrim(eventTxt(startOfMagnitude:endOfMagnitude));
        end

%         disp('startOfMagnitude')
%         disp(startOfMagnitude)
% 
%         disp('endOfMagnitude')
%         disp(endOfMagnitude)

%         disp(magnitudeData)
% 
%         disp(eventTxt(1884:1994))
%         disp(' ')
%         disp('!!!!!')
%         disp(eventTxt)
%         disp('!!!!!')

    try
        mag = readMagnitudeData(magnitudeData);
        mag.EventID(:) = eventIds(iEvent);
        Magnitudes = [Magnitudes;mag]; %#ok<AGROW> 
    catch
        disp(magnitudeData)
    end
    
    % Extract phase data

    if strcmp(include_phases, 'on') == 1
        startOfPhase = regexp(eventTxt,'Sta[\w\s]*Depth','end') +1;

        end_while = 0;

        while end_while < 2
            if end_while == 0
                try
                    phaseData = strtrim(eventTxt(startOfPhase:end));
                    phase = readPhaseData(phaseData);
                    end_while = 2;
                catch
                    end_while = 1;
                    endOfPhase = numel(eventTxt)-1;
                    disp('ERROR: Excluding stations without locations')
                    disp(endOfPhase)
                end
            end

            if end_while == 1
                try
                    phaseData = strtrim(eventTxt(startOfPhase:endOfPhase));
                    phase = readPhaseData(phaseData);
                    end_while = 2;
                catch
                    endOfPhase = endOfPhase-1;
%                     disp('ERROR: Excluding stations without locations')
%                     disp(endOfPhase)
                end
            end
        end
        phase.EventID(:) = eventIds(iEvent);
        Phases = [Phases;phase]; %#ok<AGROW> 
    end
end
end