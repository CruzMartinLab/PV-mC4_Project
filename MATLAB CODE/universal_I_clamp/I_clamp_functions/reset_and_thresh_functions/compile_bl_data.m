function [PV_bl_finalresults, PYR_bl_finalresults] = compile_bl_data(PV_bl_xlsxs, PYR_bl_xlsxs, spiking_injcur, num_spike_sweeps)

%LUKE START HERE - NEED TO EDIT THIS TO ONLY GET BL (END COLUMN) FROM THE
%WBL.XLSX FILE, SHOULD BE EASY- SHOULD ALSO MAKE NEW SECTION IN RESET_v_AND
%THRESHOLD TO REFERENCE THIS FUNCTION SPECIFICALLY, SO DON'T MESS WITH OLD
%ONE OR OLD SETUP ON MAIN FILE


%% Combine PV spiking results
PV_bl_finalresults = cell(length(spiking_injcur)+2,(length(PV_bl_xlsxs)+1));

PV_bl_finalresults(2,1)= {'Injected Current'};
for k = 3:num_spike_sweeps+2
    PV_bl_finalresults{k,1} = spiking_injcur(k-2,1);
end

ncol = size(PV_bl_finalresults);
ncol = ncol(2); 

for i = 1:length(PV_bl_xlsxs)
    working_xlsx = xlsread(strcat(PV_bl_xlsxs(i).folder, '\', PV_bl_xlsxs(i).name));
    path_parts = regexp(PV_bl_xlsxs(i).name, '_', 'split');
    
    PV_bl_finalresults(2,i+1) = {char(strcat(path_parts(1), '_', path_parts(2), '_', path_parts(4), '_', path_parts(6), '_', path_parts(3)))}; %add cell name
    PV_bl_finalresults(1,i+1) = {char(path_parts(3))};%add sex
    
    PV_bl_finalresults(3:end,i+1) = num2cell(working_xlsx(:,end));

end

PV_bl_finalresults = PV_bl_finalresults';

%% Combine PYR spiking results
PYR_bl_finalresults = cell(length(spiking_injcur)+2,(length(PYR_bl_xlsxs)+1));

PYR_bl_finalresults(2,1)= {'Injected Current'};
for k = 3:num_spike_sweeps+2
    PYR_bl_finalresults{k,1} = spiking_injcur(k-2,1);
end

ncol = size(PYR_bl_finalresults);
ncol = ncol(2); 

for i = 1:length(PYR_bl_xlsxs)
    working_xlsx = xlsread(strcat(PYR_bl_xlsxs(i).folder, '\', PYR_bl_xlsxs(i).name));
    path_parts = regexp(PYR_bl_xlsxs(i).name, '_', 'split');
    
    PYR_bl_finalresults(2,i+1) = {char(strcat(path_parts(1), '_', path_parts(2), '_', path_parts(4), '_', path_parts(6), '_', path_parts(3)))}; %add cell name
    PYR_bl_finalresults(1,i+1) = {char(path_parts(3))};%add sex
    
    PYR_bl_finalresults(3:end,i+1) = num2cell(working_xlsx(:,end));

end

PYR_bl_finalresults = PYR_bl_finalresults';

end
    