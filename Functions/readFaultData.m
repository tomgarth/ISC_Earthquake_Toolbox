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
        if i == 1
            header=faults(1);
        else
            header=faults(2);
        end
        bird_faults{1,i}=header{1}(1:5);
        bird_faults{2,i}=header{1}(3);
        fault=faults(3:end-1);
        bird_faults{3,i} = split(fault,",");

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
    
    %%% Get individual GEM Faults

    gem_all = extractBetween(gem_data,"<Placemark>","</Placemark>");

    %%% Create Cell Structure for GEM Faults

    gem_faults = {};

    for iii = 1:length(gem_all)

        %%% GEM Fault Name

        gem_name = extractBetween(gem_all(iii),"<name>","</name>");

        %%% GEM Fault Type

        gem_type = extractBetween(gem_all(iii),"<SimpleData name=""slip_type"">","</SimpleData>");

        %%% Get GEM Fault coordinates
    
        gem_out = extractBetween(gem_all(iii),"<LineString><coordinates>","</coordinates></LineString>");

        %%% Get Coordinates from GEM Fault Segments

        faults = split(gem_out," ");
        gem_faults{1,iii} = gem_name;
        gem_faults{2,iii} = gem_type;
        gem_faults{3,iii} = split(faults,",");

    end

    %%% Save GEM Faults to gem_faults.mat in Fault_Data folder

    save(fullfile(sprintf('%s',fault_folder.path),"gem_faults.mat"),"gem_faults");

else

    %%% Load GEM fault data from file

    load(fullfile(sprintf('%s',fault_folder.path),"gem_faults.mat"));

end