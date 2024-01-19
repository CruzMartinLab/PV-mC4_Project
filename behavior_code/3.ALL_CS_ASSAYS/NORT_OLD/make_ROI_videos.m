%% FOR NORT 5 Min
clear
%Enter the columns of the DLCcoordinates.csv for each marker w/ likelihood
snout=32:34 ;
head=38:40;
centroid=53:55;
topleft=2:3;
topright=5:6;
bottomleft=8:9;
bottomright=11:12;
bottle1_tr=14:16;
bottle1_bl=17:19;
bottle2_tr=20:22;
bottle2_bl=23:25;
nov_tr=26:28;
nov_bl=29:31;


%Set threshold DLC confidence for choice between snout and head tracking
thresh = 0.90;

%Get folders when behavior files are. Please select MI1 and MI2 separately
p_folder = uigetdir('Y:\Luke\Behavior\');

logs = dir(fullfile(p_folder,'**','DLCcoordinates.csv'));
vlogs = dir(fullfile(p_folder,'**','behavcam*.avi'));

%% FOR NORT 30 Min
clear
%Enter the columns of the DLCcoordinates.csv for each marker w/ likelihood
snout=29:31 ;
head=35:37;
centroid=50:52;
topleft=2:3;
topright=5:6;
bottomleft=8:9;
bottomright=11:12;
bottle1_tr=14:16;
bottle1_bl=17:19;
bottle2_tr=20:22;
bottle2_bl=23:25;
nov_peak=26:28;


%Set threshold DLC confidence for choice between snout and head tracking
thresh = 0.90;

%Get folders when behavior files are. Please select MI1 and MI2 separately
p_folder = uigetdir('Y:\Luke\Behavior\');

logs = dir(fullfile(p_folder,'**','DLCcoordinates.csv'));
vlogs = dir(fullfile(p_folder,'**','behavcam*.avi'));




%%
%For 5 min
i=1;
load(fullfile(logs(i).folder,'startframe.mat'));
load(fullfile(logs(i).folder,'mouse_explore.mat'));
s=startframe;
file_delim = strsplit(logs(i).folder, '\');
[~,n]=size(file_delim);
currentfile = file_delim(n);
trial=char(file_delim(n-1));
nort_type=char(file_delim(n-2));

[NUM,~,~] = xlsread(fullfile(logs(i).folder,logs(i).name));
corners=NUM(:,[topleft,topright,bottomleft,bottomright]);
obj1=NUM(:,[bottle1_tr,bottle1_bl]);
obj2=NUM(:,[bottle2_tr,bottle2_bl]);
nov=NUM(:,[nov_tr,nov_bl]);
mouse=NUM(:,[snout, head, centroid]);

corners=mean(corners(1:10,:));
tl=[corners(1) corners(2)];
tr=[corners(3) corners(4)];
bl=[corners(5) corners(6)];
br=[corners(7) corners(8)];


obj1=mean(obj1(s:size(obj1),:));
obj2=mean(obj2(s:size(obj2),:));
nov=mean(nov(s:size(nov),:));

obj1=[obj1(1) obj1(2) obj1(4) obj1(5)];
obj2=[obj2(1) obj2(2) obj2(4) obj2(5)];

nov=[nov(1) nov(2) nov(4) nov(5)];

frame_cor=[tl(1) tl(2); tr(1) tr(2); bl(1) bl(2);br(1) br(2)];
if contains(trial,'T4')
    frame_obj=[nov(1) nov(2); nov(3) nov(4);obj2(1) obj2(2); obj2(3) obj2(4)];
else
    frame_obj=[obj1(1) obj1(2); obj1(3) obj1(4);obj2(1) obj2(2); obj2(3) obj2(4)];
end
%%
%For 30 min
i=1;
load(fullfile(logs(i).folder,'startframe.mat'));
load(fullfile(logs(i).folder,'mouse_explore.mat'));
s=startframe;
file_delim = strsplit(logs(i).folder, '\');
[~,n]=size(file_delim);
currentfile = file_delim(n);
trial=char(file_delim(n-1));
nort_type=char(file_delim(n-2));

[NUM,~,~] = xlsread(fullfile(logs(i).folder,logs(i).name));
corners=NUM(:,[topleft,topright,bottomleft,bottomright]);
obj1=NUM(:,[bottle1_tr,bottle1_bl]);
obj2=NUM(:,[bottle2_tr,bottle2_bl]);
nov=NUM(:,[nov_peak]);
mouse=NUM(:,[snout, head, centroid]);

corners=mean(corners(1:10,:));
tl=[corners(1) corners(2)];
tr=[corners(3) corners(4)];
bl=[corners(5) corners(6)];
br=[corners(7) corners(8)];


obj1=mean(obj1(s:size(obj1),:));
obj2=mean(obj2(s:size(obj2),:));
nov=mean(nov(s:size(nov),:));

obj1=[obj1(1) obj1(2) obj1(4) obj1(5)];
obj2=[obj2(1) obj2(2) obj2(4) obj2(5)];

nov=[nov(1) nov(2)];


nov_w1=(nov(1)-tl(1))/2;
nov_w2=nov(1)-tl(1);

nov_h1=(nov(2)-tl(2))/3;
nov_h2=nov(2)-tl(2);   

nov_tr(1)=nov(1)+nov_w2;
nov_tr(2)=nov(2)-nov_h1;

nov_bl(1)=nov(1)-nov_w1;
nov_bl(2)=nov(2)+nov_h2;

nov=[nov_tr(1) nov_tr(2) nov_bl(1) nov_bl(2)];

frame_cor=[tl(1) tl(2); tr(1) tr(2); bl(1) bl(2);br(1) br(2)];
if contains(trial,'T4')
    frame_obj=[nov(1) nov(2); nov(3) nov(4);obj2(1) obj2(2); obj2(3) obj2(4)];
else
    frame_obj=[obj1(1) obj1(2); obj1(3) obj1(4);obj2(1) obj2(2); obj2(3) obj2(4)];
end

%%
[numVideos,~]=size(vlogs);

for ii=1:numVideos       
       temp=strsplit(vlogs(ii).name,'_');
       f(ii,1)=string(temp(1));
       temp=strsplit(string(temp(2)),'.' );
       f(ii,2)=temp(1);    
end

for ii=1:numVideos
        to_sort_BV(ii,1)=str2num(f(ii,2));
end
 
  sorted_BV=sortrows(to_sort_BV);
  
for ii=1:numVideos
        f(ii,2)=int2str(sorted_BV(ii,1));
end
  

for ii=1:numVideos
        final_BV_names(ii,1)=strcat(f(ii,1),'_',f(ii,2),'.avi');
end


count=1;
for ii=1:numVideos

oldv= VideoReader(strcat(vlogs(ii).folder, '\', final_BV_names(ii,1)));
temp=strcat(vlogs(ii).folder, '\', 'ROI',final_BV_names(ii,1));
newv= VideoWriter(char(temp));

open(newv);


while hasFrame(oldv)
    frame = readFrame(oldv);
    for j=1:4
          frame=mark_frame([frame_cor(j,1) frame_cor(j,2)],frame,3,[50 50 200]);
    end
    
    for j=1:4
          frame=mark_frame([frame_obj(j,1) frame_obj(j,2)],frame,3,[200 200 200]);
    end
     
     snout=mouse(count,1:3);
     head=mouse(count,4:6);     
     centroid=mouse(count,7:9);
     
        if snout(3)>thresh
           frame=mark_frame([snout(1) snout(2)],frame);
        end

        if head(3)>thresh 
            frame=mark_frame([head(1) head(2)],frame);
        end

        if centroid(3)>thresh 
            frame=mark_frame([centroid(1) centroid(2)],frame);
        end
        
        if interactions(count,2)==1
            if contains(trial,'T4')
               frame=mark_frame([((nov(1)+nov(3))/2) ((nov(2)+nov(4))/2)],frame,10,[250 250 0]);
            else
               frame=mark_frame([((obj1(1)+obj1(3))/2) ((obj1(2)+obj1(4))/2)],frame,10,[250 250 0]);
            end
        end

        if interactions(count,3)==1                               
            frame=mark_frame([((obj2(1)+obj2(3))/2) ((obj2(2)+obj2(4))/2)],frame,10,[250 250 0]);
        end

            
            writeVideo(newv, frame);
            count=count+1;
end
close(newv);
end