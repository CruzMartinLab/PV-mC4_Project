%The Purpose of this script is to extract the timestamp data from the 
%Timestamp.Dat file created with every recording in the UCLA Software
%Connor Johnson ACM Lab 1/2/2020
%run on all of MI
p_folder = uigetdir('Z:\Luke\Behavior');
files = dir(fullfile(p_folder,'**','timestamp.dat')); %to select directory from which .dat files will be pulled
numExps = length(files);

MeanTimeElapsBh = [];
perdiff = [];
bhtotalframes = [];
bhtotaltime = [];

numExps = length(files);

    for i = 1:numExps
        %Initialize tempArray
        tempArray = [];
        % Find all msCam videos
        tempFiles = dir(fullfile(files(i).folder,'timestamp.dat'));
        for ii = 1:length(tempFiles)
            tempArray{ii} = fullfile(tempFiles(ii).folder,tempFiles(ii).name);
            M=importdata(tempArray{ii}); %% This will create the matrix version
            defaultcam = M.data(1,1);
            behavecam = M.data(M.data(:,1) == defaultcam,:);
            timestamp=struct;
            timestamp.behavecam = behavecam;
            save(fullfile(files(i).folder,'timestamp.mat'),'timestamp')


        end

    end



