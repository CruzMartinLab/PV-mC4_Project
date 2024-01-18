function [reset_thresh_data] = reset_V_and_thresh_finder_RESTofSPIKES(spiking_files, spiking_injcur, num_spike_sweeps)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          v_threshold snd resrt for all but first spike                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Initial set up of a cell array
reset_thresh_data = cell(length(spiking_injcur)+2,(length(spiking_files)*8)+3);
reset_thresh_data(2,1) = {'Injected Current'};

reset_thresh_data(2,2:8:end) = {'# Spikes'};
reset_thresh_data(2,3:8:end) = {'# Thresh'};
reset_thresh_data(2,4:8:end) = {'# Minima'};
reset_thresh_data(2,5:8:end) = {'Basline (mV)'};
reset_thresh_data(2,6:8:end) = {'Avg Reset (mV)'};
reset_thresh_data(2,7:8:end) = {'Reset delta (mV)'};
reset_thresh_data(2,8:8:end) = {'Avg Threshold (mV)'};
reset_thresh_data(2,9:8:end) = {'Threshold delta (mV)'};

reset_thresh_data(2,end-1) = {'OVERALL Avg Reset Delta (mV)'};
reset_thresh_data(2,end) = {'OVERALL Avg Threshold Delta (mV)'};


%populate spiking_data array with the current injection values    
for k = 3:num_spike_sweeps+2
    reset_thresh_data{k,1} = spiking_injcur(k-2,1);
end


fill_col=2;

for ii = 1:length(spiking_files)
    
    %put current .abf filename in header of the excels
    reset_thresh_data(1,fill_col) = {spiking_files(ii).name};

    %load .abf file
    [spike_d,~,~] = abfload_fcollman(strcat(spiking_files(ii).folder, '\', spiking_files(ii).name));
    
    %get voltage data from the recording
    d_mV = squeeze(spike_d(:,1,1:25));
    
     for iii = 1:num_spike_sweeps %for each sweep
        num_spikes = 0; %initialize number of spikes at the current sweep to 0

        d_mV_bl = mean(d_mV(20000:25000,iii)); %250ms before start of current injection
        
 
        for iv = 25656:35656 %for each time point in the sweep 1282.8ms-1782.8
            if d_mV(iv,iii) < 0 && d_mV(iv+1, iii) > 0 %identifies where the line crosses 0mV 
                num_spikes = num_spikes + 1;
            end
        end
        
        if num_spikes > 1
            TF = islocalmin(d_mV(25656:35656,iii), 'MinSeparation', 70, 'MinProminence', 30);

            x_ax = 25656:35656;
            y_ax = d_mV(x_ax,iii);
            
            minima_idx = x_ax(TF);
            minima_mV = y_ax(TF);
        
            %% find threshold first using derivative   
            inflection_holder = zeros(1,1); %resets each sweep
            IH_row = 1;

                for iv = 25656:35656
                    if d_mV(iv,iii) < 0 && d_mV(iv+1, iii) > 0         
                        %asking which point is closer to 0
                        if abs(d_mV(iv,iii)) < abs(d_mV(iv+1,iii)) 
                           cross0_idx = iv;
                        else
                           cross0_idx = iv+1;
                        end


                         %find the baseline (inflection point) of the AP using the derivative of
                         %the sweep
                         x_bl = cross0_idx-50:cross0_idx+50;
                         y_bl = d_mV(cross0_idx-50:cross0_idx+50,iii);
                         dydx = gradient(y_bl(:)) ./ gradient(x_bl(:));

                          %this figure set shows you the sweep and the derivative of the sweep
        %                   figure; plot(d_mV(:, iii))
        %                   figure; plot(d_mV(x_bl,iii))
        %                   figure; plot(dydx)

                              %inflection point is roughly where dydx>1
                        for v = 1:length(dydx)
                            if dydx(v) > 1
                                break
                            end
                        end

                        AP_bl_idx = cross0_idx-51+v; %inflection in the derivative on full scale
                        AP_bl = d_mV(cross0_idx-51+v, iii); %idx of inflection

                        inflection_holder(IH_row, 1) = AP_bl_idx;
                        inflection_holder(IH_row, 2) = AP_bl;

                        IH_row = IH_row+1;
                     end

                end

                mean_thresh = mean(inflection_holder(2:end,2),1);
                IH_length = size(inflection_holder);
                IH_length=(IH_length(1));


        %fitted_inflection_pts = fit(inflection_holder(:,1), inflection_holder(:,2), 'exp1');
        %plot(fitted_inflection_pts, inflection_holder(:,1), inflection_holder(:,2));
        
        
        
%         figure; plot(d_mV(:,iii))
%         hold on
%         plot(inflection_holder(2:end,1), inflection_holder(2:end,2), 'r*')
%         hold on
%         yline(mean_thresh)
%         hold on 
%         plot(minima_idx(2:end), minima_mV(2:end), 'r*')
%         hold on
%         yline(mean(minima_mV(2:end)))
%         hold on
%         yline(d_mV_bl)
        
            reset_thresh_data(iii+2,fill_col) = {num_spikes-1};
            reset_thresh_data(iii+2,fill_col+1) = {IH_length-1};
            reset_thresh_data(iii+2,fill_col+2) = {sum(TF)-1};
            reset_thresh_data(iii+2,fill_col+3) = {d_mV_bl};
            reset_thresh_data(iii+2,fill_col+4) = {mean(minima_mV(2:end))};
            reset_thresh_data(iii+2,fill_col+5) = {(mean(minima_mV(2:end))) - d_mV_bl};
            reset_thresh_data(iii+2,fill_col+6) = {mean_thresh};
            reset_thresh_data(iii+2,fill_col+7) = {mean_thresh - d_mV_bl}; 
        else
            reset_thresh_data(iii+2,fill_col) = {nan};
            reset_thresh_data(iii+2,fill_col+1) = {nan};
            reset_thresh_data(iii+2,fill_col+2) = {nan};
            reset_thresh_data(iii+2,fill_col+3) = {nan};
            reset_thresh_data(iii+2,fill_col+4) = {nan};
            reset_thresh_data(iii+2,fill_col+5) = {nan};
            reset_thresh_data(iii+2,fill_col+6) = {nan};
            reset_thresh_data(iii+2,fill_col+7) = {nan}; 
        end
        clearvars num_spikes inflection_holder IH_row IH_length TF minima_idx minima_mV d_mV-bl y_ax mean_thresh         
     end
     fill_col = fill_col+8;
end

all_reset_deltas = nanmean(cell2mat(reset_thresh_data(3:end, 7:8:end)),2);
all_thresh_deltas = nanmean(cell2mat(reset_thresh_data(3:end, 9:8:end)),2);

for iv = 1:length(all_reset_deltas)
    reset_thresh_data(iv+2,end-1) = {all_reset_deltas(iv,1)};
    reset_thresh_data(iv+2,end) = {all_thresh_deltas(iv,1)};
end

path_parts1 = regexp(spiking_files(ii).folder, '\', 'split');
% save spiking data for cell
basefilename = strcat(path_parts1(7), '_', path_parts1(8), '_', path_parts1(9), '_RESTofSPIKES_reset_thresh_data.xlsx');
basefilename = char(basefilename);
savefilename = strcat(spiking_files(ii).folder, '\', basefilename);
xlswrite(savefilename, reset_thresh_data)


end
