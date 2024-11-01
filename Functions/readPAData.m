function pas = readPAData(paTextData,hypid,typePA)
% readPhaseData 
% Reads in the principal axis comment data as a table
%
% pas = readPAData(paTextData) reads in the phase text data and 
% retuns it as a table.

% If principle axis has an error line 

if typePA == 1
    
    formatSpec = '%2s%7s%7s%6s%7s%7s%6s%7s%7s%6s%10s%11s%6s%7s%6s%7s%7s%6s%7s%7s%6s%7s';

    if isempty(paTextData)
        rawStrings = repmat({""},1,23); %#ok<STRSCALR> 
    else
        rawStrings = textscan(paTextData,formatSpec,Delimiter='',WhiteSpace='',TextType='string');
    end

    pas = table;
    pas.ScalePA = double(rawStrings{1});
    pas.Tval = double(strip(rawStrings{2}));
    pas.Tazi = double(strip(rawStrings{3}));
    pas.Tpl = double(strip(rawStrings{4}));
    pas.Bval = double(strip(rawStrings{5}));
    pas.Bazi = double(strip(rawStrings{6}));
    pas.Bpl = double(strip(rawStrings{7}));
    pas.Pval = double(strip(rawStrings{8}));
    pas.Pazi = double(strip(rawStrings{9}));
    pas.Ppl = double(strip(rawStrings{10}));
    pas.AuthorPA = categorical(rawStrings{11});
    pas.eTval = double(strip(rawStrings{13}));
    pas.eTazi = double(strip(rawStrings{14}));
    pas.eTpl = double(strip(rawStrings{15}));
    pas.eBval = double(strip(rawStrings{16}));
    pas.eBazi = double(strip(rawStrings{17}));
    pas.eBpl = double(strip(rawStrings{18}));
    pas.ePval = double(strip(rawStrings{19}));
    pas.ePazi = double(strip(rawStrings{20}));
    pas.ePpl = double(strip(rawStrings{21}));
    pas.fCLVD_pa = double(strip(rawStrings{22}));
    pas.OrigID = str2double(strip(hypid));

% If principle axis does not have an error line 

else
    
    formatSpec = '%2s%7s%7s%6s%7s%7s%6s%7s%7s%6s%10s';
    
    if isempty(paTextData)
        rawStrings = repmat({""},1,12); %#ok<STRSCALR> 
    else
        rawStrings = textscan(paTextData,formatSpec,Delimiter='',WhiteSpace='',TextType='string');
    end
   
    pas = table;
    pas.ScalePA = double(rawStrings{1});
    pas.Tval = double(strip(rawStrings{2}));
    pas.Tazi = double(strip(rawStrings{3}));
    pas.Tpl = double(strip(rawStrings{4}));
    pas.Bval = double(strip(rawStrings{5}));
    pas.Bazi = double(strip(rawStrings{6}));
    pas.Bpl = double(strip(rawStrings{7}));
    pas.Pval = double(strip(rawStrings{8}));
    pas.Pazi = double(strip(rawStrings{9}));
    pas.Ppl = double(strip(rawStrings{10}));
    pas.AuthorPA = categorical(rawStrings{11});
    pas.eTval = nan;
    pas.eTazi = nan;
    pas.eTpl = nan;
    pas.eBval = nan;
    pas.eBazi = nan;
    pas.eBpl = nan;
    pas.ePval = nan;
    pas.ePazi = nan;
    pas.ePpl = nan;
    pas.fCLVD_pa = nan;
    pas.OrigID = str2double(strip(hypid));
end
