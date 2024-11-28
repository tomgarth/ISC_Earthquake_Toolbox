function [bird_faults,gem_faults] = readFaultData()

%%% Check path to Fault_Data Folder

fault_folder = what('Fault_Data');

%%% Check if Bird and GEM Fault files exist

bird_test = exist(fullfile(sprintf('%s',fault_folder.path),"bird_faults.mat"));
gem_test = exist(fullfile(sprintf('%s',fault_folder.path),"gem_faults.mat"));

%%% Set timeout period

options = weboptions('Timeout', 360);

%%% If Bird fault data not already downloaded

if bird_test == 0

    %%% URL for Bird Faults 
    
    bird_url = 'http://peterbird.name/oldFTP/PB2002/PB2002_boundaries.dig.txt';
    
    %%% Download Bird Faults from URL

    bird_data = webread(bird_url,options);
    
    %%% Split Bird Faults into individual Fault Segments
    
    bird_out = split(bird_data,"*** end of line segment ***");

    %%% Create Cell Structure for Bird Faults

    bird_faults = {};

    %%% Loop over Bird Fault Segments

    for i = 1:length(bird_out)-1

        %%% Get Coordinates from Bird Fault Segments

        faults=splitlines(bird_out(i));
        fault=faults(3:end-1);
        bird_faults{1,i} = split(fault,",");

    end

    %%% Save Bird Faults to bird_faults.mat in Fault_Data folder

    save(fullfile(sprintf('%s',fault_folder.path),"bird_faults.mat"),"bird_faults");

%%% If Bird fault data already downloaded 

else

    %%% Load Bird fault data from file

    load(fullfile(sprintf('%s',fault_folder.path),"bird_faults.mat"));

end

%%% If GEM fault data not already downloaded

if gem_test == 0

    %%% URL for GEM Faults 

    gem_url = 'https://raw.githubusercontent.com/GEMScienceTools/gem-global-active-faults/refs/heads/master/kml/gem_active_faults_harmonized.kml';
    
    %%% Download GEM Faults from URL
    
    gem_data = webread(gem_url,options);
    
    %%% Split GEM Faults into individual Fault Segments
    
    gem_out = extractBetween(gem_data,"<LineString><coordinates>","</coordinates></LineString>");

    %%% Create Cell Structure for GEM Faults

    gem_faults = {};

    %%% Loop over GEM Fault Segments

    for ii = 1:length(gem_out)

        %%% Get Coordinates from GEM Fault Segments

        faults = split(gem_out(ii)," ");
        gem_faults{1,ii} = split(faults,",");

    end

    %%% Save GEM Faults to gem_faults.mat in Fault_Data folder

    save(fullfile(sprintf('%s',fault_folder.path),"gem_faults.mat"),"gem_faults");

else

    %%% Load GEM fault data from file

    load(fullfile(sprintf('%s',fault_folder.path),"gem_faults.mat"));

end