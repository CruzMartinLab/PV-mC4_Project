%% Values to Set

%Enter the columns of the DLCcoordinates.csv for each marker w/ likelihood
tailbase=41:43;
snout=32:34 ;
head=35:37;
centroid=38:40;
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



%% 
%Get folders when behavior files are. Please select MI1 and MI2 separately
p_folder = uigetdir('Y:\Luke\Behavior\');

logs = dir(fullfile(p_folder,'**','DLCcoordinates.csv'));


%%
addpath(genpath('Z:\Lab Software and Code\ConnorStuff'));
addpath(genpath('Z:\Lab Software and Code\Rhush Stuff'));

logs = is_split(logs);
numFiles=length(logs);%% 

% after each run, this variable will contain the results. These are not
% saved and will need to be copied to an excel file
final_results=cell(numFiles+1,18);


final_results(1,1)={'Mouse Name'};
final_results(1,2)={'Trial 1 Object 1'};
final_results(1,3)={'Trial 1 Object 2'};
final_results(1,4)={'Trial 1 Distance'};
final_results(1,5)={'Trial 1 Velocity'};
final_results(1,6)={'Trial 2 Object 1'};
final_results(1,7)={'Trial 2 Object 2'};
final_results(1,8)={'Trial 2 Distance'};
final_results(1,9)={'Trial 2 Velocity'};
final_results(1,10)={'Trial 3 Object 1'};
final_results(1,11)={'Trial 3 Object 2'};
final_results(1,12)={'Trial 3 Distance'};
final_results(1,13)={'Trial 3 Velocity'};
final_results(1,14)={'Trial 4 Object 1'};
final_results(1,15)={'Trial 4 Object 2'};
final_results(1,16)={'Trial 4 Distance'};
final_results(1,17)={'Trial 4 Velocity'};
final_results(1,18)={'Genotype'};

row=1;
animals=numFiles/4;


for i=1:numFiles
    
    row=mod(i,animals);
    
    if row==0
        row=7;
    end
    
    s = regexp(logs(i).name, '\', 'split');
    file_delim = strsplit(logs(i).folder, '\');
    load(fullfile(logs(i).folder,'timestamp.mat'));
    load(fullfile(logs(i).folder,'startframe.mat'));
%     load(fullfile(logs(i).folder,'genotype.mat'));
    
    %read in the DLC file
    [NUM,~,~] = xlsread(fullfile(logs(i).folder,logs(i).name));
    [~,n]=size(file_delim);
    currentfile = file_delim(n);
    trial=char(file_delim(n-1));
    figpath=strcat(logs(i).folder,'\','_mouse_position.jpg');
    
  
    
    final_results(row+1,1) = currentfile;
    
    
    
    interactions= NORT(i,trial,startframe,currentfile,NUM(:,[topleft,topright,bottomleft,bottomright]),NUM(:,[bottle1_tr,bottle1_bl]),NUM(:,[bottle2_tr,bottle2_bl]), NUM(:,[nov_tr,nov_bl]), NUM(:,[snout, head, centroid]), VideoReader(fullfile(logs(i).folder,'behavCam1.avi')), VideoWriter(fullfile(logs(i).folder,'behavCam1_ROI.avi')), thresh);   

      
   %save current figure
   saveas(gcf,figpath);
   close(gcf);
    
   %calculate % times for various zones as well as total distance, average velocity 
   [m,~]=size(interactions);
 
  interactions=interactions(startframe:m,:);
  
  if strcmp(trial, 'Trial 3')
      interactions=interactions(1:9000,:);
  end
  
  [m,~]=size(interactions);
  
  summation=sum(interactions);
  
  for j=2:3
      summation(j)=100*summation(j)/m;
  end
  
  summation(5)=summation(5)/m;
  
  if strcmp(trial,'Trial 1')
      final_results(row+1,2)=num2cell(summation(2));
      final_results(row+1,3)=num2cell(summation(3));
      final_results(row+1,4)=num2cell(summation(4));
      final_results(row+1,5)=num2cell(summation(5));
  elseif strcmp(trial,'Trial 2')
      final_results(row+1,6)=num2cell(summation(2));
      final_results(row+1,7)=num2cell(summation(3));
      final_results(row+1,8)=num2cell(summation(4));
      final_results(row+1,9)=num2cell(summation(5));
  else strcmp(trial,'Trial 3')
      final_results(row+1,10)=num2cell(summation(2));
      final_results(row+1,11)=num2cell(summation(3));
      final_results(row+1,12)=num2cell(summation(4));
      final_results(row+1,13)=num2cell(summation(5));
  
  end
fprintf('%s %s complete \n',trial, char(currentfile));
  
end



function interactions = NORT(i,trial,s,currentfile,corners,obj1,obj2,nov,mouse, oldv, newv, thresh)
    [m,~]=size(mouse);
    interactions = cell(m+1,5);
    
    %new video for ROI
    open(newv);
    
    interactions{1,1}={'Frame'};
    interactions{1,2}={'Object 1'};
    interactions{1,3}={'Object 2'};
    interactions{1,4}={'Distance Travelled (m)'};
    interactions{1,5}={'Average Velocity (m/s)'};
    
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
    
    
    
    obj1=mean(obj1(2000:size(obj1),:));
    obj2=mean(obj2(2000:size(obj2),:));
    nov=mean(nov(2000:size(nov),:));
    
    t1=obj1(3);
    t2=obj2(3);
    
    obj1=[obj1(1) obj1(2) obj1(4) obj1(5)];
    obj2=[obj2(1) obj2(2) obj2(4) obj2(5)];
    nov=[nov(1) nov(2) nov(4) nov(5)];
    
    if strcmp(trial,'Trial 3')
        
        if t1>thresh
            ROI1=drawrectangle('Position',[round(obj1(2)-15),round(obj1(3)-21),round(obj1(4)-obj1(2))+60, round(obj1(1)-obj1(3))+60],'StripeColor','r' );
            ROI2=drawrectangle('Position',[round(nov(2)-25), round(nov(3)-20),round(nov(4)-nov(2))+57, round(nov(1)-nov(3))+45],'StripeColor','r' );
        
           
        
        else
            ROI1=drawrectangle('Position',[round(obj2(2)-24),round(obj2(3)-23),round(obj2(4)-obj2(2))+57, round(obj2(1)-obj2(3))+54],'StripeColor','r' );
            ROI2=drawrectangle('Position',[round(nov(2)-15), round(nov(3)-9),round(nov(4)-nov(2))+57, round(nov(1)-nov(3))+45],'StripeColor','r' );
        
          
        
        end
    else
        ROI1=drawrectangle('Position',[round(obj1(2)-15),round(obj1(3)-21),round(obj1(4)-obj1(2))+60, round(obj1(1)-obj1(3))+60],'StripeColor','r' );
        ROI2=drawrectangle('Position',[round(obj2(2)-24),round(obj2(3)-23),round(obj2(4)-obj2(2))+57, round(obj2(1)-obj2(3))+54],'StripeColor','r' );
    
          
    
    
    end
    
    
    
    
    %convert pixels to meters   
    width = pdist([tl;tr]);
    pix_per_m = width/0.45;

    %will become true when thresh is crossed for dlc points
    chance=false;
    
    for j=2:m
        
       interactions{j,1} = (j-1);
    
     snout=mouse(j-1,1:2);
     head=mouse(j-1,4:5);     
     centroid=mouse(j-1,7:8);
     if (j==2)
         prev=mouse(j-1,7:8);
     else prev=mouse(j-2,7:8);
     end

     
     if mouse(j-1,6)>=thresh
         chance=true;
     elseif mouse(j-1,9)>=thresh
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
         
         if inROI(ROI1,head(2),head(1))
             interactions{j,2}=true;
         end
         
         if inROI(ROI1,centroid(2),centroid(1))
            interactions{j,2}=true; 
         end
         
         if inROI(ROI2,head(2),head(1))
             interactions{j,3}=true;
         end  
         
         if inROI(ROI2,centroid(2),centroid(1))
            interactions{j,3}=true; 
         end
         
     end
     
      if hasFrame(oldv)
            frame = readFrame(oldv);
         
%             y=round(tl(1));
%             x=round(tl(2));
%             frame((x-3):(x+3),(y-3):(y+3),1) = 56;
%             frame((x-3):(x+3),(y-3):(y+3),2) = 61;
%             frame((x-3):(x+3),(y-3):(y+3),3) = 150;
%             y=round(tr(1));
%             x=round(tr(2));
%             frame((x-3):(x+3),(y-3):(y+3),1) = 56;
%             frame((x-3):(x+3),(y-3):(y+3),2) = 61;
%             frame((x-3):(x+3),(y-3):(y+3),3) = 150;
%              y=round(bl(1));
%             x=round(bl(2));
%             frame((x-3):(x+3),(y-3):(y+3),1) = 56;
%             frame((x-3):(x+3),(y-3):(y+3),2) = 61;
%             frame((x-3):(x+3),(y-3):(y+3),3) = 150;
%              y=round(br(1));
%             x=round(br(2));
%             frame((x-3):(x+3),(y-3):(y+3),1) = 56;
%             frame((x-3):(x+3),(y-3):(y+3),2) = 61;
%             frame((x-3):(x+3),(y-3):(y+3),3) = 150;
%             
%             
%             y=round(head(1));
%             x=round(head(2));
%             frame((x-1):(x+1),(y-1):(y+1),1) = 50;
%             frame((x-1):(x+1),(y-1):(y+1),2) = 61;
%             frame((x-1):(x+1),(y-1):(y+1),3) = 250;
%             
%             
%             y=round(centroid(1));
%             x=round(centroid(2));
%             frame((x-1):(x+1),(y-1):(y+1),1) = 50;
%             frame((x-1):(x+1),(y-1):(y+1),2) = 250;
%             frame((x-1):(x+1),(y-1):(y+1),3) = 50;
            
            
%             if strcmp(trial,'Trial 4')
%                if interactions{j,2}==1
%                    if t1>thresh
%                         corner=[round(obj1(2)-17) round(obj1(3)-20)];
%     
%                         width=round(obj1(1)-obj1(3))+42;
%                         height=round(obj1(4)-obj1(2))+42;
%                         
%                         if(corner(1)<1)
%                             corner(1)=2;
%                         end
%                         if(corner(2)<1)
%                             corner(2)=2;
%                         end
% 
%                         
%                    else
%                         corner=[round(obj2(2)-20) round(obj2(3)-18)];
%                         if(corner(1)<1)
%                             corner(1)=2;
%                         end
%                         if(corner(2)<1)
%                             corner(2)=2;
%                         end
%     
%                         width=round(obj2(1)-obj2(3))+36;
%                         height=round(obj2(4)-obj2(2))+39;
%                    end
% 
%                         frame(corner(1):(corner(1)+height),(corner(2)):(corner(2)+1),1) = 156;
%                         frame(corner(1):(corner(1)+height),(corner(2)):(corner(2)+1),2)  = 61;
%                         frame(corner(1):(corner(1)+height),(corner(2)):(corner(2)+1),3) = 150;
% 
% 
%                         frame(corner(1):(corner(1)+height),(corner(2)+width):(corner(2)+width+1),1) = 156;
%                         frame(corner(1):(corner(1)+height),(corner(2)+width):(corner(2)+width+1),2) = 61;
%                         frame(corner(1):(corner(1)+height),(corner(2)+width):(corner(2)+width+1),3) = 150;
% 
% 
%                         frame(corner(1):(corner(1)+1),(corner(2)):(corner(2)+width),1) = 156;
%                         frame(corner(1):(corner(1)+1),(corner(2)):(corner(2)+width),2)  = 61;
%                         frame(corner(1):(corner(1)+1),(corner(2)):(corner(2)+width),3) = 150;
% 
% 
%                         frame((corner(1)+height):(corner(1)+1+height),(corner(2)):(corner(2)+width),1) = 156;
%                         frame((corner(1)+height):(corner(1)+1+height),(corner(2)):(corner(2)+width),2)  = 61;
%                         frame((corner(1)+height):(corner(1)+1+height),(corner(2)):(corner(2)+width),3) = 150;
%                    
%                end
%                
%                if interactions{j,3}==1
%                    if t1>thresh
%                    corner=[round(nov(2)-20) round(nov(3)-15)];
%     
%                     width=round(nov(1)-nov(3))+27;
%                     height=round(nov(4)-nov(2))+39;
%                     
%                     if(corner(1)<1)
%                             corner(1)=2;
%                         end
%                         if(corner(2)<1)
%                             corner(2)=2;
%                         end
%                    else 
%                      corner=[round(nov(2)-10) round(nov(3)-4)];
%     
%                     width=round(nov(1)-nov(3))+27;
%                     height=round(nov(4)-nov(2))+39;
%                     
%                     if(corner(1)<1)
%                             corner(1)=2;
%                         end
%                         if(corner(2)<1)
%                             corner(2)=2;
%                         end
%                    end
%                        
%                     
%                     if(corner(1)<1)
%                             corner(1)=2;
%                         end
%                         if(corner(2)<1)
%                             corner(2)=2;
%                         end
%                     
%                     frame(corner(1):(corner(1)+height),(corner(2)):(corner(2)+1),1) = 156;
%                     frame(corner(1):(corner(1)+height),(corner(2)):(corner(2)+1),2)  = 61;
%                     frame(corner(1):(corner(1)+height),(corner(2)):(corner(2)+1),3) = 150;
% 
% 
%                     frame(corner(1):(corner(1)+height),(corner(2)+width):(corner(2)+width+1),1) = 156;
%                     frame(corner(1):(corner(1)+height),(corner(2)+width):(corner(2)+width+1),2) = 61;
%                     frame(corner(1):(corner(1)+height),(corner(2)+width):(corner(2)+width+1),3) = 150;
% 
% 
%                     frame(corner(1):(corner(1)+1),(corner(2)):(corner(2)+width),1) = 156;
%                     frame(corner(1):(corner(1)+1),(corner(2)):(corner(2)+width),2)  = 61;
%                     frame(corner(1):(corner(1)+1),(corner(2)):(corner(2)+width),3) = 150;
% 
% 
%                     frame((corner(1)+height):(corner(1)+1+height),(corner(2)):(corner(2)+width),1) = 156;
%                     frame((corner(1)+height):(corner(1)+1+height),(corner(2)):(corner(2)+width),2)  = 61;
%                     frame((corner(1)+height):(corner(1)+1+height),(corner(2)):(corner(2)+width),3) = 150;
%                     
%                end
%                
%             else
%                  if interactions{j,2}==1
%                     
%                     corner=[round(obj1(2)-21) round(obj1(3)-25)];
%     
%                     width=round(obj1(1)-obj1(3))+60;
%                     height=round(obj1(4)-obj1(2))+60;
%                     
%                     if(corner(1)<1)
%                             corner(1)=2;
%                         end
%                         if(corner(2)<1)
%                             corner(2)=2;
%                         end
%                     
%                     frame(corner(1):(corner(1)+height),(corner(2)):(corner(2)+1),1) = 156;
%                         frame(corner(1):(corner(1)+height),(corner(2)):(corner(2)+1),2)  = 61;
%                         frame(corner(1):(corner(1)+height),(corner(2)):(corner(2)+1),3) = 150;
% 
% 
%                         frame(corner(1):(corner(1)+height),(corner(2)+width):(corner(2)+width+1),1) = 156;
%                         frame(corner(1):(corner(1)+height),(corner(2)+width):(corner(2)+width+1),2) = 61;
%                         frame(corner(1):(corner(1)+height),(corner(2)+width):(corner(2)+width+1),3) = 150;
% 
% 
%                         frame(corner(1):(corner(1)+1),(corner(2)):(corner(2)+width),1) = 156;
%                         frame(corner(1):(corner(1)+1),(corner(2)):(corner(2)+width),2)  = 61;
%                         frame(corner(1):(corner(1)+1),(corner(2)):(corner(2)+width),3) = 150;
% 
% 
%                         frame((corner(1)+height):(corner(1)+1+height),(corner(2)):(corner(2)+width),1) = 156;
%                         frame((corner(1)+height):(corner(1)+1+height),(corner(2)):(corner(2)+width),2)  = 61;
%                         frame((corner(1)+height):(corner(1)+1+height),(corner(2)):(corner(2)+width),3) = 150;
%                         
%                  
%                 end 
%                  if interactions{j,3}==1
%                      corner=[round(obj2(2)-24) round(obj2(3)-23)];
%                           
%                         width=round(obj2(1)-obj2(3))+54;
%                         height=round(obj2(4)-obj2(2))+57;
%                         
%                         if(corner(1)<1)
%                             corner(1)=2;
%                         end
%                         if(corner(2)<1)
%                             corner(2)=2;
%                         end
%                         
%                         frame(corner(1):(corner(1)+height),(corner(2)):(corner(2)+1),1) = 156;
%                         frame(corner(1):(corner(1)+height),(corner(2)):(corner(2)+1),2)  = 61;
%                         frame(corner(1):(corner(1)+height),(corner(2)):(corner(2)+1),3) = 150;
% 
% 
%                         frame(corner(1):(corner(1)+height),(corner(2)+width):(corner(2)+width+1),1) = 156;
%                         frame(corner(1):(corner(1)+height),(corner(2)+width):(corner(2)+width+1),2) = 61;
%                         frame(corner(1):(corner(1)+height),(corner(2)+width):(corner(2)+width+1),3) = 150;
% 
% 
%                         frame(corner(1):(corner(1)+1),(corner(2)):(corner(2)+width),1) = 156;
%                         frame(corner(1):(corner(1)+1),(corner(2)):(corner(2)+width),2)  = 61;
%                         frame(corner(1):(corner(1)+1),(corner(2)):(corner(2)+width),3) = 150;
% 
% 
%                         frame((corner(1)+height):(corner(1)+1+height),(corner(2)):(corner(2)+width),1) = 156;
%                         frame((corner(1)+height):(corner(1)+1+height),(corner(2)):(corner(2)+width),2)  = 61;
%                         frame((corner(1)+height):(corner(1)+1+height),(corner(2)):(corner(2)+width),3) = 150;
%                         
%                  end
%                  
%                  
%             
%             end
            
            writeVideo(newv, frame);
      end
        
        
        
        
    end
    close(newv);
    
    
        mat = zeros(length(mouse),5);
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
        
    end
    interactions = mat;
    
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
%%