function mts = readMTData(mtTextData,hypid)
% readMTData 
% Reads in the moment tensor Data as a table
%
% mts = readMTData(mtTextData) reads in the moment tensor text data and 
% retuns it as a table.

formatSpec = '%2s%6s%6s%7s%7s%7s%7s%7s%7s%5s%5s%10s%12s%6s%6s%7s%7s%7s%7s%7s%7s%5s%5s%10s';

if isempty(mtTextData)
    rawStrings = repmat({""},1,25); %#ok<STRSCALR> 
else
    rawStrings = textscan(mtTextData,formatSpec,Delimiter='',WhiteSpace='',TextType='string');
end

% Populate temporary mts table

mts = table;
mts.ScaleMT = double(rawStrings{1});
mts.M0 = double(strip(rawStrings{2}));
mts.fCLVD = double(strip(rawStrings{3}));
mts.MRR = double(strip(rawStrings{4}));
mts.MTT = double(strip(rawStrings{5}));
mts.MPP = double(strip(rawStrings{6}));
mts.MRT = double(strip(rawStrings{7}));
mts.MTP = double(strip(rawStrings{8}));
mts.MPR = double(strip(rawStrings{9}));
mts.NST1 = double(strip(rawStrings{10}));
mts.NST2 = double(strip(rawStrings{11}));
mts.AuthorMT = categorical(rawStrings{12});
mts.eM0 = double(strip(rawStrings{14}));
mts.eCLVD = double(strip(rawStrings{15}));
mts.eMRR = double(strip(rawStrings{16}));
mts.eMTT = double(strip(rawStrings{17}));
mts.eMPP = double(strip(rawStrings{18}));
mts.eMRT = double(strip(rawStrings{19}));
mts.eMTP = double(strip(rawStrings{20}));
mts.eMPR = double(strip(rawStrings{21}));
mts.NCO1 = double(strip(rawStrings{22}));
mts.NCO2 = double(strip(rawStrings{23}));
mts.Duration = double(strip(rawStrings{24}));
mts.OrigID = str2double(strip(hypid));
