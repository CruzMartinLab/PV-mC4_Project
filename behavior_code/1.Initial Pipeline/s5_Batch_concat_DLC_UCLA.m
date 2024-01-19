p_folder = uigetdir('Z:\Luke\Behavior\');

files = dir(fullfile(p_folder,'**','timestamp.mat')); %to determine the folder of each trial
%% 
numExps = length(files);
addpath(genpath('Z:\Lab Software and Code\ConnorStuff'));
%run on all of MI

%Connor Johnson ACM Lab Boston University 2020 | connorj1@bu.edu

% IF you have an error of files named DLC_ or DeepCut_ please change lines
% 8 and 9

%set fname to the string that is contained in the DLC file name
fname = 'DLC_';
%fname = 'DeepCut_';

tic  
for i = 1:numExps
    %find all the DeepLabCut excel sheets within the trial folder
    tempFiles = dir(fullfile(files(i).folder,'behavCam*.csv')); 
    numFiles = size(tempFiles);

    %extract only behavcam name
    x = [];
    for ii = 1:length(tempFiles)
        f = strsplit(tempFiles(ii).name, fname);
        x = [x f(1)];
    end
    
    correctedList = cell(size(x));
    
    %rewrite list of files so that the numbers are in the correct order
    for ii = 1:size(x,2)
        correctedList{ii} = join(['behavCam',num2str(ii)]);
    end
    
    %reunite entire filename
    fullfilename = x;
    for ii = 1:length(correctedList)
        fullfilename(ii) = strcat(correctedList(ii),fname,f(2)); 
    end
   
    T = struct2table(tempFiles);
    sortedT = sortrows(T, 'date');
    tempFiles = table2struct(sortedT); % This will organize the files incase there is a 10th or greater file 
    iwant = cell(length(fullfilename),1);% this will create a cell where I can combine all my tables

    for ii = 1:length(fullfilename)
        tempArray = char(fullfile(tempFiles(ii).folder,fullfilename(ii)));
        M=readtable(tempArray, 'HeaderLines', 3); %% This will create a matrix from the excel file, which excludes the headers in the first 3 lines
        iwant{ii} = M; %iwant is a cell holding each matrix as the forloop runs its course
    end
    
    %this will concatanate the matrices in each cell
    catmat = cat(1,iwant{:}); 
    frames = 1:height(catmat); 
    catmat = table2array(catmat);
    catmat(:,1) = frames;
    
    [num, txt, raw] = xlsread(tempArray);
    iwant = cell(2,1);
    iwant{1} = txt;
    iwant{2} = num2cell(catmat);
    finalmat = cat(1,iwant{:});
    %write the final excel file back to folder
    
    if isfile(fullfile(files(i).folder,'DLCcoordinates.csv'))
        delete(fullfile(files(i).folder,'DLCcoordinates.csv'))
    end
    
    writecell(finalmat, fullfile(files(i).folder,'DLCcoordinates.csv'));
 
end  
    toc