% Values to Set

%Enter the columns of the DLCcoordinates.csv for each marker w/ likelihood
snout =14:16;  
head =17:19;
centroid=20:22;
topleft=2:3;
topright=5:6;
bottomleft=8:9;
bottomright=11:12;
object=23:34;


%Set threshold DLC confidence for choice between snout and head tracking
thresh = 0.90;
%% 
%Get folders when behavior files are. 
p_folder = uigetdir('Y:\Luke\Behavior\');

logs = dir(fullfile(p_folder,'**','DLCcoordinates.csv'));
%%
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
addpath(genpath('Y:\Lab Software and Code\Rhush Stuff'));

%logs = is_split(logs);
numFiles=length(logs);%% 

final_results=cell(numFiles+1,9);
final_results(1,1)={'Mouse Name'};
final_results(1,2)={'Interaction Time'};
final_results(1,5)={'Number of Interactions'};
final_results(1,3)={'Total distance travelled (m)'};
final_results(1,4)={'Average Velocity (m/s)'};
%final_results(1,6)={'Genotype'};

for i=1:numFiles
    
    s = regexp(logs(i).name, '\', 'split');
    file_delim = strsplit(logs(i).folder, '\');
    [~,m]=size(file_delim);
    %load(fullfile(logs(i).folder,'timestamp.mat'));
    load(fullfile(logs(i).folder,'startframe.mat'));
    %load(fullfile(logs(i).folder,'genotype.mat'));
    
    %read in the DLC file
    [NUM,~,~] = xlsread(fullfile(logs(i).folder,logs(i).name));
    currentfile = file_delim(m);
    %Name for trajectory to be saved
    figpath=strcat(logs(i).folder,'\','_mouse_position.jpg');
    
    %Write the mouse number to file
    final_results(i+1,1) = currentfile;
    
        
    interactions= NORT(i,currentfile,NUM(:,[topleft,topright,bottomleft,bottomright]),NUM(:,[object]) ,NUM(:,[snout, head, centroid]),startframe, VideoReader(fullfile(logs(i).folder,'behavCam5.avi')), VideoWriter(fullfile(logs(i).folder,'behavCam5_ROI.avi')), thresh);       
     
   %save current figure and then close
   saveas(gcf,figpath);
   close(gcf);
    
   %calculate % times for various zones as well as total distance, average velocity 
 [m,~]=size(interactions);
 
 %m=startframe+9000;
 
   interactions=interactions(startframe:m,:);
   
   save(fullfile(fullfile(logs(i).folder,'mouse_explore.mat')),'interactions');
  
  [m,~]=size(interactions);
   
   summation=sum(interactions);
    
   count=0;
   
   
   for p=4:m-2
       A=all(interactions(p-3:p-1,2)==0);
       B=all(interactions(p:p+2,2)==1);
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
    
   %final_results(i+1,6)=cellstr(genotype); 
    
    clear NUM;
    
end


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
    
    %set objects
   
        obj=obj(5000:8000,:);
        obj=mean(obj);

        objtl=[obj(1) obj(2)];
        objtr=[obj(4) obj(5)];
        objbl=[obj(7) obj(8)];
        objbr=[obj(10) obj(11)];

        width=round(objtr(1)-objtl(1));
        height=round(objbl(2)-objtl(2));
   
    ROIi=drawrectangle('Position',[objtl(2)+1,objtl(1)+1,height+1,width+4],'StripeColor','r' );
    ROIo=drawrectangle('Position',[objtl(2)-13,objtl(1)-13,height+29,width+32],'StripeColor','b' );
    
    
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

     
     if mouse(j-1,3)>=thresh
         chance=true;
     elseif mouse(j-1,6)>=thresh
         chance=true;
     else chance=false;
     end
     
                 
     if(chance)
        
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
           
        if mouse(j-1,3)>=thresh
         snout=mouse(j-1,1:2);
        else snout=mouse(j-1,4:5);
        end
        
        
        %calculate interaction of mouse with object
            if inROI(ROIo,snout(2),snout(1)) 
                if ~inROI(ROIi,centroid(2), centroid(1))
                interactions{j,2}=true;
                end
%             elseif inROI(ROI1,centroid(2), centroid(1))
%                  interactions{j,2}=true;
            end
          
                     
     end
    
     %Mark the ROIs
    if hasFrame(oldv)
            frame = readFrame(oldv);
            
       
            
            
%Mark inner and outer rectangles            


          corner=[round(objtl(2)+1) round(objtl(1)+1)];
    
    width=round(objtr(1)-objtl(1))+4;
    height=round(objbl(2)-objtl(2));

    frame(corner(1):(corner(1)+height),(corner(2)):(corner(2)+1),1) = 156;
    frame(corner(1):(corner(1)+height),(corner(2)):(corner(2)+1),2)  = 61;
    frame(corner(1):(corner(1)+height),(corner(2)):(corner(2)+1),3) = 50;
    
             
    frame(corner(1):(corner(1)+height),(corner(2)+width):(corner(2)+width+1),1) = 156;
    frame(corner(1):(corner(1)+height),(corner(2)+width):(corner(2)+width+1),2) = 61;
    frame(corner(1):(corner(1)+height),(corner(2)+width):(corner(2)+width+1),3) = 50;
    
             
    frame(corner(1):(corner(1)+1),(corner(2)):(corner(2)+width),1) = 156;
    frame(corner(1):(corner(1)+1),(corner(2)):(corner(2)+width),2)  = 61;
    frame(corner(1):(corner(1)+1),(corner(2)):(corner(2)+width),3) = 50;
    
             
    frame((corner(1)+height):(corner(1)+1+height),(corner(2)):(corner(2)+width),1) = 156;
    frame((corner(1)+height):(corner(1)+1+height),(corner(2)):(corner(2)+width),2)  = 61;
    frame((corner(1)+height):(corner(1)+1+height),(corner(2)):(corner(2)+width),3) = 50;
    
    
    
    corner=[round(objtl(2)-13) round(objtl(1)-13)];
    width=width+28;
    height=height+28;
    
    
     frame(corner(1):(corner(1)+height),(corner(2)):(corner(2)+1),1) = 56;
    frame(corner(1):(corner(1)+height),(corner(2)):(corner(2)+1),2)  = 61;
    frame(corner(1):(corner(1)+height),(corner(2)):(corner(2)+1),3) =150;
    
             
    frame(corner(1):(corner(1)+height),(corner(2)+width):(corner(2)+width+1),1) = 56;
    frame(corner(1):(corner(1)+height),(corner(2)+width):(corner(2)+width+1),2) = 61;
    frame(corner(1):(corner(1)+height),(corner(2)+width):(corner(2)+width+1),3) = 150;
    
             
    frame(corner(1):(corner(1)+1),(corner(2)):(corner(2)+width),1) = 56;
    frame(corner(1):(corner(1)+1),(corner(2)):(corner(2)+width),2)  = 61;
    frame(corner(1):(corner(1)+1),(corner(2)):(corner(2)+width),3) = 150;
    
             
    frame((corner(1)+height):(corner(1)+1+height),(corner(2)):(corner(2)+width),1) = 56;
    frame((corner(1)+height):(corner(1)+1+height),(corner(2)):(corner(2)+width),2)  = 61;
    frame((corner(1)+height):(corner(1)+1+height),(corner(2)):(corner(2)+width),3) = 150;
           
    
    
    
    Vertices1 = round(ROIi.Vertices);
            for e = 1:length(Vertices1)
                    frame(Vertices1(e,1),Vertices1(e,2),1) = 0;
                    frame(Vertices1(e,1),Vertices1(e,2),2) = 0;
                    frame(Vertices1(e,1),Vertices1(e,2),3) = 255;
            end
            
            
            
    Vertices1 = round(ROIo.Vertices);
            for e = 1:length(Vertices1)
                    frame(Vertices1(e,1),Vertices1(e,2),1) = 255;
                    frame(Vertices1(e,1),Vertices1(e,2),2) = 0;
                    frame(Vertices1(e,1),Vertices1(e,2),3) = 0;
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