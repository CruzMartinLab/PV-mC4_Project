%% Info
%specifically for finding ISI 1, 4, and 9 of the first sweep with 10 spikes

%% add path where abfload is 
warning('off')
addpath(genpath('Z:\Luke\MATLAB_scripts\My_Whole_Cell_Data_Analysis\ABF_File_Analysis\I_clamp\universal_I_clamp\I_clamp_functions'))
%% Can run entire genotype
geno_type = dir('Z:\Luke\Electrophysiology\PV-mC4_P40_all\3.PV-mC4_P40-60_ActiveProp\PVC4^WT');%----> now manually delete all non-animal folders from geno_type
%OR
geno_type = dir('Z:\Luke\Electrophysiology\PV-mC4_P40_all\3.PV-mC4_P40-60_ActiveProp\PVC4^KI');%----> now manually delete all non-animal folders from geno_type
%% Define Global Variables
spiking_injcur = (-250:30:470)';
sag_injcur = (-500:50:150)';
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
    [ISI_data] = ISI_finder(spiking_files, num_spike_sweeps)
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
   [ISI_data] = ISI_finder(spiking_files, num_spike_sweeps)
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

PV_ISI_xlsxs = dir(fullfile(genotype_folder, '*', 'PV_Cell', '*cell*', '*spiking*', '*_ISI_data.xlsx'));

PYR_ISI_xlsxs = dir(fullfile(genotype_folder, '*', 'PYR_Cell', '*cell*', '*spiking*', '*_ISI_data.xlsx')); 

[PV_ISI_finalresults, PYR_ISI_finalresults] = compile_ISI_data(PV_ISI_xlsxs, PYR_ISI_xlsxs) 

%Save PV ISI data
final_basefilename_PV_reset_thresh = 'PV_ISI_finalresults.xlsx';
final_basefilename_PV_reset_thresh = char(final_basefilename_PV_reset_thresh);
final_savefilename_PV_reset_thresh = strcat(genotype_folder, '\', final_basefilename_PV_reset_thresh);
xlswrite(final_savefilename_PV_reset_thresh, PV_ISI_finalresults);

%Save PYR ISI fsys
final_basefilename_PYR_reset_thresh = 'PYR_ISI_finalresults.xlsx';
final_basefilename_PYR_reset_thresh = char(final_basefilename_PYR_reset_thresh);
final_savefilename_PYR_reset_thresh = strcat(genotype_folder, '\', final_basefilename_PYR_reset_thresh);
xlswrite(final_savefilename_PYR_reset_thresh, PYR_ISI_finalresults);
