p_folder = uigetdir('Z:\Luke\Behavior\PV-mC4\PV-mC4 (P40 FINAL)\CS');

files = dir(fullfile(p_folder,'**','behavcam_0.avi')); %to determine the folder of each trial
%% FOR OBJ ONLY and NORT
numExps = length(files);
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
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
    
    final_xlsxname = strcat(files(i).folder, '\', 'DLCcoordinates.csv'); 
   
    
    if isfile(final_xlsxname)
        delete(final_xlsxname)
    end
    
    
    
    tempFiles = dir(fullfile(files(i).folder,'behavcam*DLC*0.csv')); 
    numFiles = size(tempFiles);
    
    all_BC=tempFiles;
    
    [size_all_BC,~]=size(all_BC);

    for ii=1:size_all_BC
       temp_other=strsplit(all_BC(ii).name,'DLC'); 
       oldname(ii,1)=string(temp_other(2));
       temp=strsplit(all_BC(ii).name,'_');
       f(ii,1)=string(temp(1));
       temp=strsplit(string(temp(2)),'DLC' );
       f(ii,2)=temp(1);
    end

    for ii=1:size_all_BC
        to_sort_BC(ii,1)=str2num(f(ii,2));
    end

    sorted_BC=sortrows(to_sort_BC);

    for ii=1:size_all_BC
        f(ii,2)=int2str(sorted_BC(ii,1));
    end

    for ii=1:size_all_BC
        final_BC_names(ii,1)=strcat(f(ii,1),'_',f(ii,2),'DLC',oldname(ii,1));
    end
    
   
    BC_0 = xlsread(strcat(all_BC(1).folder, '\', final_BC_names(1,1)));
    [row_number,column_number]=size(BC_0);
    final_BC = zeros(1,column_number);
    final_BC(1:row_number,2:end) = BC_0(:,2:end);
    
    for ii = 2:length(all_BC)
        working_BC=xlsread(strcat(all_BC(ii).folder, '\', final_BC_names(ii,1)));
        final_BC = vertcat(final_BC, working_BC);
        clearvars working_BC
    end
    
    final_BC(:,1) = 1:1:length(final_BC);
    
  
    writematrix(final_BC, final_xlsxname);
        
    
 clearvars -except p_folder files numExps fname
 
end  
    toc
    
%% FOR JUV BLACK MOUSE
numExps = length(files);
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
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
    tempFiles = dir(fullfile(files(i).folder,'behavcam*Black*0.csv')); 
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
        correctedList{ii} = join(['behavcam','_',num2str(ii-1)]);
    end
    
    %reunite entire filename
    fullfilename = x;
    for ii = 1:length(correctedList)
        fullfilename(ii) = strcat(correctedList(ii), fname,f(2)); 
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
    
    if isfile(fullfile(files(i).folder,'DLCcoordinates_BlackMouse.csv'))
        delete(fullfile(files(i).folder,'DLCcoordinates_BlackMouse.csv'))
    end
 
    writecell(finalmat, fullfile(files(i).folder,'DLCcoordinates_BlackMouse.csv'));
 
end  
    toc
    
%% FOR JUV White MOUSE
numExps = length(files);
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
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
    tempFiles = dir(fullfile(files(i).folder,'behavcam*White*0.csv')); 
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
        correctedList{ii} = join(['behavcam','_',num2str(ii-1)]);
    end
    
    %reunite entire filename
    fullfilename = x;
    for ii = 1:length(correctedList)
        fullfilename(ii) = strcat(correctedList(ii), fname,f(2)); 
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
    
    if isfile(fullfile(files(i).folder,'DLCcoordinates_WhiteMouse.csv'))
        delete(fullfile(files(i).folder,'DLCcoordinates_WhiteMouse.csv'))
    end
 
    writecell(finalmat, fullfile(files(i).folder,'DLCcoordinates_WhiteMouse.csv'));
 
end  
    toc