% Values to Set
clear
%Enter the columns of the DLCcoordinates.csv for each marker w/ likelihood
snout=26:28;
head=32:34;
centroid=53:55;
topleft=2:3;
topright=5:6;
bottomleft=8:9;
bottomright=11:12;
object=14:25;



%Set threshold DLC confidence for choice between snout and head tracking
thresh = 0.90;
%% 
%Get folders when behavior files are. 
p_folder = uigetdir('Z:\Luke\Behavior\');

logs = dir(fullfile(p_folder,'**','DLCcoordinates.csv'));
%%
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
addpath(genpath('Y:\Lab Software and Code\Rhush Stuff'));

%logs = is_split(logs);
numFiles=length(logs);%% 

final_results=cell(numFiles+1,7);
final_results(1,1)={'Mouse Name'};
final_results(1,2)={'Interaction Time'};
final_results(1,5)={'Number of Interactions'};
final_results(1,3)={'Total distance travelled (m)'};
final_results(1,4)={'Average Velocity (m/s)'};
final_results(1,6)={'Genotype'};
final_results(1,7)={'Sex'};
f = waitbar(0, 'Starting');
for i=1:numFiles
    waitbar(i/numFiles, f, sprintf('Look at them interact: %d %%', floor(100*i/numFiles)));
    s = regexp(logs(i).name, '\', 'split');
    file_delim = strsplit(logs(i).folder, '\');
    [~,m]=size(file_delim);
    %load(fullfile(logs(i).folder,'timestamp.mat'));
    load(fullfile(logs(i).folder,'startframe.mat'));
    load(fullfile(logs(i).folder,'genotype.mat'));
    load(fullfile(logs(i).folder,'mouse_sex.mat'));
    
    %read in the DLC file
    [NUM,~,~] = xlsread(fullfile(logs(i).folder,logs(i).name));
    currentfile = file_delim(m);
    %Name for trajectory to be saved
    figpath=strcat(logs(i).folder,'\','_mouse_position.jpg');
    
    %Write the mouse number to file
    final_results(i+1,1) = currentfile;
    
        
    interactions= NORT(i,currentfile,NUM(:,[topleft,topright,bottomleft,bottomright]),NUM(:,[object]) ,NUM(:,[snout, head, centroid]),startframe, VideoReader(fullfile(logs(i).folder,'behavcam_5.avi')), VideoWriter(fullfile(logs(i).folder,'behavCam5_ROI.avi')), thresh);       
     
   %save current figure and then close
   saveas(gcf,figpath);
   close(gcf);
    
   %calculate % times for various zones as well as total distance, average velocity 
  [m,~]=size(interactions);
  %m=startframe+9000;   
   save(fullfile(fullfile(logs(i).folder,'mouse_explore.mat')),'interactions');
   interactions=interactions(startframe:m,:);
  [m,~]=size(interactions);
   
   summation=sum(interactions);
    
   count=0;
   
   
   for p=9:m-7
       A=all(interactions(p-8:p-1,2)==0);
       B=all(interactions(p:p+7,2)==1);
       if(A==1)
           if(B==1)
               
               count=count+1;
              
           end
       end      
   end
        
    summation(2)=100*summation(2)/m;
   
    
    summation(4)=summation(4)/m;
    
    summation(5)=count;
   
    
    
    for j=2:5
        final_results(i+1,j)=num2cell(summation(j));
    end
    
    final_results(i+1,6)=cellstr(genotype); 
    
    final_results(i+1,7)=cellstr(sex);
  
    fprintf('%s complete \n',char(currentfile));
    

    
end
close(f)

function interactions = NORT(i,currentfile,corners,obj, mouse,s, oldv, newv, thresh)
    [m,~]=size(mouse);
    interactions = cell(m+1,4);
    
    %new video for ROI
    open(newv);
    
    interactions{1,1}={'Frame'};
    interactions{1,2}={'Interact'};
    interactions{1,3}={'Distance Travelled (m)'};
    interactions{1,4}={'Average Velocity (m/s)'};
    
    
    %set boundaries of the field and account for small deviations
    corners=mean(corners(s:end,:));
    
    tl=[corners(1) corners(2)];
    tr=[corners(3) corners(4)];
    bl=[corners(5) corners(6)];
    br=[corners(7) corners(8)];

    %set objects
   
    obj=mean(obj(s:s+10,:));
    obj1=[obj(4) obj(5) obj(7) obj(8)];
    center1=[((obj1(1)+obj1(3))/2) ((obj1(2)+obj1(4))/2)]; 
    obj2=[obj(1) obj(2) obj(10) obj(11)];
   
    mouse_head_size=(obj1(4)-obj1(2))/3;
    mouse_head_size=floor(mouse_head_size);
    intzone=[obj1(1)+mouse_head_size  obj1(2)-(mouse_head_size);obj1(3)-(2.5*mouse_head_size)  obj1(4)+2.5*mouse_head_size];
    
    %convert pixels to meters   
    width = pdist([tl;tr]);
    pix_per_m = width/0.45;

    %will become true when thresh is crossed for dlc points
 
    [mouse_new]=mouse_correction(mouse,s,200);
    mouse=mouse_new; 

for j=2:m
    
     interactions{j,1} = (j-1);
    
     snout=mouse(j-1,1:3);
     head=mouse(j-1,4:6);     
     centroid=mouse(j-1,7:9);
     if (j==2)
         prev=mouse(j-1,7:9);
     else prev=mouse(j-2,7:9);
     end

     
     if mouse(j-1,3)>=thresh
         chance=true;
     elseif mouse(j-1,6)>=thresh
         chance=true;
     else chance=false;
     end
     
         %if (chance)        
     
        
            interactions{j,2} = false;
                       
            
            dis=0;
            
            if (j == 2)
            interactions{j,4}=0;
            else
                %distance and velocity per frame
                dis = pdist([centroid;prev]);
            dis = dis/pix_per_m;
            interactions{j,4} = dis*30;%because 30 fps to convert to m/s
         end 
        interactions{j,3}=dis;
           
        
        int=0;
        
        
        if snout(1,3)>=thresh
            [int]=mouse_in_roi(snout,intzone);
                    
        elseif head(1,3)>=thresh
            [int]=mouse_in_roi(head,intzone);
        end
        if int==1
            interactions{j,2}=true;
        end
        
        if snout(1,3)<thresh && head(1,3)<thresh
            interactions{j,2}=true;
        end
        
       if centroid(1,3)>thresh && head(1,3)>thresh
           theta=find_mouse_angle(center1,head(1:2),centroid(1:2)); 
       else
            theta=100;
       end

      if theta>75
          interactions{j,2}=false;
          interactions{j,3}=false;
      end
          
            
            
    %end
    
    
     %Mark the ROIs
    if hasFrame(oldv)
            frame = readFrame(oldv);
         
           
            frame_cor=[tl(1) tl(2); tr(1) tr(2); bl(1) bl(2);br(1) br(2)];
            frame_obj=[obj1(1) obj1(2); obj1(3) obj1(4);obj2(1) obj2(2); obj2(3) obj2(4)];

            for j=1:4
                frame=mark_frame([round(frame_cor(j,1)),round(frame_cor(j,2))],frame,3,[0 0 250]);
                frame=mark_frame([round(frame_obj(j,1)),round(frame_obj(j,2))],frame,3,[250 0 0]);
            end
            
            frame_int=[intzone(1,1) intzone(1,2); intzone(2,1) intzone(2,2)];
            
            for j=1:2
                frame=mark_frame([frame_int(j,1) frame_int(j,2)],frame,3,[50 50 200]);
            end
            
            
            
            if snout(3)>thresh
               frame=mark_frame([snout(1) snout(2)],frame,1,[250,60,50]);
            end

            if head(3)>thresh 
                frame=mark_frame([head(1) head(2)],frame,1,[50,60,250]);
            end

            if centroid(3)>thresh 
                frame=mark_frame([centroid(1) centroid(2)],frame,1,[60,250,50]);
            end
            
            if interactions{j,2}==true             
               frame=mark_frame([((obj1(1)+obj1(3))/2) ((obj1(2)+obj1(4))/2)],frame,10,[250 250 0]);    
            end

            
             
    
    writeVideo(newv, frame);
    
    %end
    end
end
    close(newv)
    
    %convert interactions to double
    mat = zeros(length(mouse),4);
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
        
    end
    interactions = mat;
  
    
    %make points for the centroid plot
     
   
   xpos=mouse(s:length(mat),7);
   ypos=mouse(s:length(mat),8);
   
 
    
  %Make the plot 
 figure(i)
 plot(xpos,-ypos,'color','k')
 axis([tl(1)-10,tr(1)+10,-10-bl(2),-tl(2)+10]);
%for colored graph whenever animal is in empty cup or mom cup zone,
%uncomment these 3 lines
 %  hold on
%  plot(xpos2,-ypos2,'color','b')
%  axis([tl(1)-10,tr(1)+10,-10-bl(2),-tl(2)+10]);
 title(strcat(currentfile,' mouse position'))
 xlabel('x')
 ylabel('y')
 figname=strcat('_mouse_position','.jpg');
 hold off
 
 
end