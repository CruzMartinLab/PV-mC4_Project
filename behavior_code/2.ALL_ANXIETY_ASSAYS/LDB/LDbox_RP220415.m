%% Values to Set

%Enter the columns of the DLCcoordinates.csv for each marker w/ likelihood
 clear
snout =14:16;
nose_bridge=17:19;
head=20:22;
left_ear=23:25;
right_ear=26:28;
neck=29:31;
bodypt1=32:34;
centroid=35:37;
bodypt2=38:40;
tailbase=41:43;
topleft=2:3;
topright=5:6;
bottomleft=8:9;
bottomright=11:12;




%Set threshold DLC confidence for choice between snout and head tracking
thresh = 0.90;


%%
%Get folders when behavior files are. Please select MI1 and MI2 separately
p_folder = uigetdir('Z:\Luke\Behavior\');

logs = dir(fullfile(p_folder,'**','DLCcoordinates.csv'));
%% 

addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
addpath(genpath('Y:\Lab Software and Code\Rhush Stuff'));

%logs = is_split(logs);
numFiles=length(logs);%% 


final_results=cell(numFiles+1,7);
final_results(1,1)={'Mouse Name'};
final_results(1,2)={'Peek'};
final_results(1,3)={'Explore'};
final_results(1,4)={'Distance Travelled (m)'};
final_results(1,5)={'Instantaneous Velocity (m/s)'};
final_results(1,6)={'Time at entrance (s)'};
final_results(1,7)={'Genotype'};
final_results(1,8)={'Sex'};


for i=1:numFiles
    
    s = regexp(logs(i).name, '\', 'split');
    file_delim = strsplit(logs(i).folder, '\');
    load(fullfile(logs(i).folder,'timestamp.mat'));
    load(fullfile(logs(i).folder,'startframe.mat'));
    load(fullfile(logs(i).folder,'genotype.mat'));
     load(fullfile(logs(i).folder,'mouse_sex.mat'));
    %read in the DLC file
    [NUM,~,~] = xlsread(fullfile(logs(i).folder,logs(i).name));
    %working_filename = strcat(logs(i).folder, '\', logs(i).name)
    %[NUM,~,~] = csvread('Y:\Luke\Behavior\PVxC4KI\PVxC4KI - Young Adult [NEW]\ANX\2.LDB\LDB\38589_1\DLCcoordinates.csv');
    [~,m]=size(file_delim);
    currentfile = file_delim(m);
    %Name for graph to be saved
    figpath=strcat(logs(i).folder,'\','_mouse_position.emf');
    
    
    final_results(i+1,1) = currentfile;
        
    
    interactions=LDB(i,currentfile,NUM(:,[topleft,topright,bottomleft,bottomright]),NUM(:,[head, centroid,tailbase]),startframe, VideoReader(fullfile(logs(i).folder,'behavCam1.avi')), VideoWriter(fullfile(logs(i).folder,'behavCam1_ROI.avi')), thresh);       
     
   %save current figure
   saveas(gcf,figpath);
   close(gcf);
    
   %calculate % times for various zones as well as total distance, average velocity 
 [m,~]=size(interactions);
 
 
   interactions=interactions(startframe:m,:);
   
   save(fullfile(fullfile(logs(i).folder,'mouse_explore_heat.mat')),'interactions');
  
  [m,~]=size(interactions);
   
   summation=sum(interactions);
    
   
    for j=2:3
        summation(j)=100*summation(j)/m;
    end
    
    summation(8)=100*summation(8)/m;
    
    summation(5)=summation(5)/m;
    
    for k=2:5
       final_results(i+1,k)=num2cell(summation(k)); 
    end
    final_results(i+1,6)=num2cell(summation(8));
    final_results(i+1,7)=cellstr(genotype);
    final_results(i+1,8)=cellstr(sex);
    
    fprintf('%d files remaining\n',numFiles-i);
    
    clear NUM;
    
end




function interactions =LDB(i,currentfile,corners,mouse,s, oldv, newv, thresh)
    [m,~]=size(mouse);
    interactions = cell(m+1,9);
    
    %new video for ROI
    open(newv);
    
    interactions{1,1}={'Frame'};
    interactions{1,2}={'Peek'};
    interactions{1,3}={'Explore'};
    interactions{1,4}={'Distance Travelled (m)'};
    interactions{1,5}={'Average Velocity (m/s)'};
    interactions{1,6}={'Distance From Hole (m)'};
    interactions{1,7}={'Distance from wall (m)'};
    interactions{1,8}={'Time at entrance'};
    interactions{1,9}={'Butts out'};
    
    
    %set boundaries of the field and account for small deviations
    corners=mean(corners);
    tl=[corners(1) corners(2)];
    tr=[corners(3) corners(4)];
    bl=[corners(5) corners(6)];
    br=[corners(7) corners(8)];
    
    if (tl(2)<tr(2))
        tl(2)=tr(2);
    else tr(2)=tl(2);
    end
    
    if(tl(1)<bl(1))
        tl(1)=bl(1);
    else bl(1)=tl(1);
    end
    
    if (bl(2)<br(2))
        bl(2)=br(2);
    else br(2)=bl(2);
    end
    
    br(1)=tr(1);
    br(2)=bl(2);   

    hole(1)=(tl(1)+tr(1))/2;
    hole(2)=bl(2);
    
    width=tr(1)-tl(1);
    height=bl(2)-tl(2);
    
    entrance_height=2*height/15;
    entrance_width=2*width/15; 
    
    
    %convert pixels to meters   
    width = pdist([tl;tr]);
    pix_per_m = width/0.306;

    %will become true when thresh is crossed for dlc points
    chance=false;
    

for j=2:m
    
     interactions{j,1} = (j-1);
    
     tailbase=mouse(j-1,7:8);
     head=mouse(j-1,1:2);
     exist_head=mouse(j-1,3);
     centroid=mouse(j-1,4:5);
     exist_centroid=mouse(j-1,6);
     tailbase=mouse(j-1,7:8);
     exist_tailbase=mouse(j-1,9);
     if (j==2)
         prev=mouse(j-1,4:5);
     else prev=mouse(j-2,4:5);
     end

     
     if mouse(j-1,6)>=thresh
         chance=true;
    
     else chance=false;
     end
     
                 
     if(chance)
        
            interactions{j,2} = false;
            interactions{j,3} = false;
                
            
            dis=0;
            
            if (j == 2)
            interactions{j,5}=0;
            else
                %distance and velocity per frame
                dis = pdist([centroid;prev]);
            dis = dis/pix_per_m;
            interactions{j,5} = dis*30;%because 30 fps to convert to m/s
         end 
        interactions{j,4}=dis;
     end   
     
     
       if exist_head>thresh
           if head(2)<br(2)
               if exist_centroid<thresh
                   interactions{j,2}=1;
               elseif centroid(2)>br(2)
                   interactions{j,2}=1;
               end
           end
       end
      if exist_centroid>thresh
           if centroid(2)<br(2)
               interactions{j,3}=1;
               dis2 = pdist([centroid;hole]);
               interactions{j,6}=dis2;
               sh_dist=[abs(centroid(1)-tl(1)) abs(centroid(1)-tr(1)) abs(centroid(2)-tr(2)) abs(centroid(2)-bl(2))];
               sh_dist=min(sh_dist);
               interactions{j,7}=sh_dist;
           end
      end
      
        if exist_tailbase>thresh
           if tailbase(2)<br(2)
               interactions{j,9}=1;              
           end
      end
      %time at entrance peek
       if exist_head>thresh
           if head(2)<br(2)
              if exist_centroid<thresh
                   interactions{j,8}=1;
               elseif centroid(2)>br(2)
                   interactions{j,8}=1;
               end 
           end
       end
       %time at entrance centroid
       if exist_centroid>thresh
           if centroid(2)<br(2)
               if centroid(2)>tl(2)+entrance_height;
                   if centroid(1)>(hole(1)-entrance_width)
                       if centroid(1)<(hole(1)+entrance_width)
               interactions{j,8}=1; 
                       end
                   end
               end
          end
      end
           
    
    
     %Mark the ROIs
    if hasFrame(oldv)
            frame = readFrame(oldv);
            
           if interactions{j,3}==1 
            y=round(tl(1));
            x=round(tl(2));
            frame((x-2):(x+2),(y-2):(y+2),1) = 56;
            frame((x-2):(x+2),(y-2):(y+2),2) = 61;
            frame((x-2):(x+2),(y-2):(y+2),3) = 250;
            y=round(tr(1));
            x=round(tr(2));
             frame((x-2):(x+2),(y-2):(y+2),1) = 56;
            frame((x-2):(x+2),(y-2):(y+2),2) = 61;
            frame((x-2):(x+2),(y-2):(y+2),3) = 250;
             y=round(bl(1));
            x=round(bl(2));
             frame((x-2):(x+2),(y-2):(y+2),1) = 56;
            frame((x-2):(x+2),(y-2):(y+2),2) = 61;
            frame((x-2):(x+2),(y-2):(y+2),3) = 250;
             y=round(br(1));
            x=round(br(2));
             frame((x-2):(x+2),(y-2):(y+2),1) = 56;
            frame((x-2):(x+2),(y-2):(y+2),2) = 61;
            frame((x-2):(x+2),(y-2):(y+2),3) = 250;
            
%             frame((top-1):(top+1),:,1) = 56;
%             frame((top-1):(top+1),:,2) = 161;
%             frame((top-1):(top+1),:,3) = 50;
%             
%             frame((bottom-1):(bottom+1),:,1) = 156;
%             frame((bottom-1):(bottom+1),:,2) = 61;
%             frame((bottom-1):(bottom+1),:,3) = 150;
            
            
            
                y=round(centroid(1));
                x=round(centroid(2));
                frame((x-1):(x+1),(y-1):(y+1),1) = 250;
                frame((x-1):(x+1),(y-1):(y+1),2) = 61;
                frame((x-1):(x+1),(y-1):(y+1),3) = 50;
           else
               y=round(tl(1));
            x=round(tl(2));
            frame(:,(y-2):(y+2),1) = 256;
            frame(:,(y-2):(y+2),2) = 61;
            frame(:,(y-2):(y+2),3) = 50;
            y=round(br(1));
            x=round(br(2));
             frame(:,(y-2):(y+2),1) = 256;
            frame(:,(y-2):(y+2),2) = 61;
            frame(:,(y-2):(y+2),3) = 50;
             y=round(tl(1));
            x=round(tl(2));
             frame((x-2):(x+2),:,1) = 256;
            frame((x-2):(x+2),:,2) = 61;
            frame((x-2):(x+2),:,3) = 50;
             y=round(br(1));
            x=round(br(2));
             frame((x-2):(x+2),:,1) = 256;
            frame((x-2):(x+2),:,2) = 61;
            frame((x-2):(x+2),:,3) = 50;
            
                   
           end
                       
           
           
                
    
    writeVideo(newv, frame);
    
    %end
    end
end
   

     close(newv)
    %convert interactions to double
    mat = zeros(length(mouse),9);
    for j = 1:length(mouse)
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
        
    end
    interactions = mat;
  
    
    %make points for the centroid plot
   count=1;  
   for k=1:length(mat)
       
       if mouse(k,5)<br(2) && mouse(k,6)>thresh
   xpos(count)=mouse(k,4);
   ypos(count)=mouse(k,5);
   count=count+1;
       end
   end
 
    
  %Make the plot 
 figure(i)
 plot(xpos,-ypos,'color','k')
 axis([tl(1)-10,tr(1)+10,-10-bl(2),-tl(2)+10]);
 title(strcat(currentfile,' mouse position'))
 xlabel('x')
 ylabel('y')
 figname=strcat('_mouse_position','.emf');
 hold off
 
 
end

            
            
      
            
            
            
       

            
           
            
           
            
            
            
            
            
            
            
            