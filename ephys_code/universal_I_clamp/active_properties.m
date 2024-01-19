%% Info
%This is to analyze (i) spiking (-250 start, 25 sweeps, 30pA steps) and
%(ii) sag (-500pA start,50 pA steps, 15? sweeps)


%LAF 2023/1/29 - added fits to find tau in active_data_spiking.m
%is Cm in active_data_spiking off by 1 decimal point? seems too high?

%% add path where abfload is 
warning('off')
addpath('Z:\Luke\MATLAB_scripts\My_Whole_Cell_Data_Analysis\ABF_File_Analysis\I_clamp\universal_I_clamp\I_clamp_functions')
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
%% This just adds a gif, not necessary at all
f=figure
x = f.Position;
x(1) = x(1)-x(3);
f.Position = x;
gifplayer('D:\Users\Luke_Fournier\Downloads\cute_neuron2.gif',0.04);
f2=figure
gifplayer('D:\Users\Luke_Fournier\Downloads\cute_neuron.gif',0.04);
x1 = f2.Position;
x1(1) = x1(1)+(x1(3)/2);
x1(3) = 1000
x1(4) = x(4)
f2.Position = x1;
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
    sag_files = dir(fullfile(working_cell, 'sag', '*.abf'));
  
 %Run spike-finder function   
 if length(spiking_files)>0
    [spiking_data, path_parts] = active_data_spiking(spiking_files, time_increment, spiking_injcur, num_spike_sweeps, spiking_time_s)
 end
 
 %Run sag-finder function
 if length(sag_files)>0
    [sag_data] = active_data_sag(sag_files,sag_injcur, num_sag_sweeps, spiking_time_s)
 end
 
progressbar([],i/length(PV_cells)); %update second bar
end

progressbar([],[],'') %reset third bar
for i = 1:length(PYR_cells)
    %index to specific cell from that animal, and extract paths for all the
    %spiking_files and the sag_files, should be ~3 from each
    working_cell = strcat(PYR_cells(i).folder, '\', PYR_cells(i).name);
    spiking_files = dir(fullfile(working_cell, 'spiking', '*.abf'));
    sag_files = dir(fullfile(working_cell, 'sag', '*.abf'));
  
 %Run spike-finder function   
 if length(spiking_files)>0
    [spiking_data, path_parts] = active_data_spiking(spiking_files, time_increment, spiking_injcur, num_spike_sweeps, spiking_time_s)
 end
 
%Run sag-finder function
 if length(sag_files)>0
    [sag_data] = active_data_sag(sag_files,sag_injcur, num_sag_sweeps, spiking_time_s)
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

%PV_spiking_xlsxs = dir(fullfile(genotype_folder, '*', 'PV_Cell', '*cell*', '*spiking*', '*spikingdata.xlsx'));
PV_IEI230_xlsxs = dir(fullfile(genotype_folder, '*', 'PV_Cell', '*cell*', '*spiking*', '*260pA_IEI_data.xlsx')); %THIS IS REALLY 260
%PV_IEI440_xlsxs = dir(fullfile(genotype_folder, '*', 'PV_Cell', '*cell*', '*spiking*', '*440pA_IEI_data.xlsx'));
%PV_sag_folders = dir(fullfile(genotype_folder, '*', 'PV_Cell', '*cell*', 'sag', '*.xlsx'));

%PYR_spiking_xlsxs = dir(fullfile(genotype_folder, '*', 'PYR_Cell', '*cell*', 'spiking', '*spikingdata.xlsx'));
PYR_IEI230_xlsxs = dir(fullfile(genotype_folder, '*', 'PYR_Cell', '*cell*', 'spiking', '*260pA_IEI_data.xlsx')); %THIS IS REALLY 260
%PYR_IEI440_xlsxs = dir(fullfile(genotype_folder, '*', 'PYR_Cell', '*cell*', 'spiking', '*440pA_IEI_data.xlsx'));
%PYR_sag_folders = dir(fullfile(genotype_folder, '*', 'PYR_Cell', '*cell*', 'sag', '*.xlsx'))

%all_spiking_folders = dir(fullfile(genotype_folder, '*', '*', '*cell*', 'spiking', '*.xlsx'));
%all_sag_fodlers = dir(fullfile(genotype_folder, '*', '*', '*cell*', 'sag', '*.xlsx'));

%Define a couple globals
spiking_injcur = (-250:30:470)';
sag_injcur = (-500:50:150)';
num_spike_sweeps = 25;
num_sag_sweeps = 14;

%%Combine spiking results
%[PV_spiking_finalresults, PYR_spiking_finalresults] = compile_spiking(PV_spiking_xlsxs, PYR_spiking_xlsxs, num_spike_sweeps, spiking_injcur)

%Combine IEI 230 results %THIS IS REALLY 260
[PV_IEI_230_finalresults, PYR_IEI_230_finalresults] = compile_IEI_230(PV_IEI230_xlsxs, PYR_IEI230_xlsxs) %THIS IS REALLY 260
%%Combine IEI 440 results
%[PV_IEI_440_finalresults, PYR_IEI_440_finalresults] = compile_IEI_440(PV_IEI440_xlsxs, PYR_IEI440_xlsxs)

%%Combine sag results
%[PV_sag_finalresults, PYR_sag_finalresults] = compile_sag(PV_sag_folders, PYR_sag_folders, num_sag_sweeps, sag_injcur)



% %Save PV spiking
% final_basefilename_PVspiking = 'PV_spiking_finalresults.xlsx';
% final_basefilename_PVspiking = char(final_basefilename_PVspiking);
% final_savefilename_PVspiking = strcat(genotype_folder, '\', final_basefilename_PVspiking);
% xlswrite(final_savefilename_PVspiking, PV_spiking_finalresults);

%Save PV IEI 260
final_basefilename_PV_IEI_230 = 'PV_IEI_260_finalresults.xlsx';
final_basefilename_PV_IEI_230 = char(final_basefilename_PV_IEI_230);
final_savefilename_PV_IEI_230 = strcat(genotype_folder, '\', final_basefilename_PV_IEI_230);
xlswrite(final_savefilename_PV_IEI_230, PV_IEI_230_finalresults);

%%Save PV IEI 440
% final_basefilename_PV_IEI_440 = 'PV_IEI_440_finalresults.xlsx';
% final_basefilename_PV_IEI_440 = char(final_basefilename_PV_IEI_440);
% final_savefilename_PV_IEI_440 = strcat(genotype_folder, '\', final_basefilename_PV_IEI_440);
% xlswrite(final_savefilename_PV_IEI_440, PV_IEI_440_finalresults);
% 
% %Save PV sag
% final_basefilename_PVsag = 'PV_sag_finalresults.xlsx';
% final_basefilename_PVsag = char(final_basefilename_PVsag);
% final_savefilename_PVsag = strcat(genotype_folder, '\', final_basefilename_PVsag);
% xlswrite(final_savefilename_PVsag, PV_sag_finalresults);

% %Save PYR spiking
% final_basefilename_PYRspiking = 'PYR_spiking_finalresults.xlsx';
% final_basefilename_PYRspiking = char(final_basefilename_PYRspiking);
% final_savefilename_PYRspiking = strcat(genotype_folder, '\', final_basefilename_PYRspiking);
% xlswrite(final_savefilename_PYRspiking, PYR_spiking_finalresults);

%Save PYR IEI 260
final_basefilename_PYR_IEI_230 = 'PYR_IEI_260_finalresults.xlsx';
final_basefilename_PYR_IEI_230 = char(final_basefilename_PYR_IEI_230);
final_savefilename_PYR_IEI_230 = strcat(genotype_folder, '\', final_basefilename_PYR_IEI_230);
xlswrite(final_savefilename_PYR_IEI_230, PYR_IEI_230_finalresults);

%Save PYR IEI 440
% final_basefilename_PYR_IEI_440 = 'PYR_IEI_440_finalresults.xlsx';
% final_basefilename_PYR_IEI_440 = char(final_basefilename_PYR_IEI_440);
% final_savefilename_PYR_IEI_440 = strcat(genotype_folder, '\', final_basefilename_PYR_IEI_440);
% xlswrite(final_savefilename_PYR_IEI_440, PYR_IEI_440_finalresults);

% %Save PYR sag
% final_basefilename_PYRsag = 'PYR_sag_finalresults.xlsx';
% final_basefilename_PYRsag = char(final_basefilename_PYRsag);
% final_savefilename_PYRsag = strcat(genotype_folder, '\', final_basefilename_PYRsag);
% xlswrite(final_savefilename_PYRsag, PYR_sag_finalresults);
