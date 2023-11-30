function mag = readMagnitudeData(magnitudeTextData)
% readMagnitudeData 
% Reads in the Magnitude Text Data as a table
%
% mag = readMagnitudeData(magnitudeTextData) reads in the magnitude
% text data and retuns it as a table.

% Due to valid spaces and space being using as a delimiter it is best to
% read in the text columns and then covert

fmtString = '%6s%5s%4s%5s%12s%9s';

rawStrings = textscan(magnitudeTextData, fmtString, Delimiter='', ...
    WhiteSpace='', TextType='string');

mag = table;
mag.MagnitudeType = categorical(strip(rawStrings{1}));
mag.Magnitude = double(rawStrings{2});
mag.Err = double(rawStrings{3});
mag.Nsta = double(rawStrings{4});
mag.Author = categorical(strip(rawStrings{5}));
mag.OrigID = double(rawStrings{6});

end