p_folder = uigetdir('Z:\Luke\Behavior\PVxC4KI');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','obj_interactions.mat'));
%files = is_split(files);
numExps = length(files);
final_results = cell(numExps,5,1);
addpath(genpath('Z:\Lab Software and Code\ConnorStuff'));

for i = 1:numExps
    load(fullfile(files(i).folder, 'timestamp.mat'));
    load(fullfile(files(i).folder, 'obj_interactions.mat'));
    load(fullfile(files(i).folder, 'startframe.mat'));
    
    file_delim = strsplit(files(i).folder, '\');
    currentfile = join(file_delim(9));
    final_results(i,1) = currentfile;
    
   for ii = [2:5]
       %2 = periphery
       %3 = center
       %4 = velocity
       %5 = distance traveled
       
       behavior = interactions(:,ii);
       final_results{i,ii} = [];
        if ii == 4
           final_results{i,4} = mean(behavior);
        elseif ii == 5
           final_results{i,5} = sum(behavior);
        else
      
       [percent_time, seconds] = behavior_times(behavior, startframe, timestamp);
       final_results{i,ii} = percent_time*100;
       end
       
   end
end