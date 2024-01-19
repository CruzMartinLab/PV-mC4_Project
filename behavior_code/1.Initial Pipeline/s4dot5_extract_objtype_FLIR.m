%This code is meant to distribute the startframe of a trial into its trial
%folder based off of the startframes.xlsx sheet in the behavior folder.
%Make sure that the start frames sheet does not include split trials.

%run on MI1 and MI2 separately
clear
p_folder = uigetdir('Z:\Luke\Behavior\PV-mC4\PV-mC4 (P40 FINAL)\CS');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','obj_type.xlsx')); %to determine the folder of each trial
charfname = char(fullfile(files.folder,'obj_type.xlsx'));
M=readtable(charfname);
M=table2cell(M(:,1:2));
g = M(:,2);
g = cell2mat(g);

%save(fullfile(files.folder,'startframes.mat'), 'startframes');

files = dir(fullfile(p_folder,'**','behavcam_0.avi'));
%files = is_split(files);
numExps = length(files);

for i = 1:numExps
    obj_type= g(i);
    save(fullfile(files(i).folder,'obj_type.mat'),'obj_type');
end