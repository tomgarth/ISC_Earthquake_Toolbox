function phases = readPhaseData(phaseTextData)
% readPhaseData 
% Reads in the phase Data as a table from the ISF data
%
% phases = readPhaseData(phaseTextData) reads in the phase text data and 
% retuns it as a table.


formatSpec = '%5s%7s%6s%10s%12s%6s%6s%6s%7s%8s%1s%1s%1s%6s%10s%7s%1s%1s%1s%6s%1s%5s%11s%6s%9s%3s%6s%6s%5s%4s%1s%9s%10s%8s%7s';

% disp ('!!!!!!! Line 16 !!!!!!!!!')
% % disp(phaseTextData)
% % disp ('!!!!!!! Line 18 !!!!!!!!!')
% n_count = numel(phaseTextData); disp(n_count)
% n_max   = round(n_count / 200);
% 
% for n = 1:n_max
% 
%     string_start = ((n-1)*200) + 1; % disp(string_start);
%     string_end   = n*300; % disp(string_end);
%     % disp ('!!!!!!!!!!!!!!!!!!!!!!!!!');
% 
% %     disp(phaseTextData(string_start:string_end));
% 
%     if string_end < n_count
% 
% %         disp(phaseTextData(string_start+0:string_start+190));
% % 
% %         disp(phaseTextData(string_start+169));
% % 
% %         disp ('!!!!!!! Line 36 !!!!!!!!!')
% 
%         if phaseTextData(string_start+169) ~= '.'
% 
% %             disp(phaseTextData(string_start+169));
%             phaseTextData(string_start+168:string_start+170) = 'NaN';
% %             disp(phaseTextData(string_start+150:string_start+210));
% %             disp(' ');
% 
%             disp ('!!!!!! Line 45 !!!!!!!!!');
% 
%             disp(' ');
%         end
%     end
% 
% end
% 
% disp ('!!!!!! Line 53 !!!!!!!!!');

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

% tmp = rawStrings{32};
% numel(tmp);

% disp(rawStrings{32})
% disp(rawStrings{33})

% tmp_data = rawStrings{32};
% disp ('tmp_data:')
% disp (numel(tmp_data))
% 
% disp (tmp_data(999))
% % disp (tmp_data(numel(tmp_data)))
% disp (numel(tmp_data(numel(tmp_data))))
% disp ('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
% 
% for n = 1:numel(tmp_data)
%     try
%         tmp = float(tmp_data(n));
%     catch
%         tmp_data(n) = 'NaN';
%     end
% end

% disp (tmp)
% disp (numel(tmp_data(numel(tmp_data))))
% rawStrings{32} = tmp_data;
% disp ('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
% 
% disp ('tmp_data 2:')
% disp (numel(tmp_data(numel(tmp_data))))
% disp ('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
% disp (numel(tmp_data(999)))

% for n = 1:numel(tmp_data)
% 
%     if tmp_data(n)) == ' '
%         disp (tmp_data(n))
%     end
% end
% 
% tmp_data(999) = ' 5555555 ';
% rawStrings{32} = tmp_data;

% tmp_data = rawStrings{32};
% disp ('tmp_data:')
% disp (tmp_data(1))
% disp (tmp_data(999))

% disp ('!!!!! line 142 !!!!!')
% 
% disp(rawStrings{32});
% disp(rawStrings{33});

phases.StaLat = double(rawStrings{32});
phases.StaLon = double(rawStrings{33});

