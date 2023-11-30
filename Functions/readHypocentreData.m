function hypo = readHypocentreData(hypocentreTextData)
% readHypocentredata
% Reads in the Hypocentre Textual Data as a table
%
% hypo = readHypocentredata(hypocenterTextData) reads in the hypocentre
% text data and retuns it as a table.

% Due to the appearance of f appneded to the depth to indicat if the
% epicenter is fixed and due to mustures of valid spaces and space
% being using as a delimiter it is best to read in the text columsn and then
% covert
formatSpec = '%10s%12s%7s%6s%9s%10s%6s%6s%4s%6s%1s%5s%5s%5s%4s%7s%7s%8s%12s%s';

if isempty(hypocentreTextData)
    rawStrings = repmat({""},1,20); %#ok<STRSCALR> 
else
    rawStrings = textscan(hypocentreTextData,formatSpec,Delimiter='',WhiteSpace='',TextType='string');
end
hypo = table;
try
    hypo.Date = datetime(rawStrings{1}+rawStrings{2},'InputFormat','yyyy/MM/dd HH:mm:ss.SS');
catch
    hypo.Date = datetime(rawStrings{1}+rawStrings{2},'InputFormat','yyyy/MM/dd HH:mm:ss');
end

try
    hypo.Err = double(rawStrings{3});
    hypo.RMS = double(rawStrings{4});
    hypo.Latitude = double(rawStrings{5});
    hypo.Longitude = double(rawStrings{6});
    hypo.Smaj = double(rawStrings{7});
    hypo.Smin = double(rawStrings{8});
    hypo.Az = double(rawStrings{9});
    hypo.Depth = double(rawStrings{10});
    hypo.EpicentreFixed = repmat("True",size(rawStrings{11}));
    hypo.EpicentreFixed(rawStrings{11} == "f") = "False";
    hypo.EpicentreFixed = categorical(hypo.EpicentreFixed);
    hypo.Err1 = double(rawStrings{12});
    hypo.Ndef = double(rawStrings{13});
    hypo.Nsta = double(rawStrings{14});
    hypo.Gap = double(rawStrings{15});
    hypo.mdist = double(rawStrings{16});
    hypo.Mdist = double(rawStrings{17});
    hypo.Qual = categorical(strip(rawStrings{18}));
    hypo.Author = categorical(strip(rawStrings{19}));
    hypo.OrigID = double(rawStrings{20});
catch
    disp('Error: Problem reading hypocentre')
end
