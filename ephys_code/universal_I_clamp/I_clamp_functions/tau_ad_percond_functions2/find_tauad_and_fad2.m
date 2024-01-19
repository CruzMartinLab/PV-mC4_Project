function [tauad_fad] = find_tauad_and_fad2(cell_sex_mat, cell_sex_std, I_inj, is_PYR, celltype_sex, num_spike_sweeps); 

tauad_fad = cell(length(I_inj)+1, 3);
tauad_fad(1,1) = {'Current (pA)'};
tauad_fad(1,2) = {'Tau_ad (ms)'};
tauad_fad(1,3) = {'F_ad'};

I_inj=I_inj';

for k = 1:num_spike_sweeps
    tauad_fad{k+1,1} = I_inj(k,1);
end


for i = 1:length(I_inj)
    xdata = cell_sex_mat(:,(i*2-1));
    ydata = cell_sex_mat(:,(i*2));
    
    x_std = cell_sex_std(:,(i*2-1));
    y_std = cell_sex_std(:,(i*2));
    
    

%     deleteif_0 = xdata(:) == 0;
%     xdata(deleteif_0,:) = [];
%     
%     deleteif_0 = ydata(:) == 0;
%     ydata(deleteif_0,:) = [];
%     
%     above_5000_idx = find(ydata > 5000);
%     xdata(above_5000_idx) = [];
%     ydata(above_5000_idx) = [];
    
    %error, by chance if 2 x values or 2 y-values are the same, fit throws
    %error, delete one of the two if there is a pair (rare, but happens)
%     [~,dup_idx] = unique(xdata(:,1),'stable');
%     xdata = xdata(dup_idx,:);
%     ydata = ydata(dup_idx,:);
    
    if ~isnan(xdata(4)) == 1  %i.e. if there are data points entered, need at least 4 for a proper fit
         
        
        xdata=xdata(~isnan(xdata(:,1)),:); 
        ydata=ydata(~isnan(ydata(:,1)),:); 
        
        x_std=x_std(~isnan(x_std(:,1)),:); 
        y_std=y_std(~isnan(y_std(:,1)),:); 
        
        
        
         if is_PYR == 1
            fitted = fit(xdata,ydata,'exp2'); %make the fit for PYR
            fit_type = 'exp2';
         else
            fitted = fit(xdata,ydata,'exp1'); %make the fit for PV
            fit_type = 'exp1';
         end     
         
%          figure;plot(fitted, xdata,ydata) %basic plot of pts with the fitted line

         x_fitted=linspace(min(xdata), max(xdata),1000); %get actual x-y points from fit
         y_fitted=fitted(x_fitted);
         
         decay_yval_thresh = y_fitted(1)-(0.632*(y_fitted(1)-y_fitted(end))); % 63% of total decay that needs to be crossed

         %plot your points + the line you just made of the fit
         


         %this is where we find where it crosses the decay threshold
         %of 63%
         moving_idx = 1;
         while y_fitted(moving_idx) > decay_yval_thresh
             moving_idx = moving_idx + 1;
         end
         tau_x = x_fitted(moving_idx); %point of crossing, x
         tau_y = y_fitted(moving_idx); %point of crossing, y

         %if you want to see that point of where it crosses
         %threshold being marked
%          plot(x_fitted, y_fitted)
%          hold on
%          plot(tau_x, tau_y, 'r*')

         tau_ad = tau_x - x_fitted(1); %to find time to get to that point, subtract x-value of where it crossed from the starting x-value

         tauad_fad(i+1,2) = {tau_ad}; %insert this tau_ad into the finalresults matrix; this is the tauad for this sweep for all recordings from this sex/geno

         f_max = max(y_fitted); %max
         f_ss = mean(y_fitted(800:1000)); %last 100ms of pulse
         f_ad = (f_max-f_ss)/f_max;

         tauad_fad(i+1,3) = {f_ad};
         
         if i == 8 || i == 12 || i == 16
             figure
             plot(xdata, ydata, 'r*') %all points to fit
             hold on
             plot(x_fitted, y_fitted, 'Color', 'k', 'LineWidth', 3) %line of best fit
             hold on
             
             plot(x_std, ydata+y_std, 'color', [0.5 0.5 0.5]) %STD above
             hold on
             plot(x_std, ydata-y_std, 'color', [0.5 0.5 0.5]) %STD below
             hold on
             
             plot(tau_x, tau_y, 'go', 'MarkerSize', 7, 'MarkerFaceColor', 'g') %tau threshold
             hold on
             

             
             
             
             ylabel('Instantaneous Spiking Freq (Hz)')
             xlabel('Time (ms)')
             title(['I_i_n_j = ',num2str(I_inj(i))]);
             xlim([0 500])
             ylim([0 max(ydata)+20])
             legend('All data points to fit', ['Best fit, ', fit_type], '+ STD', '- STD', 'Tau threshold')
             annotation('textbox', [0.45, 0.75, 0.1, 0.1], 'String', celltype_sex)
             text(10,(y_fitted(1)*0.05),['tau_a_d =', ' ', num2str(tau_ad), 'ms'])
             text(200,(y_fitted(1)*0.05),['f_a_d =', ' ', num2str(f_ad)])
             hold off
         end
         
         
    else
        continue
    end
    clear xdata ydata x_std y_std
end

end


