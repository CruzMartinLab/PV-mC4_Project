function [PV_spiking_finalresults, PYR_spiking_finalresults] = compile_spiking(PV_spiking_xlsxs, PYR_spiking_xlsxs, num_spike_sweeps, spiking_injcur)

%% Combine PV spiking results
PV_spiking_finalresults = cell(length(spiking_injcur)+9,(length(PV_spiking_xlsxs)+1));

PV_spiking_finalresults(1,1)= {'Injected Current'};
for k = 2:num_spike_sweeps+1
    PV_spiking_finalresults{k,1} = spiking_injcur(k-1,1);;
end

PV_spiking_finalresults(end-7,1) = {'Tau (ms)'};
PV_spiking_finalresults(end-6,1) = {'Cm (pF)'};
PV_spiking_finalresults(end-5,1) = {'Rheobase (pA)'};
PV_spiking_finalresults(end-4,1) = {'Rin (MOhms)'};
PV_spiking_finalresults(end-3,1)= {'Average First Spike Area (V-s)'};
PV_spiking_finalresults(end-2,1) = {'Average Width at Half Amplitude (ms)'};
PV_spiking_finalresults(end-1,1) = {'Average AP Amplitude (mV)'};
PV_spiking_finalresults(end,1) = {'Average AHP Amplitude (mV)'};

for i = 1:length(PV_spiking_xlsxs)
    working_xlsx = xlsread(strcat(PV_spiking_xlsxs(i).folder, '\', PV_spiking_xlsxs(i).name));
    path_parts = regexp(PV_spiking_xlsxs(i).name, '_', 'split');
    PV_spiking_finalresults(1,i+1) = {char(strcat(path_parts(1), '_', path_parts(2), '_', path_parts(4), '_', path_parts(6), '_', path_parts(3)))};
    for ii = 1:length(working_xlsx)-8
        PV_spiking_finalresults(ii+1, i+1) = {working_xlsx(ii, end-8)};
    end
    PV_spiking_finalresults(end-7, i+1) = {working_xlsx(1,end-7)};
    PV_spiking_finalresults(end-6, i+1) = {working_xlsx(1,end-6)};
    PV_spiking_finalresults(end-5, i+1) = {working_xlsx(1,end-5)};
    PV_spiking_finalresults(end-4, i+1) = {working_xlsx(1,end-4)};
    PV_spiking_finalresults(end-3, i+1) = {working_xlsx(1,end-3)};
    PV_spiking_finalresults(end-2, i+1) = {working_xlsx(1,end-2)};
    PV_spiking_finalresults(end-1, i+1) = {working_xlsx(1,end-1)};
    PV_spiking_finalresults(end, i+1) = {working_xlsx(1,end)};
end

PV_spiking_finalresults = PV_spiking_finalresults';

%% Combine PYR spiking results
PYR_spiking_finalresults = cell(length(spiking_injcur)+9,(length(PYR_spiking_xlsxs)+1));

PYR_spiking_finalresults(1,1)= {'Injected Current'};
for k = 2:num_spike_sweeps+1
    PYR_spiking_finalresults{k,1} = spiking_injcur(k-1,1);
end

PYR_spiking_finalresults(end-7,1) = {'Tau (ms)'};
PYR_spiking_finalresults(end-6,1) = {'Cm (pF)'};
PYR_spiking_finalresults(end-5,1) = {'Rheobase (pA)'};
PYR_spiking_finalresults(end-4,1) = {'Rin (MOhms)'};
PYR_spiking_finalresults(end-3,1)= {'Average First Spike Area (V-s)'};
PYR_spiking_finalresults(end-2,1) = {'Average Width at Half Amplitude (ms)'};
PYR_spiking_finalresults(end-1,1) = {'Average AP Amplitude (mV)'};
PYR_spiking_finalresults(end,1) = {'Average AHP Amplitude (mV)'};

for i = 1:length(PYR_spiking_xlsxs)
    working_xlsx = xlsread(strcat(PYR_spiking_xlsxs(i).folder, '\', PYR_spiking_xlsxs(i).name));
    path_parts = regexp(PYR_spiking_xlsxs(i).name, '_', 'split');
    PYR_spiking_finalresults(1,i+1) = {char(strcat(path_parts(1), '_', path_parts(2), '_', path_parts(4), '_', path_parts(6), '_', path_parts(3)))};
    for ii = 1:length(working_xlsx)-8
        PYR_spiking_finalresults(ii+1, i+1) = {working_xlsx(ii, end-8)};
    end
    PYR_spiking_finalresults(end-7, i+1) = {working_xlsx(1,end-7)};
    PYR_spiking_finalresults(end-6, i+1) = {working_xlsx(1,end-6)};
    PYR_spiking_finalresults(end-5, i+1) = {working_xlsx(1,end-5)};
    PYR_spiking_finalresults(end-4, i+1) = {working_xlsx(1,end-4)};
    PYR_spiking_finalresults(end-3, i+1) = {working_xlsx(1,end-3)};
    PYR_spiking_finalresults(end-2, i+1) = {working_xlsx(1,end-2)};
    PYR_spiking_finalresults(end-1, i+1) = {working_xlsx(1,end-1)};
    PYR_spiking_finalresults(end, i+1) = {working_xlsx(1,end)};
end

PYR_spiking_finalresults = PYR_spiking_finalresults';

end
    