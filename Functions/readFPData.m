function fps = readFPData(fpTextData,hypid)
% readFPData 
% Reads in the focal plane comment Data as a table
%
% fps = readFPData(fpTextData) reads in the fp text data and 
% returns it as a table.

formatSpec = '%3s%8s%6s%8s%4s%4s%6s%9s%16s%7s%6s%8s%4s%4s%16s';

if isempty(fpTextData)
    rawStrings = repmat({""},1,16); %#ok<STRSCALR> 
else
    rawStrings = textscan(fpTextData,formatSpec,Delimiter='',WhiteSpace='',TextType='string');
end

% Populate temporary fps table

fps = table;
fps.Type = categorical(rawStrings{1});
fps.Strike1 = double(strip(rawStrings{2}));
fps.Dip1 = double(strip(rawStrings{3}));
fps.Rake1 = double(strip(rawStrings{4}));
fps.NP1 = double(strip(rawStrings{5}));
fps.NS1 = double(strip(rawStrings{6}));
fps.Plane1 = categorical(rawStrings{7});
fps.AuthorFP = categorical(rawStrings{8});
fps.Strike2 = double(strip(rawStrings{10}));
fps.Dip2 = double(strip(rawStrings{11}));
fps.Rake2 = double(strip(rawStrings{12}));
fps.NP2 = double(strip(rawStrings{13}));
fps.NS2 = double(strip(rawStrings{14}));
fps.Plane2 = categorical(rawStrings{15});
fps.OrigID = str2double(strip(hypid));
