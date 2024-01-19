%% Values to Set
clear

%Enter the columns of the DLCcoordinates.csv for each marker w/ likelihood
snout = 29:31; 
head =32:34;  
centroid = 35:37;
center=2:3;
topleftin=5:6;
topleftout=8:9;
toprightin=11:12;
toprightout=14:15;
bottomleftin=17:18;
bottomleftout=20:21;
%Set threshold DLC confidence for choice between snout and head tracking
thresh = 0.90;

%% Values to Set when using xtrapts
clear

%Enter the columns of the DLCcoordinates.csv for each marker w/ likelihood
snout = 29:31; 
head =35:37;  
centroid = 50:52;
center=2:3;
topleftin=5:6;
topleftout=8:9;
toprightin=11:12;
toprightout=14:15;
bottomleftin=17:18;
bottomleftout=20:21;
%Set threshold DLC confidence for choice between snout and head tracking
thresh = 0.90;


%% Gather video names and locations for analysis
tic
p_folder = uigetdir('Z:\Luke\Behavior\');


logs = dir(fullfile(p_folder,'**','DLCcoordinates.csv'));


%%
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
addpath(genpath('Y:\Lab Software and Code\RhushStuff'));
% logs=is_split(logs);
% coord_idx = true(length(logs),1);
numFiles = length(logs);



%Initiate cells to store total distance, average velocity and number of
%transitions from one arm to other
distance=cell(numFiles,2,1);
velocity=cell(numFiles,2,1);
transition=cell(numFiles,5,1);

final_results=cell(numFiles+1,13);
final_results(1,1)={'Mouse Name'};
final_results(1,2)={'Closed'};
final_results(1,3)={'Open'};
final_results(1,4)={'Top'};
final_results(1,5)={'Bottom'};
final_results(1,6)={'Left'};
final_results(1,7)={'Right'};
final_results(1,8)={'HeadDip'};
final_results(1,9)={'Total distance travelled (m)'};
final_results(1,10)={'Average Velocity (m/s)'};
final_results(1,12)={'Genotype'};
final_results(1,11)={'Head peeks'};
%final_results(1,13)={'Sex'};



for i = 1:numFiles
%     try
%         if ~exist(fullfile(logs(i).folder,'obj_interactions.mat'),'file')
            s = regexp(logs(i).folder, '\', 'split');
           % fprintf('Filtering matrix %.0f of %.0f: %s %s %s\n',i,numFiles,s{6},s{7},s{8})
            fprintf('Filtering matrix %.0f of %.0f: %s \n',i,numFiles,s{6})
               load(fullfile(logs(i).folder,'timestamp.mat'));
                load(fullfile(logs(i).folder,'genotype.mat'));
%                load(fullfile(logs(i).folder,'mouse_sex.mat'));
            [NUM,~,~] = xlsread(fullfile(logs(i).folder,logs(i).name));
            file_delim = strsplit(logs(i).folder, '\');
            [~,dsize]=size(file_delim);
           currentfile = file_delim(dsize);
            final_results(i+1,1) = currentfile;
             load(fullfile(logs(i).folder,'startframe.mat'));
           distance(i,1) = currentfile;
           velocity(i,1) = currentfile;
           transition(i,1) = currentfile;
           interactions = zeroMaze(NUM(:,[center,topleftin,topleftout,toprightin,bottomleftin,bottomleftout]),NUM(:,[snout, head, centroid]), VideoReader(fullfile(logs(i).folder,'behavCam1.avi')), VideoWriter(fullfile(logs(i).folder,'behavCam1_ROI_11_12.avi')),timestamp.behavecam(:,3), thresh);
            
            [m,~] = size(NUM(:,[snout,head]));
            
            displacement=0;
            vel=0;
            
            [n,~]=size(interactions);
           
%             %%for 5 min analysis
%             if n < 9000+startframe
%                n = n;
%             else
%             n = 9000+startframe;
%             end
            %%
            
            interactions=interactions(startframe:n,:);
            
             save(fullfile(fullfile(logs(i).folder,'mouse_explore.mat')),'interactions')
             
             [mn,~]=size(interactions);
            
            %Just to check quickly how things look overall. Completely
            %optional as it just sums all columns of interactions.
            summation=sum(interactions);
            for j=2:7
                summation(j)=100*summation(j)/mn;
            end
            
            summation(12)=100*summation(12)/mn;
            summation(2)=100-summation(3);
            summation(10)=summation(10)/mn;
            
            count=0;
             for p=4:mn-2
                   A=all(interactions(p-3:p-1,8)==0);
                   B=all(interactions(p:p+2,8)==1);
                   if(A==1)
                       if(B==1)

                           count=count+1;

                       end
                   end      
               end
            
            summation(8)=count;
            
             for j=2:10
                final_results(i+1,j)=num2cell(summation(j));
             end
             
           final_results(i+1,11)=num2cell(summation(12));
            %Calculate total distance, average velocity and transitions. The matrices
            %arent saved but are available in workspace as distance and
            %velocity
%             for j=1:m
%                 displacement=displacement+interactions(j,10);
%                 if(~isinf(interactions(j,9)))
%                     vel=vel+interactions(j,9);
%                 end
%             end
%             
%             vel=vel/m;
%             distance(i,2)=num2cell(displacement);
%             velocity(i,2)=num2cell(vel);
%             
%             to_open=0;
%             from_open=0;
%             to_close=0;
%             from_close=0;
%             %transitions are considered over a span of 10 frames.
%             for j=11:m-10;
%               
%                 A=all(interactions(j-10:j,2)==0);
%                 if(A==1)
%                     B=all(interactions(j+1:j+10,2)~=0);
%                     if(B==1)
%                         to_close=to_close+1;
%                     end
%                 end  
%                 
%                 A=all(interactions(j-10:j,2)==1);
%                 if(A==1)
%                     B=all(interactions(j+1:j+10,2)~=1);
%                     if(B==1)
%                         from_close=from_close+1;
%                     end
%                 end  
%                 
%                 A=all(interactions(j-10:j,3)==0);
%                 if(A==1)
%                     B=all(interactions(j+1:j+10,3)~=0);
%                     if(B==1)
%                         to_open=to_open+1;
%                     end
%                 end    
%                 
%                 A=all(interactions(j-10:j,3)==1);
%                 if(A==1)
%                     B=all(interactions(j+1:j+10,3)~=1);
%                     if(B==1)
%                         from_open=from_open+1;
%                     end
%                 end    
%             end
%             
%             
%             transition(i,2)=num2cell(from_open);
%             transition(i,3)=num2cell(to_close);
%             transition(i,4)=num2cell(from_close);
%             transition(i,5)=num2cell(to_open);
            
            
            %save the interactions matrix
            fprintf("     Saving...\n")
           
            
             final_results(i+1,12)=cellstr(genotype);
%             final_results(i+1,13)=cellstr(sex);
            
            clear NUM;
%         

toc
end

%Analyze Videos

function interactions = zeroMaze(coord,snout, oldv, newv, time, thresh)
    [m,~] = size(snout);
    interactions = cell(m+1,11);
    
    %Set titles
    interactions{1,1} = "Frame";
    interactions{1,2} = "Closed";
    interactions{1,3} = "Open";
    interactions{1,4} = "Top";
    interactions{1,5} = "Bottom";
    interactions{1,6} = "Left";
    interactions{1,7} = "Right";
    interactions{1,8} = "HeadDip";
    interactions{1,9} = "Speed";
    interactions{1,10} = "Distance";
    interactions{1,11} = "Freezing";
    interactions{1,12} = "Investigate";%value is 1 if mouse is freezing
    
    open(newv);
  
    
    %Make ROI's
    [center, radius1, radius2] = findMid(coord);
    radius2 = abs(radius2);
    
    center2(1)=center(2);
    center2(2)=center(1)+1;
    
    %adjust radii according to platform or regular ezm by changing 4th
    %value in the parentheses. 
    ROIo = drawcircle('Center',center2,'Radius',radius1,'StripeColor','red');
    ROIi = drawcircle('Center',center2,'Radius',radius2-1,'Color','blue');
    
    %Set bounds where the closed arms open, NEED TO MALE IT HIT TOP OF INN
    bound1 = floor(center2(1) - round(radius2 * 0.75)); %top bound, 0.8 for bright, 0.75 for xtra
    bound2 = floor(center2(1) + round(radius2 * 0.80)); %bottom bound, 0.85 for bright, 0.80 for xtra
%      

    %calculate pix per meters by dividing by actual width of ezm
    width = sqrt(((coord(1,3)-coord(1,7)).^2) + ((coord(1,4)-coord(1,8)).^2));
    pix_per_m = width/0.33;

%     
%      time(1) = 0;
%      time2 = [0 time'];
%      time_dif = ((time') - time2(1:m))/1000; 
    
    for i = 2:(m+1)
        
        s=0;
        
        %choose snout or head based on DLC confidence
        if (snout(i-1,3) >= thresh)
              coords = snout(i-1,1:2);
              if (i==2)
                  prev = snout(i-1,1:2);
              else
                  prev = snout(i-2,1:2);
              end
              chance = true;
         else
             if(snout(i-1,6) >= thresh)
                 coords(2) = snout(i-1,5);
                 coords(1) = snout(i-1,4);
                 if (i==2)
                     prev = snout(i-1,4:5);
                 else
                 prev = snout(i-2,4:5);
                 end
                 chance = true;
             else
                 chance = false;
             end
        end

        
             
        %Fill in interactions array based om DLC coordinates
        interactions{i,1} = i-1;
        centroid = snout(i-1,7:8);
        headpoke = snout(i-1,4:5);
        snoutpoke = snout(i-1,1:2);
        if (chance)
            interactions{i,2} = false;
            interactions{i,3} = false;
            interactions{i,4} = false;
            interactions{i,5} = false;
            interactions{i,6} = false;
            interactions{i,7} = false;
            interactions{i,8} = false;
            
             dis=0;
        
         if (i == 2)
            interactions{i,9}=0;
         else
            dis = sqrt(((coords(1)-prev(1)).^2) + ((coords(2)-prev(2)).^2));
            dis = dis/pix_per_m;
            interactions{i,9} = dis*30;%because 30 fps to convert to m/s
         end 
        interactions{i,10}=dis;
        if (interactions{i,10} >=0.0005) %threshold to see if mouse is moving between frames
            interactions{i,11}=0;
        else interactions{i,11}=1;
        end
          

            if(centroid(2) < bound1)
               interactions{i,2} = true; %Closed
               interactions{i,4} = true; %Top
            elseif(centroid(2) > bound2)
                interactions{i,2} = true; %Closed
                interactions{i,5} = true; %Bottom
            else
                interactions{i,3} = true; %Open
                if(snout(i-1,4) < center(1)) 
                    interactions{i,6} = true; %Left
                     if (inROI(ROIi,snout(i-1,5),snout(i-1,4)))
                         interactions{i,8} = true; %Headdip inside
                     elseif (inROI(ROIo,snout(i-1,5),snout(i-1,4)))
                        interactions{i,8} = false; %No head dip
                     else
                         interactions{i,8} = true; %Head dip ouside
                     end 
                else
                    interactions{i,7} = true; %Right
                     if (inROI(ROIi,snout(i-1,5),snout(i-1,4))) %Head dip inside
                         interactions{i,8} = true; %Head dip inside
                     elseif (inROI(ROIo,snout(i-1,5),snout(i-1,4)))
                        interactions{i,8} = false; %No head dip
                     else
                         interactions{i,8} = true; %Head dip outside
                     end 
                end
            end
            
            if headpoke>bound1
                if headpoke<bound2
                interactions{i,12}=true;
                end
            end
            
             if snoutpoke>bound1
                if snoutpoke<bound2
                interactions{i,12}=true;
                end
            end
            
        end
        
        

        if hasFrame(oldv)
            frame = readFrame(oldv);


            %Mark snout/head
            if(chance)
                n = round(snout(i-1,7)); %horizontal 
                m = round(snout(i-1,8)); %vertical
                [y,x,~] = size(frame); x = x-4; y = y -4;
                if ((m < y) && (m > 4))
                    if ((n < x) && (n > 4))
%                         %Magenta for headdip
%                         if(interactions{i,8} == true) 
%                             frame((m-3):(m+3),(n-3):(n+3),1) = 187;
%                             frame((m-3):(m+3),(n-3):(n+3),2) = 86;
%                             frame((m-3):(m+3),(n-3):(n+3),3) = 149;
%                         %Blue for top 
%                         elseif(interactions{i,4} == true)          
%                             frame((m-3):(m+3),(n-3):(n+3),1) = 56;
%                             frame((m-3):(m+3),(n-3):(n+3),2) = 61;
%                             frame((m-3):(m+3),(n-3):(n+3),3) = 150;
%                         %Green for bottom
%                         elseif(interactions{i,5} == true) 
%                             frame((m-3):(m+3),(n-3):(n+3),1) = 70;
%                             frame((m-3):(m+3),(n-3):(n+3),2) = 148;
%                             frame((m-3):(m+3),(n-3):(n+3),3) = 73;
%                         %Orange for left
%                         elseif(interactions{i,6} == true)
%                             frame((m-3):(m+3),(n-3):(n+3),1) = 214;
%                             frame((m-3):(m+3),(n-3):(n+3),2) = 126;
%                             frame((m-3):(m+3),(n-3):(n+3),3) = 44;
%                         %Yellow for right
%                         elseif(interactions{i,7} == true) 
%                             frame((m-3):(m+3),(n-3):(n+3),1) = 231;
%                             frame((m-3):(m+3),(n-3):(n+3),2) = 199;
%                             frame((m-3):(m+3),(n-3):(n+3),3) = 31;
%                         end
                        
                            if(interactions{i,3} == true) 
                            frame((m-3):(m+3),(n-3):(n+3),1) = 256;
                            frame((m-3):(m+3),(n-3):(n+3),2) = 0;
                            frame((m-3):(m+3),(n-3):(n+3),3) = 0;
                           
                            
                            else
                                frame((m-3):(m+3),(n-3):(n+3),1) = 0;
                            frame((m-3):(m+3),(n-3):(n+3),2) = 0;
                            frame((m-3):(m+3),(n-3):(n+3),3) = 256;
                            end
                    end
                end
            end

            %Mark bound 1
            frame((bound1-1):(bound1+1),:,1) = 175;
            frame((bound1-1):(bound1+1),:,2) = 54;
            frame((bound1-1):(bound1+1),:,3) = 60;

            %Mark bound 2
            frame((bound2-1):(bound2+1),:,1) = 100;
            frame((bound2-1):(bound2+1),:,2) = 54;
            frame((bound2-1):(bound2+1),:,3) = 200;

            in1 = true;
            in2 = true;
            %Mark ROI inner and outer
            Vertices1 = round(ROIi.Vertices);
            for e = 1:length(Vertices1)
                if (in1 == true)
                    frame(Vertices1(e,1),Vertices1(e,2),1) = 175;
                    frame(Vertices1(e,1),Vertices1(e,2),2) = 54;
                    frame(Vertices1(e,1),Vertices1(e,2),3) = 60;
                end
            end
%                 if(~isempty(objinfo{10}))
                Vertices2 = round(ROIo.Vertices);
                for e = 1:length(Vertices2)
                    if (in2 == true)
                        frame(Vertices2(e,1),Vertices2(e,2),1) = 175;
                        frame(Vertices2(e,1),Vertices2(e,2),2) = 54;
                        frame(Vertices2(e,1),Vertices2(e,2),3) = 60;
                    end
                end
%                 end
            writeVideo(newv, frame);   
         end
    end
    close(newv);
    
    %convert interactions from cell to double
    mat = zeros(length(snout),12);
    for j = 1:length(snout)
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
        if (~isempty(interactions{j+1,11}))
             mat(j,11) = interactions{j+1,11};
        end
        
        if (~isempty(interactions{j+1,12}))
             mat(j,12) = interactions{j+1,12};
        end
    end
    interactions = post_filt(mat, 10);
end

%Filter out head dips less than thresh # of frames
function interactions = post_filt(mat,thresh)
    lines = diff(mat(:,8));
    starts = find(lines > 0);
    stops = find(lines < 0);
    if (length(starts) < length(stops))
        starts = [1; starts];
    elseif (length(starts) > length(stops))
        stops = [stops; length(mat)];
    end
    lengths = stops - starts;
    blips = find(lengths <= thresh);
    for i = 1:length(blips)
        mat(starts(blips(i)):stops(blips(i)),8) = 0;
    end
    interactions = mat;
end

%Find center and radius of the maze using a binary of the first frame
function [center,radius1, radius2] = findCenter(frame)
    fprintf("     Locating center...\n")
    [m,n] = size(frame(:,:,1));
    bandw = imbinarize(frame(:,:,1),0.5);
    i = 1;
    while (bandw(i,round(n/2)) == false)
        i = i +1;
    end
    j = 1;
    while (bandw(round(m/2),j) == false)
        j = j +1;
    end
    k = m;
    while (bandw(k,round(n/2)) == false)
        k = k - 1;
    end
    radius1 = (k-i)/2;
    center = [i+radius1,j+radius1];
    j2 = j;
    while (bandw(round(m/2),j2) == true)
        j2 = j2 + 1;
    end
    radius2 = radius1 - (j2 - j);
end

% Find center and radius using DLC coordinates of the maze
function [center,radius1,radius2] = findMid(field)

fprintf(" Locating center and radii...\n")


fixed=field(1,:);
center(1)=fixed(1);
center(2)=fixed(2);

tlin=[fixed(3) fixed(4)];
tlout=[fixed(5) fixed(6)];
trin=[fixed(7) fixed(8)];
blin=[fixed(9) fixed(10)];
blout=[fixed(11) fixed(12)];

radius2=(pdist([center;tlin])+pdist([center;trin]))/2;
radius1=(pdist([center;tlout])+pdist([center;blout]))/2;

end

function [speeds, quart_labels] = peaks_per_quart(speeds, behavTime)

    behavTime(1) = 0;
    
    last_second = floor(behavTime(end)/1000);
    extra = mod(behavTime(end),last_second*1000);
    if (extra > 0)
       last_second = last_second + 1;
    end
    seconds = (1:last_second);
    
    %bin behavior time by seconds
    fprintf('\t Binning behavior time\n')
    new_behavTime = zeros(length(behavTime));
    bindex = 1;
    for i = 1:length(behavTime)
        if (behavTime(i) < seconds(bindex)*1000)
            new_behavTime(i) = seconds(bindex); 
        else
            bindex = bindex + 1;
            new_behavTime(i) = seconds(bindex);
        end
    end
    
    fprintf('\t Finding average speed/sec\n')
    tiles = quantile(speeds,4);
    quart_labels = zeros(length(speeds),1);
    for i = seconds
        rows = find(new_behavTime == i);
        avg_speed =  mean(speeds(rows));
        speeds(rows) = avg_speed;
        if (avg_speed <= tiles(1))
            quart_labels(rows) = 1;
        elseif (avg_speed <= tiles(2))
            quart_labels(rows) = 2;
        elseif (avg_speed <= tiles(3))
            quart_labels(rows) = 3;
        else
            quart_labels(rows) = 4;
        end
    end
    
end

function speed = scalc(current,last,pix_per_m, time)
    dist = sqrt(((current(1)-last(1)).^2) + ((current(2)-last(2)).^2));
    dist = dist/pix_per_m;
    speed = dist/time;
end