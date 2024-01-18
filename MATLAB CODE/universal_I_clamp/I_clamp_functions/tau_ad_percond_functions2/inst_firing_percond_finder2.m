function [export_inst_firing] = inst_firing_percond_finder2(spiking_files, num_spike_sweeps, spiking_injcur)

%Initial set up of spiking_data cell array
inst_firing_data = cell(length(spiking_files)+1, length(spiking_injcur)+2);

%populate tau_ad array with the current injection values    
for k = 3:num_spike_sweeps+2
    inst_firing_data{1,k} = spiking_injcur(k-2,1);
end

inst_firing_data{1,2} = {'Recording'};
inst_firing_data{1,1} = {'Sex'};

%% Main Loop        
for ii = 1:length(spiking_files)

    path_parts = regexp(spiking_files(ii).folder, '\', 'split');
    inst_firing_data(ii+1,2) = {char(strcat(path_parts(7), '_', path_parts(8), '_', path_parts(9)))};
    getsex = regexp(cell2mat(path_parts(7)), '_', 'split');
    inst_firing_data(ii+1,1) = {char(getsex(3))};
 
    %load .abf file
    [spike_d,~,~] = abfload_fcollman(strcat(spiking_files(ii).folder, '\', spiking_files(ii).name));
    
    %get voltage data from the recording
    d_mV = squeeze(spike_d(:,1,9:25));

%% counts spikes and convert it to frequency - finds where one points < 0 and next point is
% > 0
    %fill_row = 3;

    for iii = 1:num_spike_sweeps %for each sweep
        num_spikes = 0; %initialize number of spikes at the current sweep to 0

        for iv = 25656:35656 %for each time point in the sweep 1282.8ms-1782.8
            if d_mV(iv,iii) < 0 && d_mV(iv+1, iii) > 0 %identifies where the line crosses 0mV 
                num_spikes = num_spikes + 1;
            end
        end
        
        if num_spikes > 3 %exp2 makes nice fit here, but requirs at least 4 data points, in this case ISIs, so you need 5 spikes min 
            TOC_Array = zeros(1,1); %Data pt of spike, %time in ms of total 500, ISI in ms, inst spiking_freq
            fill_row_IEI = 1;
            
                for iv = 25656:35656 %duration of current step
                    if d_mV(iv,iii) < 0 && d_mV(iv+1, iii) > 0
                         TOC_Lower_Bound = iv; %assign the lower bound to the point below 0
                         TOC_Upper_Bound = iv+1; %assign the upper bound to the point above 0, by default just use TOC_Lower as the true point of crossing,
                         TOC_Array(fill_row_IEI,1) = (TOC_Lower_Bound + TOC_Upper_Bound) / 2; %column 1: assign that time of crossing (avg of the upper and lower) to the correct row (correct sweep) and correct column (first crossing will correspond to the first spike)
                         TOC_Array(fill_row_IEI,2) = (TOC_Array(fill_row_IEI,1)-25656)*0.05; %column2: time in ms when spike was, start of current step is t=0
                         fill_row_IEI = fill_row_IEI + 1; %move to the next row for the next spike it finds
                    end
                end
                
                n_TOC_rows = size(TOC_Array);
                n_TOC_rows = n_TOC_rows(1);
                
                % Column 3: now having the TOCs in column 2 in ms, I can
                % subtract each from the one behind it to find the ISI in
                % ms
                 for iv = 1:n_TOC_rows-1
                     TOC_Array(iv+1,3) = TOC_Array(iv+1,2)-TOC_Array(iv,2);
                 end
                 
%                  %plot the TOC against the ISI
%                  plot(TOC_Array(2:end,2), TOC_Array(2:end,3), 'ko')
                
                
                for iv = 2:n_TOC_rows
                    TOC_Array(iv, 4) = 1 / (TOC_Array(iv,3)/1000);
                end
                
                inst_firing_data{ii+1,iii+2} = horzcat(TOC_Array(2:end, 2), TOC_Array(2:end,4));
                
                clearvars TOC_Array
        else 
            continue
        end
        

    end
    
end

export_inst_firing = inst_firing_data(2:end,:)

end