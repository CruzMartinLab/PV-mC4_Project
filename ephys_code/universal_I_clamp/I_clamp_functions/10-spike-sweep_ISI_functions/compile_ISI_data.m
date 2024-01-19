function [PV_ISI_finalresults, PYR_ISI_finalresults] = compile_ISI_data(PV_ISI_xlsxs, PYR_ISI_xlsxs)

%% Combine PV spiking results
PV_ISI_finalresults = cell((length(PV_ISI_xlsxs)*2)+1, 4);

PV_ISI_finalresults(1,1)= {'Cell'};
PV_ISI_finalresults(1,2) = {'Sex'}; 
PV_ISI_finalresults(1,3)= {'ISI1/ISI9'};
PV_ISI_finalresults(1,4)= {'ISI4/ISI9'};

for i = 1:length(PV_ISI_xlsxs)
    working_xlsx = xlsread(strcat(PV_ISI_xlsxs(i).folder, '\', PV_ISI_xlsxs(i).name));
    path_parts = regexp(PV_ISI_xlsxs(i).name, '_', 'split');
    
    PV_ISI_finalresults(i+1,1) = {char(strcat(path_parts(1), '_', path_parts(2), '_', path_parts(4), '_', path_parts(6), '_', path_parts(3)))};
    PV_ISI_finalresults(i+1,2) = {char(strcat(path_parts(3)))};
    
    PV_ISI_finalresults(i+1, end-1:end) = num2cell(working_xlsx(1,end-1:end));
end


%% Combine PYR spiking results
PYR_ISI_finalresults = cell((length(PYR_ISI_xlsxs)*2)+1, 4);

PYR_ISI_finalresults(1,1)= {'Cell'};
PYR_ISI_finalresults(1,2) = {'Sex'}; 
PYR_ISI_finalresults(1,3)= {'ISI1/ISI9'};
PYR_ISI_finalresults(1,4)= {'ISI4/ISI9'};

for i = 1:length(PYR_ISI_xlsxs)
    working_xlsx = xlsread(strcat(PYR_ISI_xlsxs(i).folder, '\', PYR_ISI_xlsxs(i).name));
    path_parts = regexp(PYR_ISI_xlsxs(i).name, '_', 'split');
    
    PYR_ISI_finalresults(i+1,1) = {char(strcat(path_parts(1), '_', path_parts(2), '_', path_parts(4), '_', path_parts(6), '_', path_parts(3)))};
    PYR_ISI_finalresults(i+1,2) = {char(strcat(path_parts(3)))};
    
    PYR_ISI_finalresults(i+1, end-1:end) = num2cell(working_xlsx(1,end-1:end));
end

end
    