function[all_averaged_data_mat, stdVal_array] = final_inst_firing(A)

for i = 1:34 %for -10pA - 470pA
    insert = vertcat(cell2mat(A(:,i)));
    all_averaged_data_mat(:,i) = insert;
    clearvars insert
end

stdVal_array = nan(length(all_averaged_data_mat), 34)

start_replacing = -1;
for ii = 1:17 %now with all cells from this condition in a mat format, you go sweep by sweep
    start_replacing = start_replacing + 2;
    x_tobin = all_averaged_data_mat(:, start_replacing);
    y_tobin = all_averaged_data_mat(:, start_replacing+1);

    edges = 1:5:501;
    bins = discretize(x_tobin, edges);
    [meanVal, stdVal] = grpstats(y_tobin,bins,{@nanmean, @std});
    bins = sort(bins);

    [~,dup_idx] = unique(bins(:,1),'stable');
    bins = bins(dup_idx,:);

    length_AADM = size(all_averaged_data_mat);
    length_AADM = length_AADM(1);

    bins_nan_array = nan((length_AADM-length(bins)),1);
    meanVal_nan_array = nan((length_AADM - length(meanVal)),1);
    stdVal_nan_array = nan((length_AADM - length(stdVal)),1);
    
    bins = vertcat(bins,bins_nan_array);
    meanVal = vertcat(meanVal, meanVal_nan_array);
    stdVal = vertcat(stdVal, stdVal_nan_array);
    
    stdVal_array(:,ii*2) = stdVal(:,1);
    
    re_insert = horzcat(bins, meanVal);

    all_averaged_data_mat(:, start_replacing:start_replacing+1) = re_insert;

    clear bins meanVal stdVal re_insert
end

all_averaged_data_mat(:, 1:2:end) = all_averaged_data_mat(:, 1:2:end)*5;
stdVal_array(:,1:2:end) = all_averaged_data_mat(:,1:2:end);

all_averaged_data_mat(102:end,:) = [];
stdVal_array(102:end,:) = [];



% plot(all_averaged_data_mat(:,33), all_averaged_data_mat(:,34), '*r');
% hold on
% plot(stdVal_array(:,33),all_averaged_data_mat(:,34)+stdVal_array(:,34))
% hold on
% plot(stdVal_array(:,33),all_averaged_data_mat(:,34)-stdVal_array(:,34))
% ylabel('Instantaneous Spiking Freq (Hz)')
% xlabel('Time (ms)')
% title('I_i_n_j = 470')%,num2str(I_inj(i))]);
% xlim([0 500])
% legend('points to fit', '+STD', '-STD')
% %ylim([0 max(ydata)+20])

end