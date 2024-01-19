function[all_averaged_data_carray] = cell_cell_inst_firing(A)

[Unique,~,idx] = unique(A(:,2),'rows');
cnt = histc(idx,unique(idx));

all_averaged_data_carray = cell(length(Unique), 35);
for i = 1:length(Unique)
    all_averaged_data_carray(i,1) = Unique(i,1);
end

start_idx = 1;
for i = 1:length(cnt) %for each cell
    end_idx = start_idx + (cnt(i)-1);
    working_cell_array = A(start_idx:end_idx,:); %get recordings from that cell
    
    for ii = 3:19
        insert = vertcat(cell2mat(working_cell_array(:,ii)));
        working_mat(2:(length(insert)+1),((ii-2)*2-1):((ii-2)*2)) = insert; %convert it to a cell array
        clearvars insert
    end
    working_mat(1,:) = [];
    %     figure; plot(working_mat(2:end,33),working_mat(2:end,34), 'r*')
    
    
    %you are now working with the matrix that has compiled all times (x)
    %and inst.spike.freq. for all recordings for a single cell, sweep by
    %sweep
    start_replacing = -1;
    for ii = 1:17 %for this one cell, now you will go sweep-by-sweep
        start_replacing = start_replacing + 2;
        x_tobin = working_mat(:, start_replacing);
        y_tobin = working_mat(:, start_replacing+1);
        
        above_5000_idx = find(y_tobin(:,1) > 5000); %one cell has weird point above 5000
        x_tobin(above_5000_idx) = [];
        y_tobin(above_5000_idx) = [];
    
        edges = 1:5:501;
        bins = discretize(x_tobin, edges);
        [meanVal] = grpstats(y_tobin ,bins,{@mean});
        bins = sort(bins);

        [~,dup_idx] = unique(bins(:,1),'stable');
        bins = bins(dup_idx,:);

        length_WM = size(working_mat);
        length_WM = length_WM(1);
        
        bins_nan_array = nan((length_WM-length(bins)),1);
        meanVal_nan_array = nan((length_WM - length(meanVal)),1);
        bins = vertcat(bins,bins_nan_array);
        meanVal = vertcat(meanVal, meanVal_nan_array);

        re_insert = horzcat(bins, meanVal);
        
        working_mat(:, start_replacing:start_replacing+1) = re_insert;
        
        clear bins meanVal
    end
        
    working_mat(:, 1:2:end) = working_mat(:, 1:2:end)*5;
    
    all_averaged_data_carray(i,2:end) = num2cell(working_mat,1);

%     figure;plot(working_mat(2:end,33),working_mat(2:end,34), 'r*')
    clear working_mat
    clear working_cell_array
    start_idx = start_idx + (cnt(i));
    
end

 
 %NEED TO:
 %figure out how to save all cells, individually, such that you could plot
 %them one by one in a loop and then assign error bars. 
 
 %take u
 
 %new cell array to hold all data for condition (numcells+1,35)
 %array(2,i = unique (i). array(i,2:35 is mat2cell(working_mat(2:end:,:)

 %now basically do same thing as in this function: combine all the cell
 %arrays vertcat(cell2mat), column-pair by column-pair and then do the mean
 %thing again where you find the mean of all y values that live in a single
 %bin (so maybe you have to bin again, even though the bins are established
 %now and they all fit neatly in
 
 %nowe in each bin you can get out a SINGLE mean and SEM
 
 %plot that with error bars
 
 %find fit of that mean, will get you single tau for that mean




end