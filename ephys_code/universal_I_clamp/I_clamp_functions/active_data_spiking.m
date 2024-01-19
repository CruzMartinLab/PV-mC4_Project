%edit 1/31/22 LAF, delete excel file before writing new one for both
%everything is checked
function [spiking_data, path_parts] = active_data_spiking(spiking_files, time_increment, spiking_injcur, num_spike_sweeps, spiking_time_s)

%Initial set up of spiking_data cell array
spiking_data = cell(length(spiking_injcur)+9,(length(spiking_files)+10));
spiking_data(1,1) = {'Injected Current'};
spiking_data(1,end-8) = {'Average Spikes'};
spiking_data(1,end-7) = {'Average Tau (ms)'};
spiking_data(1,end-6) = {'Average Cm (pF)'};
spiking_data(1,end-5) = {'Average Rheobase (pA)'};
spiking_data(1,end-4) = {'Average Input Resistance (MOhms)'};
spiking_data(1,end-3)= {'Average First Spike Area (V-s)'};
spiking_data(1,end-2) = {'Average Width at Half Amplitude (ms)'};
spiking_data(1,end-1) = {'Average AP Ampltitude'};
spiking_data(1,end) = {'Average AHP Amplitude (mV)'};


spiking_data(end-7,1) = {'Tau (ms)'};
spiking_data(end-6,1) = {'Cm (pF)'};
spiking_data(end-5,1) = {'Rheobase (pA)'};
spiking_data(end-4,1) = {'Rin (MOhms)'}; 
spiking_data(end-3,1) = {'First Spike Area (V-s)'};
spiking_data(end-2,1) = {'Width at Half Amplitude(ms)'};
spiking_data(end-1,1) = {'AP Amplitude'};
spiking_data(end,1) = {'AHP Amplitude (mV)'};
    
    
%populate spiking_data array with the current injection values    
for k = 2:num_spike_sweeps+1
    spiking_data{k,1} = spiking_injcur(k-1,1);
end
  
%Initial Set-up of Separate Array to hold IEIs - will need to average across this to get average IEI between each spike after all recordings are analyzed       
IEI_data_230 = cell(1,1);
IEI_data_440 = cell(1,1);

%clear any existing .emfs, .figs, .xlsx
emfs = dir(strcat(spiking_files(1).folder, '\*.emf'));      
figs = dir(strcat(spiking_files(1).folder, '\*.fig'));        
excels = dir(strcat(spiking_files(1).folder, '\*.xlsx'));  
        
%clear any existing .emfs, .figs, .xlsx
if length(emfs)>1
    for d = 1:length(emfs)
        delete(strcat(emfs(d).folder, '\', emfs(d).name))
    end
end
if length(figs)>1
    for d = 1:length(figs)
        delete(strcat(figs(d).folder, '\', figs(d).name))
    end
end
if length(excels)>1
    for d = 1:length(excels)
        delete(strcat(excels(d).folder, '\', excels(d).name))
    end
end
%% Main Loop        
for ii = 1:length(spiking_files)
    
    fill_col = ii+1; %fill starting at the second column (first column has current injection values
    
    %put current .abf filename in headers of the 3 excels that will be
    %output
    spiking_data(1,1+ii) = {spiking_files(ii).name};
    IEI_data_230(1,ii) = {spiking_files(ii).name};
    IEI_data_440(1,ii) = {spiking_files(ii).name}; 

    %load .abf file
    [spike_d,~,~] = abfload_fcollman(strcat(spiking_files(ii).folder, '\', spiking_files(ii).name));
    
    %get voltage data from the recording
    d_mV = squeeze(spike_d(:,1,1:25));

    % %Can un-comment this out when you want to run a single file to see it
    %  [PVspike_d,~,~] = abfload_fcollman("Z:\Luke\Electrophysiology\PVxC4KI\Active Properties\PVC4^WT\58504_2\PV_Cell\cell1\spiking\2022_09_21_0007.abf");
    %  d_mV = squeeze(PVspike_d(:,1,:));
    %  figure;
    %  plot(spiking_time_s(24000:40000), d_mV(24000:40000, 1), 'LineWidth', 3); %-250
    %  hold on
    %  plot(spiking_time_s(24000:40000), d_mV(24000:40000, 13),'LineWidth', 3); %110
    %  hold on
    %  plot(spiking_time_s(24000:40000), d_mV(24000:40000, 25), 'LineWidth', 3); %470
    %  ylim([-200 40])
 

    
 
 %% save emfs of current injection at 260pA and 440pA

    path_parts = split(spiking_files(ii).name, '.');
    %save .emf of current injection of 230pA
    figure;
    plot(spiking_time_s(24000:40000), d_mV(24000:40000, 18)); %THIS IS REALLY 260
    basefilename = strcat(path_parts(1), '_260pA.fig');
    savefilename = strcat(spiking_files(ii).folder, '\', basefilename);
    savefilename = string(savefilename);
    saveas(gcf, savefilename);
    close;

    %save .emf of current injection of 440pA
    figure;
    plot(spiking_time_s(24000:40000), d_mV(24000:40000, 24));
    basefilename = strcat(path_parts(1), '_440pA.fig');
    savefilename = strcat(spiking_files(ii).folder, '\', basefilename);
    savefilename = string(savefilename);
    saveas(gcf, savefilename);
    close;
 
%% counts spikes and convert it to frequency - finds where one points < 0 and next point is
% > 0
    for iii = 1:num_spike_sweeps %for each sweep
        num_spikes = 0; %initialize number of spikes at the current sweep to 0
        fill_row = iii+1; %to fill the correct row in spiking_data corresponding to the correct current injection value

        for iv = 25656:35656 %for each time point in the sweep 1282.8ms-1782.8
            if d_mV(iv,iii) < 0 && d_mV(iv+1, iii) > 0 %identifies where the line crosses 0mV 
                num_spikes = num_spikes + 1;
            end
        end
        %put data into spiking_array with each sweep
        spiking_data(fill_row, fill_col) = {num_spikes/0.5}; %convert from number of spikes to frequency (500ms pulse)
    end %iii
    
%% Set up time-of-crossing array for 230pA this recording, will reset each - this section updated 11/19/23 (260->230pA)
%recording
    TOC_Array = zeros(1,1);

    %goes abck through as before and finds the time at which it actually
    %crosses, but !only! on sweep 18 (260pA injection)
    
    %NOTE NOTE NOTE: keeping 230pA nomenclature so I don't have to alter
    %everything, but everything that days 230 is really 260. at 230, we
    %lose cells because some are not spiking (so of course there are no
    %IEIs)

    num_spikes = 0; %set the initial number of spikes to 0
    fill_row = 1;  %initialize fill row, no header so can start at 1

    for iii = 25656:35656
        if d_mV(iii,18) < 0 && d_mV(iii+1, 18) > 0
             TOC_Lower_Bound = iii; %assign the lower bound to the point below 0
             TOC_Upper_Bound = iii+1; %assign the upper bound to the point above 0, by default just use TOC_Lower as the true point of crossing,
             TOC_Array(fill_row,1) = TOC_Lower_Bound; %assign that time of crossing to the correct row (correct sweep) and correct column (first crossing will correspond to the first spike)
             fill_row = fill_row + 1;
        end
    end
     

     %now having the TOCs, I can subtract each to find the # of data points in
     %between them and multiple by 0.05 to get the actual time (in ms) between
     %them
     for iii=1:length(TOC_Array)-1
         data_point_delta = TOC_Array(iii+1,1)-TOC_Array(iii,1);
         IEI_data_230(iii+1,ii) = {data_point_delta * 0.05};
     end


%      %can plot it just to confirm that it is marking around 0mV
%      plot(d_mV(:,17))
%      hold on
%      for x = 1:length(TOC_Array)
%          xline(TOC_Array(x,1))
%          hold on
%      end

%% Set up time-of-crossing array for 440pA this recording, will reset each
%recording
TOC_Array = zeros(1,1);

    %goes abck through as before and finds the time at which it actually
    %crosses, but !only! on sweep 24 (400pA injection)

    num_spikes = 0; %set the initial number of spikes to 0
    fill_row = 1;  %initialize fill row, no header so can start at 1

    for iii = 25656:35656
        if d_mV(iii,24) < 0 && d_mV(iii+1, 24) > 0
             TOC_Lower_Bound = iii; %assign the lower bound to the point below 0
             TOC_Upper_Bound = iii+1; %assign the upper bound to the point above 0, by default just use TOC_Lower as the true point of crossing,
             TOC_Array(fill_row,1) = TOC_Lower_Bound; %assign that time of crossing to the correct row (correct sweep) and correct column (first crossing will correspond to the first spike)
             fill_row = fill_row + 1;
        end
    end
     

     %now having the TOCs, I can subtract each to find the # of data points in
     %between them and multiple by 0.05 to get the actual time (in ms) between
     %them
     for iii=1:length(TOC_Array)-1
         data_point_delta = TOC_Array(iii+1,1)-TOC_Array(iii,1);
         IEI_data_440(iii+1,ii) = {data_point_delta * 0.05};
     end
 
%  
%  %can plot it just to confirm that it is marking around 0mV
%  plot(d_mV(:,24))
%  hold on
%  for x = 1:length(TOC_Array)
%      xline(TOC_Array(x,1))
%      hold on
%  end
 


%% ID Rheobase
    for iii = 1:num_spike_sweeps
        if cell2mat(spiking_data(iii+1,fill_col)) > 0 %find first column where the spike freq>0
           spiking_data(end-5, fill_col) = spiking_data(iii+1,1); %assigns that to rheobase
           rheo_sweep = iii; %used in area under first sweep and width at half amp
           break
        end
    end

%% Find area under first spike of rheobase - first need to find peak and bl of AP

% figure
% plot(d_mV(:,rheo_sweep));
    
    %find where first spike crosses 0 in the rheobase sweep
    for iii = 25656:35656
        if d_mV(iii,rheo_sweep) < 0 && d_mV(iii+1, rheo_sweep) > 0
            break
        end
    end

    %asking which point is closer to 0
    if abs(d_mV(iii,rheo_sweep)) < abs(d_mV(iii+1,rheo_sweep)) 
        cross0_idx = iii;
    else
        cross0_idx = iii+1;
    end
    
    
    [AP_peak, AP_peak_idx] = max(d_mV(cross0_idx:cross0_idx+50,rheo_sweep)); %peak relative to crossing 0 point
    AP_peak_idx = cross0_idx + AP_peak_idx-1; %peak on full scale, -1 to account for it starting at 0

    %find the baseline (inflection point) of the AP using the derivative of
    %the sweep
    x_bl = cross0_idx-50:cross0_idx+50;
    y_bl = d_mV(cross0_idx-50:cross0_idx+50,rheo_sweep);
    dydx = gradient(y_bl(:)) ./ gradient(x_bl(:));

    % %this figure set shows you the sweep and the derivative of the sweep
    % figure
    % plot(d_mV(x_bl,rheo_sweep))
    % figure
    % plot(dydx)

    %inflection point is roughly where dydx>1
    for iii = 1:length(dydx)
        if dydx(iii) > 1
            break
        end
    end

    AP_bl_idx = cross0_idx-51+iii; %inflection in the derivative on full scale
    AP_bl = d_mV(cross0_idx-51+iii, rheo_sweep); %idx of inflection


%% Now Find total area under first AP of rheobase
    
    %find the idx where it crosses the bl mV value again, but on the
    %falling phase of the AP now
    for iii = AP_peak_idx:AP_peak_idx+300
        if d_mV(iii, rheo_sweep) > AP_bl && d_mV(iii+1, rheo_sweep) < AP_bl
            break
        end
    end

    AP_end_idx = iii;
    AP_end = d_mV(iii, rheo_sweep);

% %this figure set shows you where it is marking the baseline and the peak
% figure
% plot(d_mV(:, rheo_sweep))
% hold on
% plot(AP_bl_idx, AP_bl, 'r*','MarkerSize', 12)
% hold on
% plot(AP_peak_idx, AP_peak, 'r*', 'MarkerSize', 12)
% hold on
% plot(AP_end_idx, AP_end, 'r*', 'MarkerSize', 12)

    AUC_y = d_mV(AP_bl_idx:AP_end_idx,rheo_sweep); %subset the region (bl to end) to find the AUC
    AUC_y = AUC_y + abs(min(AUC_y)); %need to shift all points up so that baseline is 0
    AUC = trapz(AUC_y) * 0.05; %trapz is function to find AUC, multiply by 0.05, now in mV-ms or V-s
    spiking_data(end-3, fill_col) = {AUC};

    %% spike amplitude
    spiking_data(end-1, fill_col) = {(AP_peak - AP_bl)};
    
    %% Now find width at half amplitude
    %this is the value halfway up to the peak
    half_amp = AP_bl+((AP_peak - AP_bl) / 2); 

    for iii = AP_bl_idx:AP_peak_idx
        if d_mV(iii, rheo_sweep) < half_amp && d_mV(iii+1, rheo_sweep) > half_amp
            break
        end
    end

    %choose the point of the two that is actually closer to the true half
    %amplitude, first cross
    upper_pt_diff = abs(d_mV(iii+1, rheo_sweep) - half_amp);
    lower_pt_diff = abs(d_mV(iii, rheo_sweep) - half_amp);

    if upper_pt_diff < lower_pt_diff
        first_cross_half_amp_idx = iii+1;
    else
        first_cross_half_amp_idx = iii;
    end

    first_cross_half_amp = d_mV(first_cross_half_amp_idx, rheo_sweep); %y value of point closest to where it crosses half amp


%now find where it crosses that half amplitude on the falling phase of
%the AP
    for iii = AP_peak_idx:AP_peak_idx + 300
        if d_mV(iii, rheo_sweep) > half_amp && d_mV(iii+1, rheo_sweep) < half_amp
            break
        end
    end

    upper_pt_diff = abs(d_mV(iii, rheo_sweep) - half_amp);
    lower_pt_diff = abs(d_mV(iii+1, rheo_sweep) - half_amp);

    if upper_pt_diff < lower_pt_diff
        second_cross_half_amp_idx = iii;
    else
        second_cross_half_amp_idx = iii+1;
    end

    second_cross_half_amp = d_mV(second_cross_half_amp_idx, rheo_sweep); %y value of second cross

    %now calculate the actual width (in ms)
    width_at_half_amp = (second_cross_half_amp_idx - first_cross_half_amp_idx)*0.05;
    spiking_data(end-2, fill_col) = {width_at_half_amp}; %in ms


%% Now find AHP amplitude  

%need to account for differences in time between spikes for defining range,
%number of spikes, if there is only one spike, etc

    %if there is only one spike
    if cell2mat(spiking_data(rheo_sweep+1, fill_col)) == 2
        spiking_data(end, fill_col) = {nan}
        
        figure
        plot(d_mV(:, rheo_sweep))
        hold on
        plot(AP_bl_idx, AP_bl, 'r*','MarkerSize', 12)
        hold on
        plot(AP_peak_idx, AP_peak, 'r*', 'MarkerSize', 12)
        hold on
        plot(AP_end_idx, AP_end, 'r*', 'MarkerSize', 12)
        hold on
        plot(first_cross_half_amp_idx, first_cross_half_amp, 'k*', 'MarkerSize', 12)
        hold on
        plot(second_cross_half_amp_idx, second_cross_half_amp, 'k*', 'MarkerSize', 12)

        basefilename = strcat(path_parts(1), '_RheoSweep.fig');
        savefilename = strcat(spiking_files(ii).folder, '\', basefilename);
        savefilename = string(savefilename);
        saveas(gcf, savefilename);
        close;
    end

    %as long as there is more than 1 spike we can more reliably plot AHP
    %amplitude
    if cell2mat(spiking_data(rheo_sweep+1, fill_col)) > 2
        AHP_x = AP_end_idx:AP_end_idx+7000;
        AHP_y = d_mV(AP_end_idx:AP_end_idx+7000,rheo_sweep);
        AHP_dydx = gradient(AHP_y(:)) ./ gradient(AHP_x(:));
        
%         figure
%         plot(AHP_x, AHP_y)
%         figure
%         plot(AHP_dydx)

        for iii = 1:length(AHP_dydx)
            if AHP_dydx(iii) > 1
                break
            end
        end

        next_spike_start = iii;

        [AHP_peak, AHP_peak_idx] = min(d_mV(AP_end_idx:(AP_end_idx+next_spike_start),rheo_sweep));
        AHP_peak_idx = AHP_peak_idx + AP_end_idx;

        spiking_data(end, fill_col) = {AP_end - AHP_peak};


        figure
        plot(d_mV(:, rheo_sweep))
        hold on
        plot(AP_bl_idx, AP_bl, 'r*','MarkerSize', 12)
        hold on
        plot(AP_peak_idx, AP_peak, 'r*', 'MarkerSize', 12)
        hold on
        plot(AP_end_idx, AP_end, 'r*', 'MarkerSize', 12)
        hold on
        plot(first_cross_half_amp_idx, first_cross_half_amp, 'k*', 'MarkerSize', 12)
        hold on
        plot(second_cross_half_amp_idx, second_cross_half_amp, 'k*', 'MarkerSize', 12)
        hold on
        plot(AHP_peak_idx, AHP_peak, 'm*', 'MarkerSize', 12)

        basefilename = strcat(path_parts(1), '_RheoSweep.fig');
        savefilename = strcat(spiking_files(ii).folder, '\', basefilename);
        savefilename = string(savefilename);
        saveas(gcf, savefilename);
        close;
    end
    
%% find Rin; average across all sweeps
    hold_Rin = zeros(25,1);
    Rin_inj = .000000000020; %current injected, in Amps (20pA)
    for Rin = 1:num_spike_sweeps
        mV_basline = mean(d_mV(4640:5640,Rin));%50ms before pulse, pulse goes from 282.8ms-782.8ms, this is from 232-282ms
        Rin_mV = mean(d_mV(8640:15240,Rin)); %in sweep, 150ms after pulse start - 20ms before end of pulse), this is 432-762
        mV_delta = mV_basline - Rin_mV; %in mV
        V_delta = mV_delta / 1000; %now in volts
        hold_Rin(Rin,1) = V_delta/Rin_inj; %Rin is given in ohms (V/A)
    end
    spiking_data(end-4,fill_col) = {mean(hold_Rin)/1000000}; %divide value by 1,000,000 to convert ohms to MOhms


%% Find tau and Cm using fit
    hold_tau = zeros(25,6);

    end_of_pulse_idx = 15656; %782.8ms, right where pulse terminates, never changes so can define it here outside of loop
    for iii = 1:num_spike_sweeps
        postpulse_mV_baseline = mean(d_mV(20000:25600,iii)); %from 1 sec to right before spiking
            for iv = 15656:20000 %define where you are looking for it to reach baseline, should be long before index 24600
                check_return_to_bl = d_mV(iv,iii);
                if check_return_to_bl > postpulse_mV_baseline %if the point reaches back to baseline
                    end_return_to_bl_idx = iv;
                    break
                end
            end
 

            
% if you want to use derivative, can try to find way to see where to end
% points to fit rather than just when it hits a certain spot
%  x_tofit = (end_of_pulse_idx-50:end_return_to_bl_idx)';
%  y_tofit = d_mV(end_of_pulse_idx-50:end_return_to_bl_idx,iii);
%  y_tofit_smooth = smoothdata(y_tofit, 'sgolay',200);   
%  dydx_tofit = gradient(y_tofit_smooth(:)) ./ gradient(x_tofit(:));
   
%    to get back to close to original data
%     mV_tofit_idc = (end_of_pulse_idx-50:end_return_to_bl_idx-50)';
%     mV_tofit = d_mV(end_of_pulse_idx-50:end_return_to_bl_idx-50,iii);

    mV_tofit_idc = (end_of_pulse_idx-15:end_return_to_bl_idx-100)';
    mV_tofit = d_mV(end_of_pulse_idx-15:end_return_to_bl_idx-100,iii);

   
    f = fit(mV_tofit_idc,mV_tofit, 'poly3');
    
%     %if iii = 1 %plot and save the fit of only the fist sweep for each recording, just to have to show
%         figure
%         plot(d_mV(:,9))
%         hold on
%         plot(mV_tofit_idc,mV_tofit)
%         hold on
%         plot(f,mV_tofit_idc,mV_tofit)
%         plot(x_tofit, y_tofit_smooth, 'LineWidth', 2)
%         hold on
%         plot(dydx_tofit)
%         plot(f,mV_tofit_idc,mV_tofit)
%         basefilename = strcat(spiking_files(ii).name, '_fit.emf');
%         savefilename = strcat(spiking_files(ii).folder, '\', basefilename);
%         saveas(gcf, savefilename);
%         close;
%     end





% %average all sweeps then do it - simular result

% hold_sweeps = zeros(42000,num_spike_sweeps);
% 
% for b = 1:num_spike_sweeps
%     test_sweep = d_mV(:,b);
%     baseline_toshift = mean(test_sweep(1:5500));
%     hold_sweeps(:,b) = test_sweep - baseline_toshift;
% end
% 
% avg_spike_sweeps = mean(hold_sweeps,2)
% 
% mean(avg_spike_sweeps(1:5500))
% 
% 
%     end_of_pulse_idx = 15656; %782.8ms, right where pulse terminates, never changes so can define it here outside of loop
%         postpulse_mV_baseline = mean(avg_spike_sweeps(20000:25600)); %from 1 sec to right before spiking
%             for iv = 15656:20000 %define where you are looking for it to reach baseline, should be long before index 24600
%                 check_return_to_bl = avg_spike_sweeps(iv);
%                 if check_return_to_bl > postpulse_mV_baseline %if the point reaches back to baseline
%                     end_return_to_bl_idx = iv;
%                     break
%                 end
%             end
% 
% mV_tofit_idc1 = (end_of_pulse_idx-15:end_return_to_bl_idx-100)';
% mV_tofit1 = avg_spike_sweeps(end_of_pulse_idx-15:end_return_to_bl_idx-100);
% f1 = fit(mV_tofit_idc1,mV_tofit1, 'poly4');
% 
%         figure
%         plot(avg_spike_sweeps(:));
%         hold on
%         plot(mV_tofit_idc1,mV_tofit1);
%         hold on
%         plot(f1,mV_tofit_idc1,mV_tofit1)
% 


    %now need to actually find tau - 63% of return to baseline
    fitted_mV_values = f(mV_tofit_idc);

    %mV value of where it has returned to 63% 
    mV_delta = abs(fitted_mV_values(1) - fitted_mV_values(end));
    perc63 = mV_delta*.628;
    tau_endpt = fitted_mV_values(1) + perc63;

    working_fitted_mV_values_idx = 1;
    while fitted_mV_values(working_fitted_mV_values_idx) < tau_endpt
     working_fitted_mV_values_idx = working_fitted_mV_values_idx + 1;
    end

    hold_tau(iii,1) = end_return_to_bl_idx; %idx when it gets back to baseline
    hold_tau(iii,2) = d_mV(end_return_to_bl_idx, iii); %mV value of when it gets back to baseline
    hold_tau(iii,3) = mV_delta; %delta of the FIT now
    hold_tau(iii,4) = tau_endpt; %mV when the FIT decays by 62.8%
    hold_tau(iii,5) = working_fitted_mV_values_idx; %how many points it took to get to tau
    hold_tau(iii,6) = working_fitted_mV_values_idx * 0.05; %tau of the FIT, in ms
    end
   
    spiking_data(end-7,ii+1) = {mean(hold_tau(:,end))}; %put tau in spiking_data

% Now find Cm - do it for all sweeps individually and then average
    hold_Cm = zeros(25,1);
    for iii = 1:num_spike_sweeps
        %Cm (pF) = tau (ms) / Rin (GOhms) https://spikesandbursts.wordpress.com/2022/05/13/patch-clamp-analysis-clampfit-passive-properties/
        hold_Cm(iii,1) = hold_tau(iii,end) / (hold_Rin(iii,1)/1000000000);
    end


    spiking_data(end-6,ii+1) = {mean(hold_Cm(:,end))};

end %end of main loop

%% Delete any existing excel files since you will be replacing them here
delete(fullfile(fullfile(spiking_files(ii).folder, '*.xlsx')));
 
%% fill in average columns now - this is avg number of spikes/sweep
for avg = 1:num_spike_sweeps
    spiking_data(avg+1, end-8) = {mean(cell2mat(spiking_data(avg+1, 2:1+length(spiking_files))))};
end

%this is average tau, Cm, rheobase, Rin, AUC, Width at Half Amp
spiking_data(2, end-7) = {mean(cell2mat(spiking_data(end-7, 2:1+length(spiking_files))))};
spiking_data(2, end-6) = {mean(cell2mat(spiking_data(end-6, 2:1+length(spiking_files))))};
spiking_data(2, end-5) = {mean(cell2mat(spiking_data(end-5, 2:1+length(spiking_files))))};
spiking_data(2, end-4) = {mean(cell2mat(spiking_data(end-4, 2:1+length(spiking_files))))};
spiking_data(2, end-3) = {mean(cell2mat(spiking_data(end-3, 2:1+length(spiking_files))))};
spiking_data(2, end-2) = {mean(cell2mat(spiking_data(end-2, 2:1+length(spiking_files))))};
spiking_data(2, end-1) = {mean(cell2mat(spiking_data(end-1, 2:1+length(spiking_files))))};
spiking_data(2, end) = {nanmean(cell2mat(spiking_data(end, 2:1+length(spiking_files))))};



path_parts1 = regexp(spiking_files(ii).folder, '\', 'split');
spiking_data(1,1+ii) = {spiking_files(ii).name};
xlsx_savename = strcat(spiking_files(ii).folder, '\', path_parts1(end-3), '_', path_parts1(end-2), '_', path_parts1(end-1), '_data.xlsx');

% save spiking data for cell
basefilename = strcat(path_parts1(7), '_', path_parts1(8), '_', path_parts1(9), '_spikingdata.xlsx');
basefilename = char(basefilename);
savefilename = strcat(spiking_files(ii).folder, '\', basefilename);
xlswrite(savefilename, spiking_data)

%% average across 230 IEI array - this is separate from spiking array - also updated this 11/19/2023 (again, 260-230pA), then changes back to 260
IEI_data_230(1,end+1) = {'IEI_Average'};

%if there is only one line (names of files) but not data (i.e. no
%recordings had any spikes, so IEI_data_230 was never filled), can't run
%this next part, as there is nothing to average
IEI_data_230_dim=size(IEI_data_230);
numrows_IEI_data = IEI_data_230_dim(1);

if numrows_IEI_data > 1

    for avg = 2:numrows_IEI_data
        IEI_data_230(avg,end) = {mean(cell2mat(IEI_data_230(avg,1:end-1)))};
    end

    IEI_data_230(1,end+1) = {'ISI 1 / ISI 9'};
    IEI_data_230(1,end+1) = {'ISI 4 / ISI 9'};
    
    if numrows_IEI_data > 9
        IEI_data_230(2,end-1) = {cell2mat(IEI_data_230(2,end-2)) / cell2mat(IEI_data_230(10,end-2))};
        IEI_data_230(2,end) = {cell2mat(IEI_data_230(5,end-2)) / cell2mat(IEI_data_230(10,end-2))};
    else
         IEI_data_230(2,end-1) = {nan};
         IEI_data_230(2,end) = {nan};
    end



    basefilename = strcat(path_parts1(7), '_', path_parts1(8), '_', path_parts1(9), '_260pA_IEI_data.xlsx');
    basefilename = char(basefilename);
    savefilename = strcat(spiking_files(ii).folder, '\', basefilename);
    xlswrite(savefilename, IEI_data_230)
end

%% average across 440 IEI array - this is separate from spiking array
IEI_data_440(1,end+1) = {'IEI_Average'};
for avg = 2:length(IEI_data_440)
    IEI_data_440(avg,end) = {mean(cell2mat(IEI_data_440(avg,1:end-1)))};
end

IEI_data_440(1,end+1) = {'ISI 1 / ISI 9'};
IEI_data_440(1,end+1) = {'ISI 4 / ISI 9'};

IEI_data_440(2,end-1) = {cell2mat(IEI_data_440(2,end-2)) / cell2mat(IEI_data_440(10,end-2))};
IEI_data_440(2,end) = {cell2mat(IEI_data_440(5,end-2)) / cell2mat(IEI_data_440(10,end-2))};


basefilename = strcat(path_parts1(7), '_', path_parts1(8), '_', path_parts1(9), '_440pA_IEI_data.xlsx');
basefilename = char(basefilename);
savefilename = strcat(spiking_files(ii).folder, '\', basefilename);
xlswrite(savefilename, IEI_data_440)
end