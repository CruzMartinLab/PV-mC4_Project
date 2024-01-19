clear
%Enter the columns of the DLCcoordinates.csv for each marker w/ likelihood
snout=32:34 ;
head=38:40;
centroid=53:55;
topleft=2:3;
topright=5:6;
bottomleft=8:9;
bottomright=11:12;
lego_l_tr=14:15;
lego_l_bl=17:18;
lego_r_tr=20:21;
lego_r_bl=23:24;
conical_l=26:27;
conical_r=29:30;

thresh=0.90;

%%

%Get folders when behavior files are. Please select MI1 and MI2 separately
p_folder = uigetdir('Z:\Luke\Behavior\');

logs = dir(fullfile(p_folder,'**','DLCcoordinates.csv'));
%%

addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
addpath(genpath('Y:\Lab Software and Code\Rhush Stuff'));

%logs = is_split(logs);
numFiles=length(logs);%% 

% after each run, this variable will contain the results. These are not
% saved and will need to be copied to an excel file
final_results=cell((numFiles/2)+1,11);


final_results(1,1)={'Mouse Name'};
final_results(1,2)={'Familiarisation Object 1'};
final_results(1,3)={'Familiarisation Object 2'};
final_results(1,4)={'Familiarisation Distance'};
final_results(1,5)={'Familiarisation Velocity'};
final_results(1,6)={'Test Object 1'};
final_results(1,7)={'Test Object 2'};
final_results(1,8)={'Test Distance'};
final_results(1,9)={'Test Velocity'};
final_results(1,10)={'Genotype'};
final_results(1,11)={'Mouse Sex'};

row=1;
animals=numFiles/2;

f = waitbar(0, 'Starting');
for i=1:numFiles
    
    row=mod(i,animals);
    
    if row==0
        row=animals;
    end
    
    s = regexp(logs(i).name, '\', 'split');
    file_delim = strsplit(logs(i).folder, '\');
    n=length(file_delim);
    currentfile = file_delim(n);
    if string(file_delim(n-1))=='Familiarization'
        trial=1;
    else
        trial=2;
    end
%     load(fullfile(logs(i).folder,'TimeStamp.mat'));
     load(fullfile(logs(i).folder,'startframe.mat'));
     load(fullfile(logs(i).folder,'genotype.mat'));
     load(fullfile(logs(i).folder,'mouse_sex.mat'));
     load(fullfile(logs(i).folder,'obj_type.mat'));
     [NUM,~,~] = xlsread(fullfile(logs(i).folder,logs(i).name));
     final_results(row+1,1) = currentfile;
     figpath=strcat(logs(i).folder,'\','_mouse_position.jpg');
     

%Familiar is ALWAYS obj1
% obj type 11 means familiar object type is 1 i.e. a conical, and its on
% the left side
     
     if trial==1
        if obj_type==11 || obj_type==12
            obj1=NUM(:,[conical_l]);
            obj2=NUM(:,[conical_r]);
         elseif obj_type==21 || obj_type==22
            obj1=NUM(:,[lego_l_tr,lego_l_bl]);
            obj2=NUM(:,[lego_r_tr,lego_r_bl]);
        end
    else
        if obj_type==11
            obj1=NUM(:,[conical_l]);
            obj2=NUM(:,[lego_r_tr,lego_r_bl]);
        elseif obj_type==12
            obj1=NUM(:,[conical_r]);
            obj2=NUM(:,[lego_l_tr,lego_l_bl]);
        elseif obj_type==21 
            obj2=NUM(:,[conical_r]);
            obj1=NUM(:,[lego_l_tr,lego_l_bl]);
        else
            obj2=NUM(:,[conical_l]);
            obj1=NUM(:,[lego_r_tr,lego_r_bl]);
        end

    end

interactions=NORT_new(i,trial,obj_type,startframe,currentfile,NUM(:,[topleft,topright,bottomleft,bottomright]),NUM(:,[snout, head, centroid]),obj1,obj2, VideoReader(fullfile(logs(i).folder,'behavcam_1.avi')), VideoWriter(fullfile(logs(i).folder,'behavCam1_ROI'),'MPEG-4'), thresh);    

%save current figure
   saveas(gcf,figpath);
   close(gcf); 

   [m,~]=size(interactions);
   
   save(fullfile(fullfile(logs(i).folder,'mouse_explore.mat')),'interactions');
    
   if trial==1
    interactions=interactions(startframe:startframe+18000,:);
   else interactions=interactions(startframe:startframe+9000,:);
   end

  
  [m,~]=size(interactions);
  
  summation=sum(interactions);
  
  for j=2:3
      summation(j)=100*summation(j)/m;
  end
  
  summation(5)=summation(5)/m;
  
  if trial==1
      final_results(row+1,2)=num2cell(summation(2));
      final_results(row+1,3)=num2cell(summation(3));
      final_results(row+1,4)=num2cell(summation(4));
      final_results(row+1,5)=num2cell(summation(5));
  else
      final_results(row+1,6)=num2cell(summation(2));
      final_results(row+1,7)=num2cell(summation(3));
      final_results(row+1,8)=num2cell(summation(4));
      final_results(row+1,9)=num2cell(summation(5));
  end

   final_results(row+1,10)=cellstr(genotype);
  final_results(row+1,11)=cellstr(sex);
  
fprintf('%s %s complete \n',trial, char(currentfile));
waitbar(i/numFiles, f, sprintf('Look at them interact: %d %%', floor(100*i/numFiles)));

     
end
close(f);
function interactions=NORT_new(i,trial,obj_type,s,currentfile,corners,mouse,obj1,obj2, oldv,newv, thresh)
    
    [m,~]=size(mouse);
    interactions = cell(m+1,5);
    
    open(newv);
    
    interactions{1,1}={'Frame'};
    interactions{1,2}={'Object 1'};
    interactions{1,3}={'Object 2'};
    interactions{1,4}={'Distance Travelled (m)'};
    interactions{1,5}={'Average Velocity (m/s)'};

    corners=mean(corners(s:end,:));
    
    tl=[corners(1) corners(2)];
    tr=[corners(3) corners(4)];
    bl=[corners(5) corners(6)];
    br=[corners(7) corners(8)];
    
    obj1=mean(obj1(s:end,:));
    obj2=mean(obj2(s:end,:));
    
    mouse_head_size=(tl(2)-bl(2))/13;
    mouse_head_size=abs(floor(mouse_head_size));
    ht=1*mouse_head_size;
    wd=1*mouse_head_size;

    if trial==1
        if obj_type==11 || obj_type==12 
            center1=obj1;
            obj1=[obj1(1)+1.75*wd obj1(2)-ht obj1(1) obj1(2)+ht];
            intzone1=[obj1(1)+1.1*mouse_head_size  obj1(2)-(1.3*mouse_head_size);obj1(3)-(1.3*mouse_head_size)  obj1(4)+1.1*mouse_head_size];
            center2=obj2;
            obj2=[obj2(1) obj2(2)-ht obj2(1)-1.75*wd obj2(2)+ht];
            intzone2=[obj2(1)+1.1*mouse_head_size  obj2(2)-(1.3*mouse_head_size);obj2(3)-(1.3*mouse_head_size)  obj2(4)+1.1*mouse_head_size];
        else
             center1=[(obj1(1)+obj1(3))/2 (obj1(2)+obj1(4))/2];
             intzone1=[obj1(1)+2.5*mouse_head_size  obj1(2)-(1.3*mouse_head_size);obj1(3)  obj1(4)+1.5*mouse_head_size];
             center2=[(obj2(1)+obj2(3))/2 (obj2(2)+obj2(4))/2];
             intzone2=[obj2(1) obj2(2)-(1.5*mouse_head_size);obj2(3)-2.8*mouse_head_size  obj2(4)+1.3*mouse_head_size];
        end
    else
        if obj_type==11
            center1=obj1;
            obj1=[obj1(1)+1.75*wd obj1(2)-ht obj1(1) obj1(2)+ht];
            intzone1=[obj1(1)+1.1*mouse_head_size  obj1(2)-(1.3*mouse_head_size);obj1(3)-(1.3*mouse_head_size)  obj1(4)+1.1*mouse_head_size];
            center2=[(obj2(1)+obj2(3))/2 (obj2(2)+obj2(4))/2];
            intzone2=[obj2(1) obj2(2)-(1.5*mouse_head_size);obj2(3)-2.8*mouse_head_size  obj2(4)+1.3*mouse_head_size];
        elseif obj_type==12
            center1=obj1;
            obj1=[obj1(1) obj1(2)-ht obj1(1)-1.75*wd obj1(2)+ht];
            intzone1=[obj1(1)+1.1*mouse_head_size  obj1(2)-(1.3*mouse_head_size);obj1(3)-(1.3*mouse_head_size)  obj1(4)+1.1*mouse_head_size];
            center2=[(obj2(1)+obj2(3))/2 (obj2(2)+obj2(4))/2];
            intzone2=[obj2(1)+2.5*mouse_head_size  obj2(2)-(1.3*mouse_head_size);obj2(3)  obj2(4)+1.5*mouse_head_size];
        elseif obj_type==21
            center2=obj2;
            obj2=[obj2(1) obj2(2)-ht obj2(1)-1.75*wd obj2(2)+ht];
            intzone2=[obj2(1)+1.1*mouse_head_size  obj2(2)-(1.3*mouse_head_size);obj2(3)-(1.3*mouse_head_size)  obj2(4)+1.1*mouse_head_size];
            center1=[(obj1(1)+obj1(3))/2 (obj1(2)+obj1(4))/2];
            intzone1=[obj1(1)+2.5*mouse_head_size  obj1(2)-(1.3*mouse_head_size);obj1(3)  obj1(4)+1.5*mouse_head_size];
        else
            center2=obj2;
            obj2=[obj2(1)+1.75*wd obj2(2)-ht obj2(1) obj2(2)+ht];
            intzone2=[obj2(1)+1.1*mouse_head_size  obj2(2)-(1.3*mouse_head_size);obj2(3)-(1.3*mouse_head_size)  obj2(4)+1.1*mouse_head_size];
            center1=[(obj1(1)+obj1(3))/2 (obj1(2)+obj1(4))/2];
            intzone1=[obj1(1) obj1(2)-(1.5*mouse_head_size);obj1(3)-2.8*mouse_head_size  obj1(4)+1.3*mouse_head_size];
        end
    end
    
    %convert pixels to meters  
    width = pdist([tl;tr]);
    pix_per_m = width/0.45;
    
%     [mouse_new]=mouse_correction(mouse,s,200);
%     mouse=mouse_new;

    for j=2:m
       interactions{j,1} =(j-1);
    
     snout=mouse(j-1,1:3);
     head=mouse(j-1,4:6);     
     centroid=mouse(j-1,7:9);
     if (j==2)
         prev=mouse(j-1,7:9);
     else prev=mouse(j-2,7:9);
     end

     
     if mouse(j-1,6)>=thresh
         chance=true;
     elseif mouse(j-1,9)>=thresh
         chance=true;
     else chance=false;
     end
     
     %if(chance)
         
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
         
        int1=0;
        int2=0;
        
        if snout(1,3)>=thresh
            [int1]=mouse_in_roi(snout,intzone1);
            [int2]=mouse_in_roi(snout,intzone2);
        
        elseif head(1,3)>=thresh
            [int1]=mouse_in_roi(head,intzone1);
            [int2]=mouse_in_roi(head,intzone2);
        end
        
        if int1==1
            interactions{j,2}=true;
        elseif int2==1
            interactions{j,3}=true;
        end
        
         if centroid(1,3)>thresh && head(1,3)>thresh
         d1=pdist2(centroid(:,1:2),center1);
         d2=pdist2(centroid(:,1:2),center2);
         if d1<d2
            theta=find_mouse_angle(center1,head(1:2),centroid(1:2)); 
         else
            theta=find_mouse_angle(center2,head(1:2),centroid(1:2)); 
         end
      
      if theta>90
          interactions{j,2}=false;
          interactions{j,3}=false;
      end
         end       
         
    end
    
    f=999;

    wb = waitbar(0, 'Starting');
    
    while (f<(1899))
        waitbar((f-999)/900, wb, sprintf('What are they doing? Dear lord: %d %%', floor(100*(f-999)/900)));
        frame = readFrame(oldv);      
        frame_cor=[tl(1) tl(2); tr(1) tr(2); bl(1) bl(2);br(1) br(2)];
        for j=1:4
            frame=mark_frame([frame_cor(j,1) frame_cor(j,2)],frame,5,[50 50 200]);
        end
        
        snout=mouse(f,1:3);
        head=mouse(f,4:6);     
        centroid=mouse(f,7:9);
        
        frame_obj=[obj1(1) obj1(2); obj1(3) obj1(4); obj2(1) obj2(2);obj2(3) obj2(4)];
            
        for j=1:4
            frame=mark_frame([frame_obj(j,1) frame_obj(j,2)],frame,5,[200 50 50]);
        end

        frame_int=[intzone1(1,1) intzone1(1,2); intzone1(2,1) intzone1(2,2); intzone2(1,1) intzone2(1,2); intzone2(2,1) intzone2(2,2)];

        for j=1:4
            frame=mark_frame([frame_int(j,1) frame_int(j,2)],frame,5,[250 50 200]);
        end



        if snout(3)>thresh
           frame=mark_frame([snout(1) snout(2)],frame,2,[250,60,50]);
        end

        if head(3)>thresh 
            frame=mark_frame([head(1) head(2)],frame,2,[50,60,250]);
        end

        if centroid(3)>thresh 
            frame=mark_frame([centroid(1) centroid(2)],frame,2,[60,250,50]);
        end
        
        if interactions{f,2}==true
            frame=mark_frame([center1(1) center1(2)],frame,10,[250,0,0]); 
        end
        
        if interactions{f,3}==true
            frame=mark_frame([center2(1) center2(2)],frame,10,[0,0,250]); 
        end
        
        writeVideo(newv, frame);
        f=f+1;
    end
            
     close(newv); 
     close(wb);
     
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