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


final_results=cell(numFiles+1,9);
final_results(1,1)={'Mouse Name'};
final_results(1,2)={'Periphery'};
final_results(1,3)={'Center'};
final_results(1,6)={'Rears'};
final_results(1,4)={'Distance Travelled (m)'};
final_results(1,5)={'Instantaneous Velocity (m/s)'};
final_results(1,7)={'Genotype'};
final_results(1,8)={'Periphery Normalised'};
final_results(1,9)={'Center Normalised'};


for i=1:numFiles
    
    s = regexp(logs(i).name, '\', 'split');
    file_delim = strsplit(logs(i).folder, '\');
    load(fullfile(logs(i).folder,'timestamp.mat'));
    load(fullfile(logs(i).folder,'startframe.mat'));
    load(fullfile(logs(i).folder,'genotype.mat'));
    %read in the DLC file
    [NUM,~,~] = xlsread(fullfile(logs(i).folder,logs(i).name));
    [~,m]=size(file_delim);
    currentfile = file_delim(m);
    %Name for graph to be saved
    figpath=strcat(logs(i).folder,'\','_mouse_position.jpg');
    
    
    final_results(i+1,1) = currentfile;
        
    interactions= OF(i,currentfile,NUM(:,[topleft,topright,bottomleft,bottomright]),NUM(:,[head, centroid,tailbase]),NUM(:,[head,neck, bodypt1,centroid,bodypt2,tailbase]),startframe, VideoReader(fullfile(logs(i).folder,'behavCam1.avi')), VideoWriter(fullfile(logs(i).folder,'behavCam666_ROI.avi')), thresh); 
    saveas(gcf,figpath);
   close(gcf)
   %calculate % times for various zones as well as total distance, average velocity 
  [m,~]=size(interactions);
 
 
   interactions=interactions(startframe:m,:);
  
  [m,~]=size(interactions);
  
   save(fullfile(fullfile(logs(i).folder,'mouse_explore.mat')),'interactions');
   
   summation=sum(interactions);
    
   
    for j=2:3
        summation(j)=100*summation(j)/m;
    end
    
    summation(5)=summation(5)/m;
    
    for k=2:5
       final_results(i+1,k)=num2cell(summation(k)); 
    end
     final_results(i+1,6)=num2cell(summation(7));
    
    final_results(i+1,7)=cellstr(genotype);
    
    peri=summation(2)*100/64;
     cen=summation(3)*100/36;
     
     summation(2)=peri*100/(peri+cen);
     summation(3)=cen*100/(peri+cen);
     
     final_results(i+1,8)=num2cell(summation(2));
     final_results(i+1,9)=num2cell(summation(3 ));
    
   fprintf('%d files remaining\n',numFiles-i);
    
    clear NUM;
    
end




function interactions = OF(i,currentfile,corners,mouse,body,s, oldv, newv, thresh)
    [m,~]=size(mouse);
    interactions = cell(m+1,7);
    
    %new video for ROI
    open(newv);
    
    interactions{1,1}={'Frame'};
    interactions{1,2}={'Periphery'};
    interactions{1,3}={'Center'};
    interactions{1,7}={'Rears'};
    interactions{1,4}={'Distance Travelled (m)'};
    interactions{1,5}={'Average Velocity (m/s)'};
    interactions{1,6}={'Location'};
    
    
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
    
    if (br(1)<tr(1))
        br(1)=tr(1);
    else tr(1)=br(1);
    end
    
    
    t1=tl(1)+((tr(1)-tl(1))/5);
    t2=tl(1)+4*((tr(1)-tl(1))/5);
    l1=tl(2)+((bl(2)-tl(2))/5);
    l2=tl(2)+4*((bl(2)-tl(2))/5);
    
      
    %convert pixels to meters   
    width = pdist([tl;tr]);
    pix_per_m = width/0.457;

    %will become true when thresh is crossed for dlc points
    chance=false;
    

for j=2:m
    
     interactions{j,1} = (j-1);
    
     tailbase=mouse(j-1,7:8);
     head=mouse(j-1,1:2);     
     centroid=mouse(j-1,4:5);
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
        
        if centroid(1)<t1
            interactions{j,2}=true;
            if centroid(2)<l1
                interactions{j,6}=1;
            elseif centroid(2)>l2
                interactions{j,6}=3;
            else interactions{j,6}=5;
            end
        elseif centroid(1)>t2
            interactions{j,2}=true;
            if centroid(2)<l1
                interactions{j,6}=2;
            elseif centroid(2)>l2
                interactions{j,6}=4;
            else interactions{j,6}=6;
            end
        elseif centroid(2)<l1
            interactions{j,2}=true;
            if centroid(1)>t1 && centroid(1)<t2
                interactions{j,6}=7;
            end
        elseif centroid(2)>l2
            interactions{j,2}=true;
            if centroid(1)>t1 && centroid(1)<t2
                interactions{j,6}=8;
            end
        else interactions{j,3}=true;
            interactions{j,6}=0;
        end
           
     end
end

flag=true;
rear_frame=2;
for j=1:m
    body(j,19)=j;
end

bodylen=length(body);

 k=1;
         while (k<bodylen)
           if body(k,3)<thresh | body(k,6)<thresh | body(k,9)<thresh | body(k,12)<thresh | body(k,15)<thresh | body(k,18)<thresh
               body(k,:)=[];
               k=k-1;
           end
           k=k+1;
           bodylen=length(body);
         end

for j=2:bodylen-rear_frame
    
   distance = zeros(rear_frame,2);
    
   f1=j;
   f2=j+rear_frame;
    
   for k=f1:f2
   
%     neck=[body(k,1) body(k,2)]; 
%     bp1=[body(k,4) body(k,5)];
%     cen=[body(k,7) body(k,8)];
%     bp2=[body(k,10) body(k,11)];
%     tb=[body(k,13) body(k,14)];

    head=[body(k,1) body(k,2)]; 
    neck=[body(k,4) body(k,5)];
    bp1=[body(k,7) body(k,8)];
    cen=[body(k,10) body(k,11)];
    bp2=[body(k,13) body(k,14)];
    tb=[body(k,16) body(k,17)];
    cenprev=[body(k-1,10) body(k-1,11)];

    d1= pdist([neck;bp1]);
    d2= pdist([bp1;cen]);
    d3= pdist([bp2;cen]);
    d4= pdist([bp2;tb]);
    d5=pdist([head;neck]);
    
    distance(k-f1+1,1)=(d1+d2+d3+d4+d5);
    distance(k-f1+1,2)=d3;
     
   end 
   
   cen=[body(j,10) body(j,11)];
   cenprev=[body(j-1,10) body(j-1,11)];
   trav_dist=pdist([cen;cenprev]);
   
   A=all(distance(1:rear_frame,1)<21.5);
   D=all(distance(1:rear_frame,2)>3);
   C=all(distance(1:rear_frame,2)<4);
   
   if (A==1) & (C==1) & (D==1) & trav_dist>0.5
       if flag==true
%            if j>1001
%                if j<2000
%                    body(f1,19)
%                end
%            end
           index=body(f1,19);
           interactions{index,7}=true;
           flag=false;
       end
   end
   
   B=all(distance(1:rear_frame,1)>25);
   if (B==1)
       
           
           flag=true;
       
   end
    
end


for j=2:m
    
     %Mark the ROIs
    if hasFrame(oldv)
            frame = readFrame(oldv);
            
            
            y=round(tl(1));
            x=round(tl(2));
            frame((x-1):(x+1),(y-1):(y+1),1) = 56;
            frame((x-1):(x+1),(y-1):(y+1),2) = 61;
            frame((x-1):(x+1),(y-1):(y+1),3) = 150;
            y=round(tr(1));
            x=round(tr(2));
            frame((x-1):(x+1),(y-1):(y+1),1) = 56;
            frame((x-1):(x+1),(y-1):(y+1),2) = 61;
            frame((x-1):(x+1),(y-1):(y+1),3) = 150;
             y=round(bl(1));
            x=round(bl(2));
            frame((x-1):(x+1),(y-1):(y+1),1) = 56;
            frame((x-1):(x+1),(y-1):(y+1),2) = 61;
            frame((x-1):(x+1),(y-1):(y+1),3) = 150;
             y=round(br(1));
            x=round(br(2));
            frame((x-1):(x+1),(y-1):(y+1),1) = 56;
            frame((x-1):(x+1),(y-1):(y+1),2) = 61;
            frame((x-1):(x+1),(y-1):(y+1),3) = 150;
            
            y=round(mouse(j-1,4));
            x=round(mouse(j-1,5));
            
            if mouse(j-1,6)>thresh
            frame((x-1):(x+1),(y-1):(y+1),1) = 0;
            frame((x-1):(x+1),(y-1):(y+1),2) = 250;
            frame((x-1):(x+1),(y-1):(y+1),3) = 0;
            end
            
%             y=round(mouse(j-1,4));
%             x=round(mouse(j-1,5));
%             
            y=100;
            x=100;
            if mouse(j-1,6)>thresh
                if interactions{j-1,7}==true
            frame((x-15):(x+15),(y-15):(y+15),1) = 250;
            frame((x-15):(x+15),(y-15):(y+15),2) = 0;
            frame((x-15):(x+15),(y-15):(y+15),3) = 250;
                end
               
             end
            
            
            
%             frame((top-1):(top+1),:,1) = 56;
%             frame((top-1):(top+1),:,2) = 161;
%             frame((top-1):(top+1),:,3) = 50;
%             
%             frame((bottom-1):(bottom+1),:,1) = 156;
%             frame((bottom-1):(bottom+1),:,2) = 61;
%             frame((bottom-1):(bottom+1),:,3) = 150;
            
            


                       
           
           
                
    
    writeVideo(newv, frame);
    
    %end
    end
end
   

     close(newv)
    %convert interactions to double
    mat = zeros(length(mouse),7);
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
    end
    interactions = mat;
  
    
    %make points for the centroid plot
     
   
   xpos=mouse(s:length(mat),4);
   ypos=mouse(s:length(mat),5);
   
 
    
  %Make the plot 
 figure(i)
 plot(xpos,-ypos,'color','k')
 axis([tl(1)-10,tr(1)+10,-10-bl(2),-tl(2)+10]);
 title(strcat(currentfile,' mouse position'))
 xlabel('x')
 ylabel('y')
 figname=strcat('_mouse_position','.jpg');
 hold off
 
 
end

            
            
      
            
            
            
       

            
           
            
           
            
            
            
            
            
            
            
            