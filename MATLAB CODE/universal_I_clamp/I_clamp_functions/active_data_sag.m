%edited 1/19/22: deletes any sag excel file before writing new one

function [sag_data] = active_data_sag(sag_files,sag_injcur, num_sag_sweeps, spiking_time_s)
sag_data = cell(11,(length(sag_files)*5+3));
    sag_data(1,1) = {'Injected Current'};
    sag_data(1,end-1) = {'Average Delta'};
    sag_data(1,end) = {'Average Sag'};
        for k = 2:11
    sag_data{k,1} = sag_injcur(k-1,1);
        end

%clear any existing .emfs, .figs, .xlsx        
emfs = dir(strcat(sag_files(1).folder, '\*.emf'));      
figs = dir(strcat(sag_files(1).folder, '\*.fig'));        
excels = dir(strcat(sag_files(1).folder, '\*.xlsx'));  
        
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


fill_col = 2;               
for ii = 1:length(sag_files)
path_parts = regexp(sag_files(ii).folder, '\', 'split');
 
 [sag_d,~,~] = abfload_fcollman(strcat(sag_files(ii).folder, '\', sag_files(ii).name));
 d_mV = squeeze(sag_d(:,1,:)); 
 d_mV_dim = size(d_mV);
 
 if d_mV_dim(1,2) == 14
     d_mV = d_mV;
 elseif d_mV_dim(1,2) == 18
     d_mV = d_mV(:,5:end);
 end
%Can uncomment this out when you want to see a single file
% [sag_d,~,~] = abfload_fcollman("Z:\Luke\Electrophysiology\PVxC4KI\Active Properties\PVC4^WT\58505_2\PYR_Cell\cell3\sag\2022_09_29_0043.abf");
%  d_mV = squeeze(sag_d(:,1,:));
%  plot(spiking_time_s(24000:40000), d_mV(24000:40000,1));
 
    
    %save .emf of current injection of -500pA
    figure;
    plot(spiking_time_s(24000:40000), d_mV(24000:40000, 1));
    basefilename = strcat(sag_files(ii).name, '.emf');
    savefilename = strcat(sag_files(ii).folder, '\', basefilename);
    saveas(gcf, savefilename);
    close;
 
sag_data(1,fill_col) =  {strcat(sag_files(ii).name, '_baseline')};
sag_data(1,fill_col+1) =  {strcat(sag_files(ii).name, '_min_mV')};
sag_data(1,fill_col+2) =  {strcat(sag_files(ii).name, '_steady_state')};
sag_data(1,fill_col+3) =  {strcat(sag_files(ii).name, '_delta')};
sag_data(1,fill_col+4) =  {strcat(sag_files(ii).name, '_sag')};

for iii = 1:10 %for each negative
    working_d_mV = d_mV(:,iii);
    fill_row = iii+1;
    
    v_bl = mean(working_d_mV(24650:25650)); %50ms before pulse
    [v_min,v_min_idx] = min(working_d_mV(25656:26656)); %50ms after pulse at 1282.8 
    v_min = mean(working_d_mV((v_min_idx+25655) - 2: (v_min_idx+25655)+ 2)); %average 5 points
    v_ss = mean(working_d_mV(34640:35640)); %ss is 50ms right before the pulse ends
    
    sag_data(fill_row, fill_col) = {v_bl};
    sag_data(fill_row, fill_col+1) = {v_min};
    sag_data(fill_row, fill_col+2) = {v_ss};
    sag_data(fill_row, fill_col+3) = {v_ss - v_min};
    sag_data(fill_row, fill_col+4) = {(v_ss - v_min) / (v_bl - v_min)};
    
end

fill_col = fill_col + 5;
       
end

if length(sag_data) == 18
    for avg = 2:11
        sag_data(avg,end-1) = {mean(cell2mat(sag_data(avg, [5,10,15])))};
        sag_data(avg,end) = {mean(cell2mat(sag_data(avg, [6,11,16])))};
    end
end

%save data for cell
basefilename = strcat(path_parts(7), '_', path_parts(8), '_', path_parts(9), '_sagdata.xlsx');
basefilename = char(basefilename);
savefilename = strcat(sag_files(ii).folder, '\', basefilename);
if isfile(savefilename) %delete old excel from folder before writing new one
    delete(savefilename)
end
xlswrite(savefilename, sag_data);
   
