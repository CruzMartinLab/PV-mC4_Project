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

%% FOR NORT 30 Min
clear
snout=29:31;
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
final_results(1,14)={'Trial 4 Novel'};
final_results(1,15)={'Trial 4 Familiar'};
final_results(1,16)={'Trial 4 Distance'};
final_results(1,17)={'Trial 4 Velocity'};
final_results(1,18)={'Genotype'};
final_results(1,19)={'Mouse Sex'};

row=1;
animals=numFiles/4;

f = waitbar(0, 'Starting');
for i=1:numFiles
    
    row=mod(i,animals);
    
    if row==0
        row=animals;
    end
    
    s = regexp(logs(i).name, '\', 'split');
    file_delim = strsplit(logs(i).folder, '\');
%     load(fullfile(logs(i).folder,'TimeStamp.mat'));
    load(fullfile(logs(i).folder,'startframe.mat'));
     load(fullfile(logs(i).folder,'genotype.mat'));
     load(fullfile(logs(i).folder,'mouse_sex.mat'));
    
    %read in the DLC file
    [NUM,~,~] = xlsread(fullfile(logs(i).folder,logs(i).name));
    [~,n]=size(file_delim);
    currentfile = file_delim(n);
    trial=char(file_delim(n-1));
    nort_type=char(file_delim(n-2));
    figpath=strcat(logs(i).folder,'\','_mouse_position.jpg');
    
  
    final_results(row+1,1) = currentfile;
      
    if contains(nort_type,'5min')
        interactions= NORT(i,trial,nort_type,startframe,currentfile,NUM(:,[topleft,topright,bottomleft,bottomright]),NUM(:,[bottle1_tr,bottle1_bl]),NUM(:,[bottle2_tr,bottle2_bl]), NUM(:,[nov_tr,nov_bl]), NUM(:,[snout, head, centroid]), VideoReader(fullfile(logs(i).folder,'behavcam_0.avi')), VideoWriter(fullfile(logs(i).folder,'Behavcam_0_ROI.avi')), thresh);   
    else
        interactions= NORT(i,trial,nort_type,startframe,currentfile,NUM(:,[topleft,topright,bottomleft,bottomright]),NUM(:,[bottle1_tr,bottle1_bl]),NUM(:,[bottle2_tr,bottle2_bl]), NUM(:,[nov_peak]), NUM(:,[snout, head, centroid]), VideoReader(fullfile(logs(i).folder,'behavcam_0.avi')), VideoWriter(fullfile(logs(i).folder,'Behavcam_0_ROI.avi')), thresh);
    end
    
    
   %save current figure
   saveas(gcf,figpath);
   close(gcf);
    
   %calculate % times for various zones as well as total distance, average velocity 
   [m,~]=size(interactions);
   
   save(fullfile(fullfile(logs(i).folder,'mouse_explore.mat')),'interactions');
 
   interactions=interactions(startframe:m,:);

  
  [m,~]=size(interactions);
  
  summation=sum(interactions);
  
  for j=2:3
      summation(j)=100*summation(j)/m;
  end
  
  summation(5)=summation(5)/m;
  
  if contains(trial,'T1')
      final_results(row+1,2)=num2cell(summation(2));
      final_results(row+1,3)=num2cell(summation(3));
      final_results(row+1,4)=num2cell(summation(4));
      final_results(row+1,5)=num2cell(summation(5));
  elseif contains(trial,'T2')
      final_results(row+1,6)=num2cell(summation(2));
      final_results(row+1,7)=num2cell(summation(3));
      final_results(row+1,8)=num2cell(summation(4));
      final_results(row+1,9)=num2cell(summation(5));
  elseif contains(trial,'T3')
      final_results(row+1,10)=num2cell(summation(2));
      final_results(row+1,11)=num2cell(summation(3));
      final_results(row+1,12)=num2cell(summation(4));
      final_results(row+1,13)=num2cell(summation(5));
  elseif contains(trial,'T4')
      final_results(row+1,14)=num2cell(summation(2));
      final_results(row+1,15)=num2cell(summation(3));
      final_results(row+1,16)=num2cell(summation(4));
      final_results(row+1,17)=num2cell(summation(5));
  end
  

  final_results(row+1,18)=cellstr(genotype);
  final_results(row+1,19)=cellstr(sex);
  
fprintf('%s %s complete \n',trial, char(currentfile));
waitbar(i/numFiles, f, sprintf('Look at them interact: %d %%', floor(100*i/numFiles)));

   
end

close(f)

function interactions = NORT(i,trial,type,s,currentfile,corners,obj1,obj2,nov,mouse, oldv, newv, thresh)
    
    type_flag=0;
    
    if contains(type,'30min')
        type_flag=1;
    end
    
    [m,~]=size(mouse);
    interactions = cell(m+1,5);
    
    %new video for ROI
    open(newv);
    
    interactions{1,1}={'Frame'};
    interactions{1,2}={'Object 1'};
    interactions{1,3}={'Object 2'};
    interactions{1,4}={'Distance Travelled (m)'};
    interactions{1,5}={'Average Velocity (m/s)'};
    
   
    corners=mean(corners(1:10,:));
    tl=[corners(1) corners(2)];
    tr=[corners(3) corners(4)];
    bl=[corners(5) corners(6)];
    br=[corners(7) corners(8)];
       
    
    
    obj1=mean(obj1(s:end,:));
    obj2=mean(obj2(s:end,:));
    
    nov=mean(nov(s:end,:));
    
    t1=obj1(3);
    t2=obj2(3);
    
    obj1=[obj1(1) obj1(2) obj1(4) obj1(5)];
    obj2=[obj2(1) obj2(2) obj2(4) obj2(5)];
    
    if type_flag==1
        nov=[nov(1) nov(2)];
    else
        nov=[nov(1) nov(2) nov(4) nov(5)];
    end
         
    
    if type_flag==1
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
    end
    
    center2=[(obj2(1)+obj2(3))/2 (obj2(2)+obj2(4))/2];
     if contains(trial,'T4')
         center1=[(nov(1)+nov(3))/2 (nov(2)+nov(4))/2];
     else 
         center1=[(obj1(1)+obj1(3))/2 (obj1(2)+obj1(4))/2];
     end
    
    
    if type_flag==1
        mouse_head_size=(obj2(4)-obj2(2))/10;
    else
        mouse_head_size=(obj2(4)-obj2(2))/5;
    end
    mouse_head_size=floor(mouse_head_size);
    
    if type_flag==1
        if contains(trial,'T4')
            %this is 30 min novel object
            intzone1=[nov(1)+(1.5*mouse_head_size)  nov(2)-mouse_head_size;nov(3)-1*mouse_head_size  nov(4)+(mouse_head_size)];
            intzone2=[obj2(1)+mouse_head_size  obj2(2)-(3*mouse_head_size);obj2(3)-(3.5*mouse_head_size)  obj2(4)+2*mouse_head_size];
            
        else 
            % this is 30 min familiar objects
            intzone1=[obj1(1)+(3.5*mouse_head_size)  obj1(2)-(2*mouse_head_size);obj1(3)-(mouse_head_size)  obj1(4)+3*mouse_head_size];
            intzone2=[obj2(1)+mouse_head_size  obj2(2)-(3*mouse_head_size);obj2(3)-(3.5*mouse_head_size)  obj2(4)+2*mouse_head_size];
        end
    else
        if contains(trial,'T4')
            %this is 5 min novel object
            intzone1=[nov(1)+(3*mouse_head_size)  nov(2)-mouse_head_size;nov(3)-2.5*mouse_head_size  nov(4)+(2*mouse_head_size)];
            intzone2=[obj2(1)+2*mouse_head_size  obj2(2)-(3*mouse_head_size);obj2(3)-(2.5*mouse_head_size)  obj2(4)+2*mouse_head_size];
            
        else
            %this is 5 min familiar object
            intzone1=[obj1(1)+(3*mouse_head_size)  obj1(2)-2*mouse_head_size;obj1(3)-2*mouse_head_size  obj1(4)+(3*mouse_head_size)];
            intzone2=[obj2(1)+2*mouse_head_size  obj2(2)-(3*mouse_head_size);obj2(3)-(2.5*mouse_head_size)  obj2(4)+2*mouse_head_size];
            
        end
    end
    
      
    %convert pixels to meters   
    width = pdist([tl;tr]);
    pix_per_m = width/0.45;

    %will become true when thresh is crossed for dlc points
    chance=false;
    
    [mouse_new]=mouse_correction(mouse,s,200);
    mouse=mouse_new;
    
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
        
        
        % rewind code
        if snout(1,3)<thresh && head(1,3)<thresh
            if centroid(1,3)>thresh
                [zone]=check_mouse_zone(centroid,corners);
                if zone==1
                   interactions{j,2}=true;
                                 
                elseif zone==4
                   interactions{j,3}=true;
                    
                end
            elseif j>s 
                      
                    for k=j-2:-1:2
                       centroid_temp=mouse(k,7:9);
                       if centroid_temp(1,3)>thresh
                           break
                       end
                    end
                
                centroid_temp=mouse(k,7:9);
                if k==2
                   interactions{j,2}=false;
                   interactions{j,3}=false;
                else
                        [zone]=check_mouse_zone(centroid_temp,corners);
                        if zone==1
                            
                                interactions{j,2}=true;
                           

                        elseif zone==4
                            
                                interactions{j,3}=true;
                            
                        end
                
                end
            end
        end
        
            
        
      if centroid(1,3)>thresh && head(1,3)>thresh
         [zone]=check_mouse_zone(centroid,corners);
         if zone==1  
            theta=find_mouse_angle(center1,head(1:2),centroid(1:2)); 
         elseif zone==4 
            theta=find_mouse_angle(center2,head(1:2),centroid(1:2)); 
         else
            theta=100;
         end
      
      if theta>75
          interactions{j,2}=false;
          interactions{j,3}=false;
      end
      end
         
     %end
     
      if hasFrame(oldv)
            frame = readFrame(oldv);
         
           
            frame_cor=[tl(1) tl(2); tr(1) tr(2); bl(1) bl(2);br(1) br(2)];
            
            for j=1:4
                frame=mark_frame([frame_cor(j,1) frame_cor(j,2)],frame,3,[50 50 200]);
            end
          
            frame_obj=[obj1(1) obj1(2); obj1(3) obj1(4); obj2(1) obj2(2);obj2(3) obj2(4)];
            
            for j=1:4
                frame=mark_frame([frame_obj(j,1) frame_obj(j,2)],frame,3,[200 50 50]);
            end
            
            frame_int=[intzone1(1,1) intzone1(1,2); intzone1(2,1) intzone1(2,2); intzone2(1,1) intzone2(1,2); intzone2(2,1) intzone2(2,2)];
            
            for j=1:4
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
                if contains(trial,'T4')
                   frame=mark_frame([((nov(1)+nov(3))/2) ((nov(2)+nov(4))/2)],frame,10,[250 250 0]);
                else
                   frame=mark_frame([((obj1(1)+obj1(3))/2) ((obj1(2)+obj1(4))/2)],frame,10,[250 250 0]);
                end
            end

            if interactions{j,3}==true                               
                frame=mark_frame([256 256],frame,10,[250 0 250]);
            end


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
    
   %[mouse_new]=mouse_correction(mouse,s);
   % mouse=mouse_new; 
    
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