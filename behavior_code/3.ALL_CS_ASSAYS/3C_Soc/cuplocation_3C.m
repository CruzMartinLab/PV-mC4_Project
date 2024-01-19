

p_folder = uigetdir('Z:\Luke\Behavior');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
addpath(genpath('Y:\Lab Software and Code\RhushStuff'));
files = dir(fullfile(p_folder,'**','mousecup.xlsx')); %to determine the folder of each trial
charfname = char(fullfile(files.folder,'mousecup.xlsx'));
M=readtable(charfname);
M=table2cell(M);
g = M(:,3);
g = cell2mat(g);

files = dir(fullfile(p_folder,'**','timestamp.mat'));
%files = is_split(files);
numExps = length(files);

for i = 1:numExps
    location = g(i);
    save(fullfile(files(i).folder,'cup_location.mat'),'location');
end