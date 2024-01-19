%% Info
%sheet that calls function to find reset voltage and threshold

%% add path where abfload is 
warning('off')
addpath(genpath('Z:\Luke\MATLAB_scripts\My_Whole_Cell_Data_Analysis\ABF_File_Analysis\I_clamp\universal_I_clamp\I_clamp_functions'))
%% Can run entire genotype
geno_type = dir('Z:\Luke\Electrophysiology\PV-mC4_P40_all\3.PV-mC4_P40-60_ActiveProp\PVC4^WT');%----> now manually delete all non-animal folders from geno_type
%OR
geno_type = dir('Z:\Luke\Electrophysiology\PV-mC4_P40_all\3.PV-mC4_P40-60_ActiveProp\PVC4^KI');%----> now manually delete all non-animal folders from geno_type
%% Define Global Variables
spiking_injcur = (-250:30:470)';
num_spike_sweeps = 25;
num_sag_sweeps = 14;

time_increment = 0.05;  
spiking_x_axis = 0.05:0.05:(42000*0.05);
spiking_time_s = (spiking_x_axis)';
%% This is where real code starts
progressbar('Overall Progress','PV Cells', 'PYR Cells') %init 3 bars
for z = 1:length(geno_type)
    animal = strcat(geno_type(z).folder, '\', geno_type(z).name);
%% Run one time for each animal
%animal = uigetdir('Z:\Luke\Electrophysiology\PV-mC4_P40_all\PV-mC4_P40-60_ActiveProp');
%%
PV_cells = dir(fullfile(animal, 'PV_Cell', '*cell*')); %gets all PV cells for the current animal
PYR_cells = dir(fullfile(animal, 'PYR_Cell', '*cell*')); %gets all PYR cells for the current animal

progressbar([],'','') %reset 2nd and 3rd bars
for i = 1:length(PV_cells)
    %index to specific cell from that animal, and extract paths for all the
    %spiking_files and the sag_files, should be ~3 from each
    working_cell = strcat(PV_cells(i).folder, '\', PV_cells(i).name);
    spiking_files = dir(fullfile(working_cell, 'spiking', '*.abf'));
  
 %Run spike-finder function   
 if length(spiking_files)>0
    [reset_thresh_data] = reset_V_and_thresh_finder_ALL(spiking_files, spiking_injcur, num_spike_sweeps)
    %[reset_thresh_data] = reset_V_and_thresh_finder_FIRST_SPIKE(spiking_files, spiking_injcur, num_spike_sweeps)
    %[reset_thresh_data] = reset_V_and_thresh_finder_RESTofSPIKES(spiking_files, spiking_injcur, num_spike_sweeps)
 end
 
progressbar([],i/length(PV_cells)); %update second bar
end

progressbar([],[],'') %reset third bar
for i = 1:length(PYR_cells)
    %index to specific cell from that animal, and extract paths for all the
    %spiking_files and the sag_files, should be ~3 from each
    working_cell = strcat(PYR_cells(i).folder, '\', PYR_cells(i).name);
    spiking_files = dir(fullfile(working_cell, 'spiking', '*.abf'));
  
 %Run spike-finder function   
 if length(spiking_files)>0
    [reset_thresh_data] = reset_V_and_thresh_finder_ALL(spiking_files, spiking_injcur, num_spike_sweeps)
    %[reset_thresh_data] = reset_V_and_thresh_finder_FIRST_SPIKE(spiking_files, spiking_injcur, num_spike_sweeps)
    %[reset_thresh_data] = reset_V_and_thresh_finder_RESTofSPIKES(spiking_files, spiking_injcur, num_spike_sweeps)
 end
 
progressbar([],[],i/length(PYR_cells)); 
end

progressbar(z/(length(geno_type))); %update first progressbar

end %z, geno_type loop
%close(gcf);
%close(gcf);

%% Now that all cells are analyzed, need to combine all the important data from the sheets

%Choose the folder that has he animals you want to combine
genotype_folder = uigetdir('Z:\Luke\Electrophysiology\PV-mC4_P40_all\3.PV-mC4_P40-60_ActiveProp');

PV_reset_thresh_xlsxs = dir(fullfile(genotype_folder, '*', 'PV_Cell', '*cell*', '*spiking*', '*_reset_thresh_data.xlsx'));%1

PYR_reset_thresh_xlsxs = dir(fullfile(genotype_folder, '*', 'PYR_Cell', '*cell*', '*spiking*', '*_reset_thresh_data.xlsx')); %2

%Define a couple globals
spiking_injcur = (-250:30:470)';
num_spike_sweeps = 25;

[PV_reset_thresh_finalresults, PYR_reset_thresh_finalresults] = compile_reset_thresh_data(PV_reset_thresh_xlsxs, PYR_reset_thresh_xlsxs, spiking_injcur, num_spike_sweeps) 

%Save reset_thresh PV_data
final_basefilename_PV_reset_thresh = 'PV_ALL_reset_thresh_finalresults.xlsx';%3
final_basefilename_PV_reset_thresh = char(final_basefilename_PV_reset_thresh);
final_savefilename_PV_reset_thresh = strcat(genotype_folder, '\', final_basefilename_PV_reset_thresh);
xlswrite(final_savefilename_PV_reset_thresh, PV_reset_thresh_finalresults);

%Save PYR reset_thresh
final_basefilename_PYR_reset_thresh = 'PYR_ALL_reset_thresh_finalresults.xlsx';%4
final_basefilename_PYR_reset_thresh = char(final_basefilename_PYR_reset_thresh);
final_savefilename_PYR_reset_thresh = strcat(genotype_folder, '\', final_basefilename_PYR_reset_thresh);
xlswrite(final_savefilename_PYR_reset_thresh, PYR_reset_thresh_finalresults);

%% Added 12/17/23, get baselines from _wbl file

%Choose the folder that has he animals you want to combine
genotype_folder = uigetdir('Z:\Luke\Electrophysiology\PV-mC4_P40_all\3.PV-mC4_P40-60_ActiveProp');

PV_bl_xlsxs = dir(fullfile(genotype_folder, '*', 'PV_Cell', '*cell*', '*spiking*', '*_reset_thresh_data_wbl.xlsx'));%1

PYR_bl_xlsxs = dir(fullfile(genotype_folder, '*', 'PYR_Cell', '*cell*', '*spiking*', '*_reset_thresh_data_wbl.xlsx')); %2

%Define a couple globals
spiking_injcur = (-250:30:470)';
num_spike_sweeps = 25;

[PV_bl_finalresults, PYR_bl_finalresults] = compile_bl_data(PV_bl_xlsxs, PYR_bl_xlsxs, spiking_injcur, num_spike_sweeps) 

%Save bl PV_data
final_basefilename_PV_bl = 'PV_bl_finalresults.xlsx';%3
final_basefilename_PV_bl = char(final_basefilename_PV_bl);
final_savefilename_PV_bl = strcat(genotype_folder, '\', final_basefilename_PV_bl);
xlswrite(final_savefilename_PV_bl, PV_bl_finalresults);

%Save PYR bl
final_basefilename_PYR_bl = 'PYR_bl_finalresults.xlsx';%4
final_basefilename_PYR_bl = char(final_basefilename_PYR_bl);
final_savefilename_PYR_bl = strcat(genotype_folder, '\', final_basefilename_PYR_bl);
xlswrite(final_savefilename_PYR_bl, PYR_bl_finalresults);

