%%
clear

%bodyparts
snout=14:16 ;
nose_bridge=17:19;
head=20:22;
neck=29:31;
bdypt1=38:40;
centroid=41:43;
bdypt2=44:46;
tailbase=47:49;
topleft=2:3;
topright=5:6;
bottomleft=8:9;
bottomright=11:12;

%threshold
thresh=0.90;

%%

%Get folders when behavior files are. Please select MI1 and MI2 separately

p_folder = uigetdir('Z:\Luke\Behavior\');

logs_black = dir(fullfile(p_folder,'**','DLCcoordinates_BlackMouse.csv'));
logs_white = dir(fullfile(p_folder,'**','DLCcoordinates_WhiteMouse.csv'));


%%

addpath(genpath('Y:\Lab Software and Code\Rhush Stuff'));

numFiles_black=length(logs_black);
numFiles_white=length(logs_white); 

final_results=cell(numFiles_black+1,9);
final_results(1,1)={'Mouse Name'};
final_results(1,2)={'Snout to Snout'};
final_results(1,3)={'Active Snout to Butt'};
final_results(1,4)={'Passive Snout to Butt'};
final_results(1,5)={'Active Snout to Body'};
final_results(1,6)={'Body to Body'};
final_results(1,7)={'Chase'};
final_results(1,8)={'Genotype'};
final_results(1,9)={'Sex'};
final_results(1,10)={'Passive Snout to Body'};

f = waitbar(0, 'Starting');

for i=1:numFiles_black
    waitbar(i/numFiles_black, f, sprintf('Look at them interact: %d %%', floor(100*i/numFiles_black)));
    file_delim = strsplit(logs_black(i).folder, '\');
    [~,m]=size(file_delim);
    currentfile = file_delim(m);
    load(fullfile(logs_black(i).folder,'startframe.mat'));
    load(fullfile(logs_black(i).folder,'genotype.mat'));
    load(fullfile(logs_black(i).folder,'mouse_sex.mat'));
    
    %Name for trajectory to be saved
    figpath=strcat(logs_black(i).folder,'\','mice_position.jpg');
    
    %Write the mouse number to file
    final_results(i+1,1) = currentfile;
    
    
    %Read in DLC files
    [NUM_black,~,~] = xlsread(fullfile(logs_black(i).folder,logs_black(i).name));
    [NUM_white,~,~] = xlsread(fullfile(logs_white(i).folder,logs_white(i).name));
    
    
    video1=VideoReader(fullfile(logs_black(i).folder,'behavcam_0.avi'));
    video2=VideoReader(fullfile(logs_black(i).folder,'behavcam_1.avi'));
    count=0;
    
    while(hasFrame(video1))
        frame=readFrame(video1);
        count=count+1;
    end
    
    while(hasFrame(video2))
        frame=readFrame(video2);
        count=count+1;
    end   
    
    interactions=JUVINT(i,count,currentfile,NUM_black(:,[topleft,topright,bottomleft,bottomright]),NUM_black(:,[snout,nose_bridge, head,neck,bdypt1, centroid,bdypt2,tailbase]),NUM_white(:,[snout,nose_bridge, head,neck,bdypt1, centroid,bdypt2,tailbase]),startframe, VideoReader(fullfile(logs_black(i).folder,'behavcam_2.avi')), VideoWriter(fullfile(logs_black(i).folder,'behavCam2_ROI'),'MPEG-4'), thresh);
    
    
    [m,~]=size(interactions);
    %m=startframe+9000;   
    save(fullfile(fullfile(logs_black(i).folder,'mouse_explore.mat')),'interactions');
    interactions=interactions(startframe:m,:);
    [m,~]=size(interactions);

    summation=sum(interactions);
    
    summation=100*summation/m;
    
    for j=2:7
        final_results(i+1,j)=num2cell(summation(j+2));
    end
    final_results(i+1,10)=num2cell(summation(10));
    final_results(i+1,8)=cellstr(genotype); 
    
    final_results(i+1,9)=cellstr(sex);
  
    
    
    
end

close(f)

function interactions=JUVINT(i,frame_fix,currentfile,corners,mouse_black, mouse_white,s, oldv, newv, thresh)

    corners=mean(corners(s:end,:));
    
    tl=[corners(1) corners(2)];
    tr=[corners(3) corners(4)];
    bl=[corners(5) corners(6)];
    br=[corners(7) corners(8)];
 
    
    [m,~]=size(mouse_black);
    interactions=cell(m,10);
    
    interactions{1,1}={'Frame'};
    interactions{1,2}={'Active snout to snout'};
    interactions{1,3}={'Passive snout to snout'};
    interactions{1,4}={'Snout to Snout'};
    interactions{1,5}={'Active Nose to Butt'};
    interactions{1,6}={'Passive Nose to Butt'};
    interactions{1,7}={'Active Snout to Body'};
    interactions{1,8}={'Body to Body'};
    interactions{1,9}={'Chase'};
    
    mouse_head_size=(tl(2)-bl(2))/13;
    mouse_head_size=abs(floor(mouse_head_size));
    
    for j=2:m
    
        mb=mouse_black(j,[1:2,4:5,7:8,10:11,13:14,16:17,19:20,22:23]);
        mbt=mouse_black(j,[3,6,9,12,15,18,21,24]);

        mw=mouse_white(j,[1:2,4:5,7:8,10:11,13:14,16:17,19:20,22:23]);
        mwt=mouse_white(j,[3,6,9,12,15,18,21,24]);

        parts=length(mbt);

        interactions{j-1}=j-1;

        %Snout to snout interactions in column 4
        [active_snout_distances]=check_distances(mb,mw,1,1,3,mouse_head_size);
        active_thresholds=mwt(1:3);

        if active_thresholds(1)>thresh 
            if active_snout_distances(1)==1
                interactions{j,2}=true;
            end
        elseif active_thresholds(2)>thresh
            if active_snout_distances(2)==1
                interactions{j,2}=true;
            end
        end


        [passive_snout_distances]=check_distances(mw,mb,1,1,3,mouse_head_size);
        passive_thresholds=mbt(1:3);

        if passive_thresholds(1)>thresh 
            if passive_snout_distances(1)==1
                interactions{j,3}=true;
            end
        elseif passive_thresholds(2)>thresh
            if passive_snout_distances(2)==1
                interactions{j,3}=true;
            end
        end

        if  interactions{j,3}==true 
            if interactions{j,2}==true
                interactions{j,4}=true;
            end
        end

        %snout to butt interactions in column 5 and 6
        [active_butt_distances]=check_distances(mb,mw,1,7,2,mouse_head_size);
        active_thresholds=mwt(7:8);

        if active_thresholds(2)>thresh 
            if active_butt_distances(2)==1
                interactions{j,5}=true;
            end
        elseif active_thresholds(1)>thresh
            if active_butt_distances(1)==1
                interactions{j,5}=true;
            end
        end

        [passive_butt_distances]=check_distances(mw,mb,1,7,2,mouse_head_size);
        passive_thresholds=mbt(7:8);

        if passive_thresholds(2)>thresh 
            if passive_butt_distances(2)==1
                interactions{j,6}=true;
            end
        elseif passive_thresholds(1)>thresh
            if passive_butt_distances(1)==1
                interactions{j,6}=true;
            end
        end

        %Active Snout to body interactions in column 7
        [active_body_distances_snout]=check_distances(mb,mw,1,5,3,mouse_head_size);
        [active_body_distances_head]=check_distances(mb,mw,3,5,3,mouse_head_size);

        if mbt(1)>thresh
            if any(active_body_distances_snout)
                interactions{j,7}=true;
            end
        elseif mbt(3)>thresh
            if any(active_body_distances_head)
                interactions{j,7}=true;
            end
        end

        if interactions{j,5}==true
            interactions{j,7}=false;
        end
        
        %Passive Snout to body interactions in column 7
        [passive_body_distances_snout]=check_distances(mw,mb,1,5,3,mouse_head_size);
        [passive_body_distances_head]=check_distances(mw,mb,3,5,3,mouse_head_size);

        if mwt(1)>thresh
            if any(passive_body_distances_snout)
                interactions{j,10}=true;
            end
        elseif mwt(3)>thresh
            if any(passive_body_distances_head)
                interactions{j,10}=true;
            end
        end

        if interactions{j,6}==true
            interactions{j,10}=false;
        end

        %Body to Body interactions in column  8
        [active_body_distances]=zeros(4,4);

        for ii=4:7
           [active_body_distances(ii-3,:)]=check_distances(mb,mw,ii,4,4,mouse_head_size); 
        end

        for ii=4:7
            if mbt(ii)>thresh
                if any(active_body_distances(ii-3,:))
                    interactions{j,8}=true;
                end
            end
        end
        
        if interactions{j,5}==true
             interactions{j,8}=false;
        end
        if interactions{j,6}==true
             interactions{j,8}=false;
         end
        if interactions{j,7}==true
             interactions{j,8}=false;
        end
        
   
        %Chase in column 9

        diff=mw(11:12)-mb(11:12);
        mod_mw=mw(7:8)-diff;
        theta=find_mouse_angle(mod_mw(1:2),mb(7:8),mb(11:12));
        if abs(theta)<90
           interactions{j,9}=true;
        end

        if interactions{j,4}==true
            interactions{j,9}=false;
        end
        if interactions{j,6}==true
            interactions{j,9}=false;
        end
        if interactions{j,7}==true
            interactions{j,9}=false;
        end

        [no_chase_distances]=zeros(3,3);

        for ii=3:5
           [no_chase_distances(ii-2,:)]=check_distances(mb,mw,ii,3,3,0.75*mouse_head_size); 
        end

        for ii=3:5
            if mbt(ii)>thresh
                if any(no_chase_distances(ii-2,:))
                    interactions{j,9}=false;
                end
            end
        end

    end
    
    open(newv)
    
    f=frame_fix;

    wb = waitbar(0, 'Starting');
    
    while (f<(frame_fix+900))
        waitbar((f-frame_fix)/900, wb, sprintf('What are they doing? Dear lord: %d %%', floor(100*(f-frame_fix)/900)));
        frame=readFrame(oldv);

        s=mouse_black(f,1:2);
        h=mouse_black(f,7:8);
        t=mouse_black(f,22:23);
        sw=mouse_white(f,1:2);
        hw=mouse_white(f,7:8);
        tw=mouse_white(f,22:23);

        frame=mark_frame([s(1) s(2)],frame,3,[0 250 0]);
        frame=mark_frame([h(1) h(2)],frame,3,[250 0 0]);
        frame=mark_frame([t(1) t(2)],frame,3,[0 0 250]);

        frame=mark_frame([sw(1) sw(2)],frame,3,[250 250 0]);
        frame=mark_frame([hw(1) hw(2)],frame,3,[250 0 250]);
        frame=mark_frame([tw(1) tw(2)],frame,3,[0 250 250]);
        
        %snout to snout (red)
        if interactions{f,4}==true
            frame=mark_frame([256 256],frame,10,[250 0 0]);
        end

        %snout to butt active (blue)
         if interactions{f,5}==true
            frame=mark_frame([256 256],frame,10,[0 0 250]);
         end

         %snout to butt passive(cyan)
         if interactions{f,6}==true
            frame=mark_frame([226 256],frame,10,[0 250 250]);
         end

         %snout to body(white)
         if interactions{f,7}==true
            frame=mark_frame([226 226],frame,10,[250 250 250]);
         end

         %body to body(magenta)
         if interactions{f,8}==true
            frame=mark_frame([226 200],frame,10,[250 0 250]);
         end

         %chase(yellow)
          if interactions{f,9}==true
            frame=mark_frame([200 200],frame,10,[250 250 0]);
          end
         %passive snout to body(green)
          if interactions{f,10}==true
            frame=mark_frame([200 300],frame,10,[0 250 0]);
        end
    
         writeVideo(newv, frame);
         f=f+1;
    end

    close(newv)
    close(wb)
    
    mat = zeros(m,10);
    for j = 1:m-1
        if (~isempty(interactions{j+1,1}))
            mat(j,1) = interactions{j+1,1};
        end
        
        if (~isempty(interactions{j+1,2}))
            mat(j,2) = interactions{j+1,2};
        end
        
        if (~isempty(interactions{j+1,3}))
            mat(j,3) = interactions{j+1,3};
        end
        
        if (~isempty(interactions{j+1,4}))
            mat(j,4) = interactions{j+1,4};
        end
        
        if (~isempty(interactions{j+1,5}))
            mat(j,5) = interactions{j+1,5};
        end
        
        if (~isempty(interactions{j+1,6}))
            mat(j,6) = interactions{j+1,6};
        end
        
        if (~isempty(interactions{j+1,7}))
            mat(j,7) = interactions{j+1,7};
        end
        
        if (~isempty(interactions{j+1,8}))
            mat(j,8) = interactions{j+1,8};
        end
        
        if (~isempty(interactions{j+1,9}))
            mat(j,9) = interactions{j+1,9};
        end
        
         if (~isempty(interactions{j+1,10}))
            mat(j,10) = interactions{j+1,10};
        end
        
    end
    interactions = mat;
    
    
    
end
