function phases = readPhaseData(phaseTextData)
% readPhaseData 
% Reads in the Hypocentre Textual Data as a table
%
% phases = readPhaseData(phaseTextData) reads in the phase text data and 
% retuns it as a table.

% Due to the appearance of f appneded to the depth to indicat if the
% epicenter is fixed and due to mustures of valid spaces and space
% being using as a delimiter it is best to read in the text columsn and then
% covert


formatSpec = '%5s%7s%6s%10s%12s%6s%6s%6s%7s%8s%1s%1s%1s%6s%10s%7s%1s%1s%1s%6s%1s%5s%11s%6s%9s%3s%6s%6s%5s%4s%1s%9s%10s%8s%7s';
 
if isempty(phaseTextData)
    rawStrings = repmat({""},1,35); %#ok<STRSCALR> 
else
    rawStrings = textscan(phaseTextData,formatSpec,Delimiter='',WhiteSpace='',TextType='string');
end

phases = table;
phases.Sta = categorical(rawStrings{1});
phases.Dist = double(strip(rawStrings{2}));
phases.EvAz = double(rawStrings{3});
phases.Phase = categorical(strip(rawStrings{4}));
phases.Time = timeofday(datetime(rawStrings{5},'InputFormat','HH:mm:ss.SSS'));
phases.TRes = double(rawStrings{6});
phases.Azim = double(rawStrings{7});
phases.AzRes = double(rawStrings{8});
phases.Slow = double(rawStrings{9});
phases.SlowRes = double(rawStrings{10});
phases.Tdef = categorical(rawStrings{11});
phases.Adef = categorical(rawStrings{12});
phases.Sdef = categorical(rawStrings{13});
phases.SNR = double(rawStrings{14});
phases.Amp = double(rawStrings{15});
phases.Per = double(rawStrings{16});
phases.Pick = categorical(rawStrings{17});
phases.Pol = categorical(rawStrings{18});
phases.Qual = categorical(rawStrings{19});
phases.MagType = categorical(strip(rawStrings{20}));
phases.MinMax = categorical(rawStrings{21});
phases.Mag = categorical(rawStrings{22});
phases.ArrID = double(rawStrings{23});
phases.Agency = categorical(strip(rawStrings{24}));
phases.Deploy = categorical(strip(rawStrings{25}));
phases.Loc = categorical(strip(rawStrings{26}));
phases.Auth = categorical(strip(rawStrings{27}));
phases.Report = categorical(rawStrings{28});
phases.Chan = categorical(strip(rawStrings{29}));
phases.AChan = categorical(rawStrings{30});
phases.LpFm = categorical(rawStrings{31});
phases.StaLat = double(rawStrings{32});
phases.StaLon = double(rawStrings{33});
phases.StaElev = double(rawStrings{34});
phases.InsDepth = double(rawStrings{35});

end