%% Values to Set
clear

%Enter the columns of the DLCcoordinates.csv for each marker w/ likelihood
snout =50:52;  
head =53:55;
centroid=56:58;
topleft=2:3;
topright=5:6;
bottomleft=32:33;
bottomright=35:36;
upperleft=8:9;
upperright=11:12;
lowerleft=26:27;
lowerright=29:30;
topcup=14:25;
bottomcup=38:49;

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


final_results=cell(numFiles+1,13);
final_results(1,1)={'Mouse Name'};
final_results(1,2)={'Empty Cup'};
final_results(1,3)={'Mouse Cup'};
final_results(1,4)={'Empty Chamber'};
final_results(1,5)={'Middle Chamber'};
final_results(1,6)={'Mouse Chamber'};
final_results(1,7)={'Empty Interactions'};
final_results(1,8)={'Mouse Interactions'};
final_results(1,9)={'First Choice'};
final_results(1,10)={'Latency to mouse cup (s)'};
final_results(1,12)={'Velocity(m/s)'};
final_results(1,11)={'Distance travelled(m)'};
final_results(1,13)={'Genotype'};

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
    figpath=strcat(logs(i).folder,'\','_mouse_position.emf');
    
    
    final_results(i+1,1) = currentfile;
    
      
  
    load(fullfile(logs(i).folder,'cup_location.mat'));
        
    interactions= NORT(i,currentfile,NUM(:,[topleft,topright,bottomleft,bottomright]),NUM(:,[upperleft,upperright,lowerleft,lowerright]),NUM(:,[topcup bottomcup]) ,NUM(:,[snout, head, centroid]),startframe, VideoReader(fullfile(logs(i).folder,'behavCam5.avi')), VideoWriter(fullfile(logs(i).folder,'behavCam666_ROI.avi')), thresh);       
     
   %save current figure
   saveas(gcf,figpath);
   close(gcf);
    
   %calculate % times for various zones as well as total distance, average velocity 
 [m,~]=size(interactions);
 
 %m=startframe+9000;
 
   interactions=interactions(startframe:m,:);
   
    save(fullfile(fullfile(logs(i).folder,'mouse_explore.mat')),'interactions');
  
  [m,~]=size(interactions);
   
   summation=sum(interactions);
    
   count1=0;
   count2=0;
   
    
   for p=4:m-2
       A=all(interactions(p-3:p-1,2)==0);
       B=all(interactions(p:p+2,2)==1);
       if(A==1)
           if(B==1)
               
               count1=count1+1;
               
           end
       end
       
       A=all(interactions(p-3:p-1,3)==0);
       B=all(interactions(p:p+2,3)==1);
       if(A==1)
           if(B==1)
               
               count2=count2+1;
               
           end
       end
   end
       
   
   
    for j=2:6
        summation(j)=100*summation(j)/m;
    end
    
    summation(8)=summation(8)/m;
    final_results(i+1,11)=num2cell(summation(7));
    final_results(i+1,12)=num2cell(summation(8));
    final_results(i+1,5)=num2cell(summation(5));
    
    if location==1
        final_results(i+1,2)=num2cell(summation(3));
        final_results(i+1,3)=num2cell(summation(2));
        final_results(i+1,4)=num2cell(summation(6));
        final_results(i+1,6)=num2cell(summation(4));
         final_results(i+1,7)=num2cell(count2);
        final_results(i+1,8)=num2cell(count1);
    else
        final_results(i+1,3)=num2cell(summation(3));
        final_results(i+1,2)=num2cell(summation(2));
        final_results(i+1,6)=num2cell(summation(6));
        final_results(i+1,4)=num2cell(summation(4));
         final_results(i+1,8)=num2cell(count2);
        final_results(i+1,7)=num2cell(count1);
    end
    
    
    
    %latency to mouse cup
    lat=0;
    k=2;
    
    
      while(lat==0)
          if (interactions(k,location+1)==1)
          lat=lat+1;
          end
          k=k+1;
      end
    final_results(i+1,10)=num2cell((k-1)/30);
 
      
    %choice of empty or mouse
    first=0;
    k=2;
    
    while(first==0)
        if(interactions(k,2)==0)&(interactions(k,3)==1)
            first=3;
        end
        
        if(interactions(k,2)==1)&(interactions(k,3)==0)
            first=2;
        end
        k=k+1;
    end
        
    if first==2
        if location==1
            final_results(i+1,9)=cellstr('Mouse');
        else final_results(i+1,9)=cellstr('Empty');
        end
    end
    
    if first==3
    if location==2
            final_results(i+1,9)=cellstr('Mouse');
        else final_results(i+1,9)=cellstr('Empty');
        end
    end
    
     final_results(i+1,13)=cellstr(genotype);
    
    clear NUM;
    
     fprintf('%d files remaining\n',numFiles-i);
    
end




function interactions = NORT(i,currentfile,corners,sections,cup, mouse,s, oldv, newv, thresh)
    [m,~]=size(mouse);
    interactions = cell(m+1,8);
    
%     for t=0:2
%         mouse_temp=mouse(:,(3*t+1):(3*t+2));
%         mouse_temp=smoothdata(mouse_temp,'movmedian',10);
%         mouse(:,(3*t+1):(3*t+2))=mouse_temp;
%     end
    
    %new video for ROI
    open(newv);
    
    interactions{1,1}={'Frame'};
    interactions{1,2}={'Cup Top'};
    interactions{1,3}={'Cup Bottom'};
    interactions{1,4}={'Top'};
    interactions{1,5}={'Middle'};
    interactions{1,6}={'Bottom'};   
    interactions{1,7}={'Distance Travelled (m)'};
    interactions{1,8}={'Average Velocity (m/s)'};
    
    
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
    
    
    sections=mean(sections);
    ul=[sections(1) sections(2)];
    ur=[sections(3) sections(4)];
    ll=[sections(5) sections(6)];
    lr=[sections(7) sections(8)];
    
    top=round((ul(2)+ur(2))/2);
    bottom=round((ll(2)+lr(2))/2);
    
    
    cup=mean(cup);
            
    topcenterin=[((cup(4)+cup(10))/2) cup(5)];
      
    topcenterout=[((cup(4)+cup(10))/2) ((cup(2)+cup(8))/2)];
            
    bottomcenterin=[((cup(16)+cup(22))/2) cup(17)];
            
    bottomcenterout=[((cup(16)+cup(22))/2) ((cup(14)+cup(20))/2)];
      
    radius1top=[topcenterin(1) topcenterin(2); cup(4) cup(5)];
            radius1=pdist(radius1top);
            
            topcenterinr=[topcenterin(2)-2 topcenterin(1)+2];
            
            ROI1 = drawcircle('Center',topcenterinr,'Radius',radius1,'StripeColor','red');
             topcenteroutr=[topcenterout(2)+3 topcenterout(1)+1];
             
              radius2top=[topcenterout(1) topcenterout(2); cup(1) cup(2)];
            radius2=8+pdist(radius2top);
            
            
            ROI2 = drawcircle('Center',topcenteroutr,'Radius',radius2,'StripeColor','red');
            radius1bottom=[bottomcenterin(1) bottomcenterin(2); cup(16) cup(17)];
            radius3=pdist(radius1bottom);
            
            bottomcenterinr=[bottomcenterin(2)+4 bottomcenterin(1)+2];
            
            ROI3 = drawcircle('Center',bottomcenterinr,'Radius',radius3,'StripeColor','red');
             bottomcenteroutr=[bottomcenterout(2)+2 topcenterout(1)-4];
             
              radius2bottom=[bottomcenterout(1) bottomcenterout(2); cup(13) cup(14)];
            radius4=8+pdist(radius2bottom);
            
            
            ROI4 = drawcircle('Center',bottomcenteroutr,'Radius',radius4,'StripeColor','red');          
    
    %convert pixels to meters   
    width = pdist([tl;tr]);
    pix_per_m = width/0.457;

    %will become true when thresh is crossed for dlc points
    chance=false;
    

    [mouse_new]=mouse_correction(mouse,s,50);
    mouse=mouse_new;
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
    
     else chance=false;
     end
     
                 
     if(chance)
        
            interactions{j,2} = false;
            interactions{j,3} = false;
                
            
            dis=0;
            
            if (j == 2)
            interactions{j,8}=0;
            else
                %distance and velocity per frame
                dis = pdist([centroid;prev]);
            dis = dis/pix_per_m;
            interactions{j,8} = dis*30;%because 30 fps to convert to m/s
         end 
        interactions{j,7}=dis;
        
        if centroid(2)<top
            interactions{j,4}=true;
        elseif centroid(2)<bottom
            interactions{j,5}=true;
        else interactions{j,6}=true;
        end
           
        %calculate interaction of mouse with object
            if inROI(ROI2,snout(2),snout(1)) 
                if ~inROI(ROI1,centroid(2), centroid(1))
                interactions{j,2}=true;
               end
            end
          
            if inROI(ROI4,snout(2),snout(1))
                if ~inROI(ROI3,centroid(2), centroid(1))
                interactions{j,3}=true;
                end
            end
           
     end
    
     %Mark the ROIs
    if hasFrame(oldv)
            frame = readFrame(oldv);
            
            
%             y=round(tl(1));
%             x=round(tl(2));
%             frame((x-1):(x+1),(y-1):(y+1),1) = 56;
%             frame((x-1):(x+1),(y-1):(y+1),2) = 61;
%             frame((x-1):(x+1),(y-1):(y+1),3) = 150;
%             y=round(tr(1));
%             x=round(tr(2));
%             frame((x-1):(x+1),(y-1):(y+1),1) = 56;
%             frame((x-1):(x+1),(y-1):(y+1),2) = 61;
%             frame((x-1):(x+1),(y-1):(y+1),3) = 150;
%              y=round(bl(1));
%             x=round(bl(2));
%             frame((x-1):(x+1),(y-1):(y+1),1) = 56;
%             frame((x-1):(x+1),(y-1):(y+1),2) = 61;
%             frame((x-1):(x+1),(y-1):(y+1),3) = 150;
%              y=round(br(1));
%             x=round(br(2));
%             frame((x-1):(x+1),(y-1):(y+1),1) = 56;
%             frame((x-1):(x+1),(y-1):(y+1),2) = 61;
%             frame((x-1):(x+1),(y-1):(y+1),3) = 150;
            
            frame((top-1):(top+1),:,1) = 56;
            frame((top-1):(top+1),:,2) = 161;
            frame((top-1):(top+1),:,3) = 50;
            
            frame((bottom-1):(bottom+1),:,1) = 156;
            frame((bottom-1):(bottom+1),:,2) = 61;
            frame((bottom-1):(bottom+1),:,3) = 150;
            
            


                       
           %Mark circle if interaction
            %if (j>s)
            
            Vertices1 = round(ROI1.Vertices);
            for e = 1:length(Vertices1)
                %if (interactions{j,2} == true)
                    frame(Vertices1(e,1),Vertices1(e,2),1) = 255;
                    frame(Vertices1(e,1),Vertices1(e,2),2) = 0;
                    frame(Vertices1(e,1),Vertices1(e,2),3) = 0;
               % end
            end
            
            
            
            Vertices2 = round(ROI2.Vertices);
            for e = 1:length(Vertices2)
                %if (interactions{j,2} == true)
                    frame(Vertices2(e,1),Vertices2(e,2),1) = 0;
                    frame(Vertices2(e,1),Vertices2(e,2),2) = 0;
                    frame(Vertices2(e,1),Vertices2(e,2),3) = 255;
               % end
            end
            
             
            
            Vertices3 = round(ROI3.Vertices);
            for e = 1:length(Vertices3)
                %if (interactions{j,2} == true)
                    frame(Vertices3(e,1),Vertices3(e,2),1) = 255;
                    frame(Vertices3(e,1),Vertices3(e,2),2) = 0;
                    frame(Vertices3(e,1),Vertices3(e,2),3) = 0;
               % end
            end
            
            
            
            Vertices4 = round(ROI4.Vertices);
            for e = 1:length(Vertices4)
                %if (interactions{j,2} == true)
                    frame(Vertices4(e,1),Vertices4(e,2),1) = 0;
                    frame(Vertices4(e,1),Vertices4(e,2),2) = 0;
                    frame(Vertices4(e,1),Vertices4(e,2),3) = 255;
               % end
            end
            
           
                
    
    writeVideo(newv, frame);
    
    %end
    end
end
   

     close(newv)
    %convert interactions to double
    mat = zeros(length(mouse),8);
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
    end
    interactions = mat;
  
    
    %make points for the centroid plot
     
   
   xpos=mouse(s:length(mat),7);
   ypos=mouse(s:length(mat),8);
   
  
 
    
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

            
            
      
            
            
            
       

            
           
            
           
            
            
            
            
            
            
            
            