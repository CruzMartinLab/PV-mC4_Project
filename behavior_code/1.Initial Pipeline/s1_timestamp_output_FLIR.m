%The Purpose of this script is to concatenate all the timestamps from a
%mouse folder that is output when using the FLIR cameras via bonsai 
%LF 2023/2
%p_folder = uigetdir('Z:\Luke\Behavior');

p_folder = uigetdir('Z:\Luke\Behavior\PV-mC4\PV-mC4 (P40 FINAL)\CS');
mouse = dir(fullfile(p_folder,'**','*Timestamp_0*.csv')); %to select directory from which .dat files will be pulled
num_mice = length(mouse);

for i = 1:num_mice
    final_xlsxname = strcat(mouse(i).folder, '\', 'TimeStamp.csv'); 
    final_xlsxname_mat = strcat(mouse(i).folder, '\', 'TimeStamp.mat');
    
    if isfile(final_xlsxname)
        delete(final_xlsxname)
    end
    
    if isfile(final_xlsxname_mat)
        delete(final_xlsxname_mat)
    end
    
    all_TS = dir(fullfile(mouse(i).folder, '*Timestamp*.csv'));
    
    
    [size_all_TS,~]=size(all_TS);

    for ii=1:size_all_TS
       temp=strsplit(all_TS(ii).name,'_');
       f(ii,1)=string(temp(1));
       temp=strsplit(string(temp(2)),'.' );
       f(ii,2)=temp(1);
    end

    for ii=1:size_all_TS
        to_sort_TS(ii,1)=str2num(f(ii,2));
    end

    sorted_TS=sortrows(to_sort_TS);

    for ii=1:size_all_TS
        f(ii,2)=int2str(sorted_TS(ii,1));
    end

    for ii=1:size_all_TS
        final_TS_names(ii,1)=strcat(f(ii,1),'_',f(ii,2),'.csv');
    end
    
    final_TS = zeros(1,3);
    TS_0 = xlsread(strcat(all_TS(1).folder, '\', final_TS_names(1,1)));
    final_TS(1:length(TS_0),2:3) = TS_0;
    
    for ii = 2:length(all_TS)
        working_TS(:,2:3) = xlsread(strcat(all_TS(ii).folder, '\', final_TS_names(ii,1)));
        final_TS = vertcat(final_TS, working_TS);
        clearvars working_TS
    end
    
    final_TS(:,1) = 1:1:length(final_TS);
    
  
    writematrix(final_TS, final_xlsxname);
    save(final_xlsxname_mat, 'final_TS');
    
    
    clearvars TS_0
    clearvars final_TS
end




