function [ISI_data] = ISI_finder(spiking_files, num_spike_sweeps)

%Initial set up of spiking_data cell array
ISI_data = cell(9,(length(spiking_files)+3));

ISI_data(2,1) = {'First 10-spike Sweep'};
ISI_data(3,1) = {'Current Injected (pA)'};
ISI_data(4,1) = {'# Spikes'};
ISI_data(5,1) = {'ISI1'};
ISI_data(6,1) = {'ISI4'};
ISI_data(7,1) = {'ISI9'};
ISI_data(8,1) = {'ISI1 / ISI9'};
ISI_data(9,1) = {'ISI4 / ISI9'};
ISI_data(1,end-1) = {'Average ISI1 / ISI9'};
ISI_data(1,end) = {'Average ISI4/ ISI9'};



%% Main Loop        
for ii = 1:length(spiking_files)
    
    fill_col = ii+1; %fill starting at the second column (first column has current injection values
    
    %put current .abf filename in headers of the 3 excels that will be
    %output
    ISI_data(1,1+ii) = {spiking_files(ii).name};

    %load .abf file
    [spike_d,~,~] = abfload_fcollman(strcat(spiking_files(ii).folder, '\', spiking_files(ii).name));
    
    %get voltage data from the recording
    d_mV = squeeze(spike_d(:,1,1:25));

 
%% counts spikes and convert it to frequency - finds where one points < 0 and next point is
% > 0
    fill_row = 2;

    for iii = 1:num_spike_sweeps %for each sweep
        num_spikes = 0; %initialize number of spikes at the current sweep to 0

        for iv = 25656:35656 %for each time point in the sweep 1282.8ms-1782.8
            if d_mV(iv,iii) < 0 && d_mV(iv+1, iii) > 0 %identifies where the line crosses 0mV 
                num_spikes = num_spikes + 1;
            end
        end
        
        if num_spikes > 9
            ISI_data(fill_row,fill_col) = {iii}; %Sweep #
            ISI_data(fill_row+1, fill_col) = {(iii*30)-280}; %Sweep Iinj
            ISI_data(fill_row+2, fill_col) = {num_spikes}; %Number of Spikes (should be at least 10
            break;
        end
    end %iii
    
%% Set up time-of-crossing array for 230pA this recording, will reset each - this section updated 11/19/23 (260->230pA)
%recording
    TOC_Array = zeros(1,1);

    use_sweep = cell2mat(ISI_data(fill_row, fill_col));
    
    %goes abck through as before and finds the time at which it actually
    %crosses, but !only! on the sweep that you previously identified as
    %being the first sweep with at least 10 spikes

    num_spikes = 0; %set the initial number of spikes to 0
    fill_row_IEI = 1;  %initialize fill row, no header so can start at 1

    for iii = 25656:35656
        if d_mV(iii,use_sweep) < 0 && d_mV(iii+1, use_sweep) > 0
             TOC_Lower_Bound = iii; %assign the lower bound to the point below 0
             TOC_Upper_Bound = iii+1; %assign the upper bound to the point above 0, by default just use TOC_Lower as the true point of crossing,
             TOC_Array(fill_row_IEI,1) = TOC_Lower_Bound; %assign that time of crossing to the correct row (correct sweep) and correct column (first crossing will correspond to the first spike)
             fill_row_IEI = fill_row_IEI + 1;
        end
    end
     

     %now having the TOCs, I can subtract each to find the # of data points in
     %between them and multiple by 0.05 to get the actual time (in ms) between
     %them
     for iii=1:length(TOC_Array)-1
         data_point_delta = TOC_Array(iii+1,1)-TOC_Array(iii,1);
         TOC_Array(iii+1,2) = data_point_delta * 0.05;
     end

     ISI_data(fill_row+3, fill_col) = {TOC_Array(2,2)}; %gets the first ISI of sweep (ISI 1)
     ISI_data(fill_row+4, fill_col) = {TOC_Array(5,2)}; %gets the fourth ISI of sweep (ISI 4)
     ISI_data(fill_row+5, fill_col) = {TOC_Array(10,2)}; %gets the ninth ISI of sweep (ISI 9)
     
     ISI_data(fill_row+6, fill_col) = {TOC_Array(2,2) / TOC_Array(10,2)}; %gets ISI 1 / ISI 9
     ISI_data(fill_row+7, fill_col) = {TOC_Array(5,2) / TOC_Array(10,2)}; %gets ISI 4 / ISI 9
     
     clearvars fill_col fill_row fill_row_IEI use_sweep num_spikes TOC_Array
     
end
     
ISI_data(2, end-1) = {mean(cell2mat(ISI_data(end-1, 2:1+length(spiking_files))))}; %Average ISI 1 / ISI 9
ISI_data(2, end) = {mean(cell2mat(ISI_data(end, 2:1+length(spiking_files))))}; %Average ISI 1 / ISI 9
    

path_parts1 = regexp(spiking_files(ii).folder, '\', 'split');
ISI_data(1,1+ii) = {spiking_files(ii).name};
xlsx_savename = strcat(spiking_files(ii).folder, '\', path_parts1(end-3), '_', path_parts1(end-2), '_', path_parts1(end-1), '_data.xlsx');

% save spiking data for cell
basefilename = strcat(path_parts1(7), '_', path_parts1(8), '_', path_parts1(9), '_ISI_data.xlsx');
basefilename = char(basefilename);
savefilename = strcat(spiking_files(ii).folder, '\', basefilename);
xlswrite(savefilename, ISI_data)


end