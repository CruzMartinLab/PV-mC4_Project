%This code is meant to distribute the startframe of a trial into its trial
%folder based off of the startframes.xlsx sheet in the behavior folder.
%Make sure that the start frames sheet does not include split trials.

%run on MI1 and MI2 separately
clear
p_folder = uigetdir('Z:\Luke\Behavior\');
addpath(genpath('Z:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','mouse_sex.xlsx')); %to determine the folder of each trial
charfname = char(fullfile(files.folder,'mouse_sex.xlsx'));
M=readtable(charfname);
M=table2cell(M(:,1:2));
g = M(:,2);
g = cell2mat(g);

%save(fullfile(files.folder,'startframes.mat'), 'startframes');

files = dir(fullfile(p_folder,'**','timestamp.mat'));
%files = is_split(files);
numExps = length(files);

for i = 1:numExps
    sex= g(i);
    save(fullfile(files(i).folder,'mouse_sex.mat'),'sex');
end