
function [Primes, Hypocentres, Magnitudes, Phases, FocalMechanisms] = readISCData(textData, ...
    Primes, Hypocentres, Magnitudes, Phases, FocalMechanisms, ...
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

% Define Temporary Focal Mechanism Tables
MTS = table;
FPS = table;
PAS = table;
OFM = table;

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

    prime.EventID = eventIds(iEvent);

    Primes = [Primes; prime]; %#ok<AGROW> 
  
    % Extract all comments and hypocentres to commData

    commData = deblank(eventTxt(regexp(eventTxt,'\d{4}/\d{2}/\d{2}','once','start'):regexp(eventTxt,'(Year|Magnitude|Sta|Event|STOP) ', 'once', 'start')-1));

    % Extract all hypocentres to hypocentreData

    hypocentreData = regexprep(commData,'\s\([^\n]*\)\n|\s\([^\n]*\)','');

    for n = 1:((numel(hypocentreData)+1)/140)
        
        % Define temp focal mechanism table for each hypocentre

        clear mts fps pas ofm;

        mts = table;
        fps = table;
        pas = table;
        ofm = table;

        % Extract hypocentre line

        hyp_end = (140*n)-1;
        hyp_start = 1+(140*(n-1));
        hypocentreData_part = hypocentreData(hyp_start:hyp_end);

        % Get comment hypid

        comm_hypid = hypocentreData(hyp_end-8:hyp_end); % Extract hypid as string

        % Get start of ISF comment block using hypid as pattern match

        comm_start = regexp(commData,comm_hypid);

        % Extract Comment Lines for hypocentre

        if (hyp_start+161) > length(hypocentreData)

             % If hypid + 161 is longer than hypocentreData file reached end of comment block  
             % Only relevant if hypocentre comment is the last part of
             % hypocentre block
            comm_lines = commData(comm_start+9:end); 
        else
           
            % Selects end of comment using hypid of following hypocentre 

            comm_end = regexp(commData,hypocentreData(hyp_start+270:hyp_start+279));
            comm_lines = commData(comm_start+9:comm_end-131);
        end

        % Check if comment types are present in comm_lines (ISF comment
        % block)

        clear commMT commFP commPA commVA commDC commAG commMF commRT commDT commTM;

        commMT = regexp(comm_lines,'(#MOMTENS','once','start');
        commFP = regexp(comm_lines,'(#FAULT_PLANE','once','start');   
        commPA = regexp(comm_lines,'(#PRINAX','once','start');

        commVA = regexp(comm_lines,'(varianceReduction','once','end');
        commDC = regexp(comm_lines,'(doubleCouple','once','end');
        commAG = regexp(comm_lines,'(azimuthalGap','once','end');
        commMF = regexp(comm_lines,'(misfit','once','end');
        commRT = regexp(comm_lines,'(riseTime','once','end');
        commDT = regexp(comm_lines,'(decayTime','once','end');
        commTM = regexp(comm_lines,'(\(Triangular moment-rate function|\(type triangle)','once','start');

        if length(commMT) > 0
            endMT = commMT+355; % Moment tensor block is 355 characters long
            mtData = comm_lines(commMT+188:endMT); % Extract data without header
            mtData = regexprep(mtData,'\(#|\)|(\+\s|\n',''); % Remove brackets and new lines
            mts =  readMTData(mtData,comm_hypid); % mts table defined by function readMTData
        end
        if length(commFP) > 0
            
            % Check if one or two fault planes defined

            endFP = regexp(comm_lines,'(\+')+62; % Double fault plane, comment ends here
            if endFP < 1
                endFP = (commFP+78)+50; % Single fault plane, comment ends here
            end
            fpData = comm_lines(commFP+78:endFP); % Extract data without header
            fpData = regexprep(fpData,'\(#|\)|(\+\s|\n',''); % Remove brackets and new lines
            fps = readFPData(fpData,comm_hypid); % fps table defined by function readFPData
        end
        if length(commPA) > 0
            
            if (376) >= length(comm_lines(commPA:end))
                
                % Start and end of comment for principle axis without error
                % comment
                
                startPA = commPA+93;
                endPA = commPA+164;
                typePA = 0; % Define as principle axis without error comment
            
            else
               
                check = regexp(comm_lines(commPA:commPA+376),'(\+','all','start'); % Check if principle axis error is part of comment
                if length(check) > 1
                    startPA = commPA+177;
                    endPA = commPA+330;
                    typePA = 1; % Define as principle axis with error comment
                else
                    startPA = commPA+93;
                    endPA = commPA+164;
                    typePA = 0; % Define as principle axis without error comment
                end
            end
            paData = comm_lines(startPA:endPA); % Extract data without header
            paData = regexprep(paData,'\(#|\)|(\+\s|\n',''); % Remove brackets and new lines
            pas = readPAData(paData,comm_hypid,typePA); % pas table defined by function readPAData
        end
        
        % Populate ofm table with all nan

        ofm.VarianceReduction = nan;
        ofm.DoubleCouple = nan;
        ofm.AzimuthalGap = nan;
        ofm.Misfit = nan;
        ofm.RiseTime = nan;
        ofm.DecayTime = nan;
        ofm.MomentRateType = nan;

        % Check for extra comment lines relating to Focal Mechanisms

        if length(commVA) > 0
            va = comm_lines(commVA+1:commVA+regexp(comm_lines(commVA+1:end),'\)','once','start')-1);
            ofm.VarianceReduction(1) = str2double(strip(va));
        end
        if length(commDC) > 0
            dc = comm_lines(commDC+1:commDC+regexp(comm_lines(commDC+1:end),'\)','once','start')-1);
            ofm.DoubleCouple(1) = str2double(strip(dc));
        end  
        if length(commAG) > 0
            ag = comm_lines(commAG+1:commAG+regexp(comm_lines(commAG+1:end),'\)','once','start')-1);
            ofm.AzimuthalGap(1) = str2double(strip(ag));
        end    
        if length(commMF) > 0
            mf = comm_lines(commMF+1:commMF+regexp(comm_lines(commMF+1:end),'\)','once','start')-1);
            ofm.Misfit(1) = str2double(strip(mf));
        end    
        if length(commRT) > 0
            rt = comm_lines(commRT+1:commRT+regexp(comm_lines(commRT+1:end),'\)','once','start')-1);
            ofm.RiseTime(1) = str2double(strip(rt));
        end    
        if length(commDT) > 0
            dt = comm_lines(commDT+1:commDT+regexp(comm_lines(commDT+1:end),'\)','once','start')-1);
            ofm.DecayTime(1) = str2double(strip(dt));
        end    
        if length(commTM) > 0
            tm = 1;
            ofm.MomentRateType(1) = categorical(cellstr('Triangular'));
        end   
        if any(~isnan(ofm{:,:})) % If any elements of table ofm are not nan 
            ofm.OrigID = str2double(strip(comm_hypid)); % Add hypid to table ofm
            OFM = [OFM;ofm]; %#ok<AGROW> 
        end

        MTS = [MTS;mts]; %#ok<AGROW> 
        FPS = [FPS;fps]; %#ok<AGROW>
        PAS = [PAS;pas]; %#ok<AGROW>

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

% Combine partial Focal Mechanism Tables into master Focal Mechanism table
% using the OrigID as the key

TempTable1 = outerjoin(MTS,FPS,'MergeKeys',true);
TempTable2 = outerjoin(TempTable1,PAS,'MergeKeys',true);
FocalMechanisms = outerjoin(TempTable2,OFM,'MergeKeys',true);