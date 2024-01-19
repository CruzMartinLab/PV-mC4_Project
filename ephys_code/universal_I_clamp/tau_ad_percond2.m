%% Info
%specifically for finding ISI 1, 4, and 9 of the first sweep with 10 spikes

%% add path where abfload is 
warning('off')
addpath(genpath('Z:\Luke\MATLAB_scripts\My_Whole_Cell_Data_Analysis\ABF_File_Analysis\I_clamp\universal_I_clamp\I_clamp_functions'));
%% Can run entire genotype
geno_type = dir('Z:\Luke\Electrophysiology\PV-mC4_P40_all\3.PV-mC4_P40-60_ActiveProp\PVC4^WT');%----> now manually delete all non-animal folders from geno_type
%OR
geno_type = dir('Z:\Luke\Electrophysiology\PV-mC4_P40_all\3.PV-mC4_P40-60_ActiveProp\PVC4^KI');%----> now manually delete all non-animal folders from geno_type
%% Define Global Variables
spiking_injcur = (-10:30:470)';
num_spike_sweeps = 17;

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
    
    if length(spiking_files)>0
        [export_inst_firing] = inst_firing_percond_finder2(spiking_files, num_spike_sweeps, spiking_injcur);
    end

    if i == 1
        animal_PV_inst_firing_data = export_inst_firing;
    else
        animal_PV_inst_firing_data = vertcat(animal_PV_inst_firing_data, export_inst_firing);
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
        [export_inst_firing] = inst_firing_percond_finder2(spiking_files, num_spike_sweeps, spiking_injcur);
    end

    if i == 1
        animal_PYR_inst_firing_data = export_inst_firing;
    else
        animal_PYR_inst_firing_data = vertcat(animal_PYR_inst_firing_data, export_inst_firing);
    end
 
progressbar([],[],i/length(PYR_cells)); 
end







if length(PYR_cells) > 0 %only enter loop if that animal had any PYR
    if exist('PYR_inst_firing_data', 'var') == 0 %if it doesnt exist
        PYR_inst_firing_data = animal_PYR_inst_firing_data; %start cell array that will hold all the data
    else %if it does already exist
        PYR_inst_firing_data = vertcat(PYR_inst_firing_data, animal_PYR_inst_firing_data); %concatenate newest animal to bottom of growing cell array
    end
    
    clearvars animal_PYR_inst_firing_data %clear it, will be remade next animal
end


if length(PV_cells) > 0 
    if exist('PV_inst_firing_data', 'var') == 0
        PV_inst_firing_data = animal_PV_inst_firing_data;
    else
        PV_inst_firing_data = vertcat(PV_inst_firing_data, animal_PV_inst_firing_data);
    end
    
    clearvars animal_PV_inst_firing_data
end

progressbar(z/(length(geno_type))); %update first progressbar

end %z, geno_type loop

% PYR_tauad_data = sortrows(PYR_tauad_data,1, 'descend'); %not necessary
% PV_tauad_data = sortrows(PV_tauad_data,1, 'descend'); %not necessary
%%

PYR_M_cell_array = PYR_inst_firing_data;
deleteif_F = cell2mat(PYR_M_cell_array(:,1)) == 'F';
PYR_M_cell_array(deleteif_F,:) = [];

PYR_F_cell_array = PYR_inst_firing_data;
deleteif_M = cell2mat(PYR_F_cell_array(:,1)) == 'M';
PYR_F_cell_array(deleteif_M,:) = [];

PV_M_cell_array = PV_inst_firing_data;
deleteif_F = cell2mat(PV_M_cell_array(:,1)) == 'F';
PV_M_cell_array(deleteif_F,:) = [];

PV_F_cell_array = PV_inst_firing_data;
deleteif_M = cell2mat(PV_F_cell_array(:,1)) == 'M';
PV_F_cell_array(deleteif_M,:) = [];





% A= PYR_M_cell_array;
% uniqueCol1 = unique(A(:,2))
% uniqueCol1(:,1) = cell2mat(uniqueCol1(2,1))
% counts = histogram(A(:,2), uniqueCol1)




A = PYR_M_cell_array;
[all_averaged_data_carray] = cell_cell_inst_firing(A);
PYR_M_carray = all_averaged_data_carray;
clear A all_averaged_data_carray

A = PYR_F_cell_array;
[all_averaged_data_carray] = cell_cell_inst_firing(A);
PYR_F_carray = all_averaged_data_carray;
clear A all_averaged_data_carray

A = PV_M_cell_array;
[all_averaged_data_carray] = cell_cell_inst_firing(A);
PV_M_carray = all_averaged_data_carray;
clear A all_averaged_data_carray

A = PV_F_cell_array;
[all_averaged_data_carray] = cell_cell_inst_firing(A);
PV_F_carray = all_averaged_data_carray;
clear A all_averaged_data_carray





%%YOU ARE HERE        
A = PYR_M_carray(:,2:end);
[all_averaged_data_mat, stdVal_array] = final_inst_firing(A);
PYR_M_mat = all_averaged_data_mat;
PYR_M_std_mat = stdVal_array;
clear A all_averaged_data_mat stdVal_array   

A = PYR_F_carray(:,2:end);
[all_averaged_data_mat, stdVal_array] = final_inst_firing(A);
PYR_F_mat = all_averaged_data_mat;
PYR_F_std_mat = stdVal_array;
clear A all_averaged_data_mat stdVal_array   
    
A = PV_M_carray(:,2:end);
[all_averaged_data_mat, stdVal_array] = final_inst_firing(A);
PV_M_mat = all_averaged_data_mat;
PV_M_std_mat = stdVal_array;
clear A all_averaged_data_mat stdVal_array   

A = PV_F_carray(:,2:end);
[all_averaged_data_mat, stdVal_array] = final_inst_firing(A);
PV_F_mat = all_averaged_data_mat;
PV_F_std_mat = stdVal_array;
clear A all_averaged_data_mat stdVal_array  


    
    

    
    

    
%     working_mat_copy = working_mat;
%     
%     working_mat_copy(2:end,11) = bins;
%     working_mat_copy(2:length(meanVal)+1,12) = meanVal;
%     
%     [~,dup_idx] = unique(working_mat_copy(:,11),'stable');
%     working_mat_copy = working_mat_copy(dup_idx,11);
%     
%     
%     
%     
%     
%     
%     edges = 1:5:501;
%     working_mat_xs = working_mat(:,1:2:end);
%     
%     which_bin = discretize(working_mat_xs, edges);
%     
%     which_bin = which_bin*5
%     
%     plot(which_bin(2:end,end), working_mat(2:end,34), 'r*')
%     
%     binned_working_mat = working_mat;
%     binned_working_mat(:,1:2:end) = which_bin(:,:);
%     
%     [meanVal, maxVal, stdVal] = grpstats(binned_working_mat(:,12),which_bin,{@mean, @max, @std});
%     
%     
%     for iii = 1:length(working_mat) 
%     
%     
%     
%     
%     
%     
%     
%     
%     
%     
%     
% %KEEP THIS
% for i = 3:19 %for -10pA - 470pA
%     
%     insert = vertcat(cell2mat(PYR_M_cell_array(:,i)));
%     PYR_M_mat(2:(length(insert)+1),((i-2)*2-1):((i-2)*2)) = insert;
%     clearvars insert
%     
%     insert = vertcat(cell2mat(PYR_F_cell_array(:,i)));
%     PYR_F_mat(2:(length(insert)+1),((i-2)*2-1):((i-2)*2)) = insert;
%     clearvars insert
%     
%     insert = vertcat(cell2mat(PV_M_cell_array(:,i)));
%     PV_M_mat(2:(length(insert)+1),((i-2)*2-1):((i-2)*2)) = insert;
%     clearvars insert
%     
%     insert = vertcat(cell2mat(PV_F_cell_array(:,i)));
%     PV_F_mat(2:(length(insert)+1),((i-2)*2-1):((i-2)*2)) = insert;
%     clearvars insert
%     
% end
% 
% 
% I_inj = -10:30:470;
% 
% PYR_M_mat(1,1:2:end) = I_inj;
% PYR_M_mat(1,2:2:end) = I_inj;
% 
% PYR_F_mat(1,1:2:end) = I_inj;
% PYR_F_mat(1,2:2:end) = I_inj;
% 
% PV_M_mat(1,1:2:end) = I_inj;
% PV_M_mat(1,2:2:end) = I_inj;
% 
% PV_F_mat(1,1:2:end) = I_inj;
% PV_F_mat(1,2:2:end) = I_inj;
% 
% 
% 
% % 
% % plot(PYR_M_mat(2:end,33), PYR_M_mat(2:end,34), '*r');
% % plot(PYR_F_mat(2:end,33), PYR_F_mat(2:end,34), '*r');
% % plot(PV_M_mat(2:end,33), PV_M_mat(2:end,34), '*r');
% % plot(PV_F_mat(2:end,33), PV_F_mat(2:end,34), '*r');


%%
I_inj = -10:30:470;

%PYR M
cell_sex_mat = PYR_M_mat;
cell_sex_std = PYR_M_std_mat;
is_PYR = 1;
celltype_sex = 'PYR M';
[tauad_fad] = find_tauad_and_fad2(cell_sex_mat, cell_sex_std, I_inj, is_PYR, celltype_sex, num_spike_sweeps); 
PYR_M_tauad_fad = tauad_fad;
clear tauad_fad cell_sex_mat cell_sex_std
savemultfigs

%PYR F
cell_sex_mat = PYR_F_mat;
cell_sex_std = PYR_F_std_mat;
is_PYR = 1;
celltype_sex = 'PYR F';
[tauad_fad] = find_tauad_and_fad2(cell_sex_mat, cell_sex_std, I_inj, is_PYR, celltype_sex, num_spike_sweeps); 
PYR_F_tauad_fad = tauad_fad;
clear tauad_fad cell_sex_mat cell_sex_std
savemultfigs

%PV M
cell_sex_mat = PV_M_mat;
cell_sex_std = PV_M_std_mat;
is_PYR = 0;
celltype_sex = 'PV M';
[tauad_fad] = find_tauad_and_fad2(cell_sex_mat, cell_sex_std, I_inj, is_PYR, celltype_sex, num_spike_sweeps); 
PV_M_tauad_fad = tauad_fad;
clear tauad_fad cell_sex_mat cell_sex_std
savemultfigs

%PV F
cell_sex_mat = PV_F_mat;
cell_sex_std = PV_F_std_mat;
is_PYR = 0;
celltype_sex = 'PV F';
[tauad_fad] = find_tauad_and_fad2(cell_sex_mat, cell_sex_std, I_inj, is_PYR, celltype_sex, num_spike_sweeps); 
PV_F_tauad_fad = tauad_fad;
clear tauad_fad cell_sex_mat cell_sex_std
savemultfigs
 

%% Now that all cells are analyzed, need to combine all the important data from the sheets

genotype_folder = geno_type(1).folder;


%Save PYR_M tauad_fad
tauad_fad_finalresults = PYR_M_tauad_fad;
final_basefilename_tauad_fad = 'PYR_M_tauad_fad_finalresults.xlsx';
compile_tauad_fad_percond(final_basefilename_tauad_fad, genotype_folder,tauad_fad_finalresults);
clear tauad_fad_finalresults

%Save PYR_F tauad_fad
tauad_fad_finalresults = PYR_F_tauad_fad;
final_basefilename_tauad_fad = 'PYR_F_tauad_fad_finalresults.xlsx';
compile_tauad_fad_percond(final_basefilename_tauad_fad, genotype_folder,tauad_fad_finalresults);
clear tauad_fad_finalresults

%Save PV_M tauad_fad
tauad_fad_finalresults = PV_M_tauad_fad;
final_basefilename_tauad_fad = 'PV_M_tauad_fad_finalresults.xlsx';
compile_tauad_fad_percond(final_basefilename_tauad_fad, genotype_folder,tauad_fad_finalresults);
clear tauad_fad_finalresults

%Save PV_F tauad_fad
tauad_fad_finalresults = PV_F_tauad_fad;
final_basefilename_tauad_fad = 'PV_F_tauad_fad_finalresults.xlsx';
compile_tauad_fad_percond(final_basefilename_tauad_fad, genotype_folder,tauad_fad_finalresults);
clear tauad_fad_finalresults
