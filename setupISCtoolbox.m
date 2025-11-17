function setupISCtoolbox()

folder = fileparts(mfilename("fullpath"));
addpath( fullfile(folder,"Functions") );
addpath( fullfile(folder,"Functions/focalmech") );
addpath( fullfile(folder,"Functions/altmany-export_fig-3/") );
addpath( fullfile(folder,"Data") );
addpath( fullfile(folder,"Data/Downloaded_ISC_Data") );
addpath( fullfile(folder,"Data/Example_ISC_Data") );

addpath( folder )
% addpath Functions/
