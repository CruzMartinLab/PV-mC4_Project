function [PV_sag_finalresults, PYR_sag_finalresults] = compile_sag(PV_sag_folders, PYR_sag_folders, num_sag_sweeps, sag_injcur)

%%Combine PV sag results
PV_sag_finalresults = cell(length(sag_injcur)-3,((length(PV_sag_folders)*2)+1));

PV_sag_finalresults(1,1)= {'Injected Current'};
for k = 2:15
    PV_sag_finalresults{k,1} = sag_injcur(k-1,1);
end

for i = 1:length(PV_sag_folders)
    working_xlsx = xlsread(strcat(PV_sag_folders(i).folder, '\', PV_sag_folders(i).name));
    path_parts = regexp(PV_sag_folders(i).name, '_', 'split');
    PV_sag_finalresults(1,i+1) = {char(strcat(path_parts(1), '_', path_parts(2), '_', path_parts(4), '_', path_parts(6), '_', path_parts(3), '_delta'))};
    PV_sag_finalresults(1,i+1+length(PV_sag_folders)) = {char(strcat(path_parts(1), '_', path_parts(2), '_', path_parts(4), '_', path_parts(6), '_', path_parts(3), '_sagratio'))};
    for ii = 2:11
        PV_sag_finalresults(ii, i+1) = {working_xlsx(ii-1, end-1)};
        PV_sag_finalresults(ii,i+1+length(PV_sag_folders)) = {working_xlsx(ii-1, end)};
    end
end

%%Combine PYR sag results
PYR_sag_finalresults = cell(length(sag_injcur)-3,((length(PYR_sag_folders)*2)+1));

PYR_sag_finalresults(1,1)= {'Injected Current'};
for k = 2:15
    PYR_sag_finalresults{k,1} = sag_injcur(k-1,1);
end

for i = 1:length(PYR_sag_folders)
    working_xlsx = xlsread(strcat(PYR_sag_folders(i).folder, '\', PYR_sag_folders(i).name));
    path_parts = regexp(PYR_sag_folders(i).name, '_', 'split');
    PYR_sag_finalresults(1,i+1) = {char(strcat(path_parts(1), '_', path_parts(2), '_', path_parts(4), '_', path_parts(6), '_', path_parts(3), '_delta'))};
    PYR_sag_finalresults(1,i+1+length(PYR_sag_folders)) = {char(strcat(path_parts(1), '_', path_parts(2), '_', path_parts(4), '_', path_parts(6), '_', path_parts(3), '_sagratio'))};
    for ii = 2:11
        PYR_sag_finalresults(ii, i+1) = {working_xlsx(ii-1, end-1)};
        PYR_sag_finalresults(ii,i+1+length(PYR_sag_folders)) = {working_xlsx(ii-1, end)};
    end
    
PV_sag_finalresults = PV_sag_finalresults;
PYR_sag_finalresults = PYR_sag_finalresults;
    
end