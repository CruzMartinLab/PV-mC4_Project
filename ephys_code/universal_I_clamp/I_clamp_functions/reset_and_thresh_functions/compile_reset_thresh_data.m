function [PV_reset_thresh_finalresults, PYR_reset_thresh_finalresults] = compile_reset_thresh_data(PV_reset_thresh_xlsxs, PYR_reset_thresh_xlsxs, spiking_injcur, num_spike_sweeps)

%% Combine PV spiking results
PV_reset_thresh_finalresults = cell(length(spiking_injcur)+2,(length(PV_reset_thresh_xlsxs)*2)+1);

PV_reset_thresh_finalresults(2,1)= {'Injected Current'};
for k = 3:num_spike_sweeps+2
    PV_reset_thresh_finalresults{k,1} = spiking_injcur(k-2,1);
end

ncol = size(PV_reset_thresh_finalresults);
ncol = ncol(2); 

for i = 2:(((ncol-1)/2)+1)
    PV_reset_thresh_finalresults(1,i) = {'Reset Voltage (mV)'};
end

for i = (((ncol-1)/2)+2):ncol
    PV_reset_thresh_finalresults(1,i) = {'Threshold Voltage (mV)'};
end

for i = 1:length(PV_reset_thresh_xlsxs)
    working_xlsx = xlsread(strcat(PV_reset_thresh_xlsxs(i).folder, '\', PV_reset_thresh_xlsxs(i).name));
    path_parts = regexp(PV_reset_thresh_xlsxs(i).name, '_', 'split');
    
    PV_reset_thresh_finalresults(2,i+1) = {char(strcat(path_parts(1), '_', path_parts(2), '_', path_parts(4), '_', path_parts(6), '_', path_parts(3)))};
    PV_reset_thresh_finalresults(3:end,i+1) = num2cell(working_xlsx(:,end-1));
    
    PV_reset_thresh_finalresults(2,i+1+((ncol-1)/2)) = {char(strcat(path_parts(1), '_', path_parts(2), '_', path_parts(4), '_', path_parts(6), '_', path_parts(3)))};
    PV_reset_thresh_finalresults(3:end,i+1+((ncol-1)/2)) = num2cell(working_xlsx(:,end));

end

PV_reset_thresh_finalresults = PV_reset_thresh_finalresults';

%% Combine PYR spiking results
PYR_reset_thresh_finalresults = cell(length(spiking_injcur)+2,(length(PYR_reset_thresh_xlsxs)*2)+1);

PYR_reset_thresh_finalresults(2,1)= {'Injected Current'};
for k = 3:num_spike_sweeps+2
    PYR_reset_thresh_finalresults{k,1} = spiking_injcur(k-2,1);
end

ncol = size(PYR_reset_thresh_finalresults);
ncol = ncol(2); 

for i = 2:(((ncol-1)/2)+1)
    PYR_reset_thresh_finalresults(1,i) = {'Reset Voltage (mV)'};
end

for i = (((ncol-1)/2)+2):ncol
    PYR_reset_thresh_finalresults(1,i) = {'Threshold Voltage (mV)'};
end

for i = 1:length(PYR_reset_thresh_xlsxs)
    working_xlsx = xlsread(strcat(PYR_reset_thresh_xlsxs(i).folder, '\', PYR_reset_thresh_xlsxs(i).name));
    path_parts = regexp(PYR_reset_thresh_xlsxs(i).name, '_', 'split');
    
    PYR_reset_thresh_finalresults(2,i+1) = {char(strcat(path_parts(1), '_', path_parts(2), '_', path_parts(4), '_', path_parts(6), '_', path_parts(3)))};
    PYR_reset_thresh_finalresults(3:end,i+1) = num2cell(working_xlsx(:,end-1));
    
    PYR_reset_thresh_finalresults(2,i+1+((ncol-1)/2)) = {char(strcat(path_parts(1), '_', path_parts(2), '_', path_parts(4), '_', path_parts(6), '_', path_parts(3)))};
    PYR_reset_thresh_finalresults(3:end,i+1+((ncol-1)/2)) = num2cell(working_xlsx(:,end));

end

PYR_reset_thresh_finalresults = PYR_reset_thresh_finalresults';

end
    