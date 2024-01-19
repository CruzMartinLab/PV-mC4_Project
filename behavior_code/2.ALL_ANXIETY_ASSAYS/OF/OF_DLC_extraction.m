%run timestamp, startframes, and DLC concat before this
%% Set Values
%Set DLC column numbers for the arena corners and centroid
corners = 2:13;
centroid = 17:19;

%Set DLC likelihood threshold
thresh = 0.9;

%Set to 1 for videos and path images or 0 for no videos or images
vid = 1;

%% Get files
%put the link to Data 2018-2019 or whatever folder you want to access
p_folder = uigetdir();
%%
logs = dir(fullfile(p_folder,'**','DLCcoordinates.csv'));
addpath(genpath('\\128.197.37.142\cm-lab-server-v2\Lab Software and Code\ConnorStuff\calcium_functions'));
%logs = is_split(logs);
coord_idx = true(length(logs),1);

logs = logs(coord_idx);
numFiles = length(logs);

%% Main Script

for i = 9
%      try
%         if ~exist(fullfile(logs(i).folder,'obj_interactions.mat'),'file')
            s = regexp(logs(i).folder, '\', 'split');
            len = length(s);
            fprintf('Filtering matrix %.0f of %.0f: %s %s %s\n',i,numFiles,s{len-2},s{len-1},s{len})
            [NUM,~,~] = xlsread(fullfile(logs(i).folder,'DLCcoordinates.csv'));
            load(fullfile(logs(i).folder,'timestamp.mat'));
            [interactions, path] = openField(NUM(:,[corners,centroid]), VideoReader(fullfile(logs(i).folder,'behavCam1.avi')), VideoWriter(fullfile(logs(i).folder,'behavCam1_ROI.avi')), timestamp.behavecam(:,3),thresh, vid);
           save(fullfile(fullfile(logs(i).folder,'obj_interactions.mat')),'interactions')
            if (vid == 1)
                imwrite(path,fullfile(logs(i).folder,'path.png'))
            end
            clear NUM;
%         else
%             disp('Matrix already completed')
%         end
%      catch
%           warning('Error on matrix #%d: %s\n', i, logs(i).name)
%      end
end

%% Functions

function [interactions, path] = openField(dlc, oldv, newv, time, thresh, vid)
    %dlc = coord_interp(dlc,thresh);
    interactions = zeros(length(dlc),6);
    
    count = 0;
    
    %Save corner coodrinate from dlc 
    tl = dlc(1,1:2); tr = dlc(1,4:5);
    bl = dlc(1,7:8); %% br = dlc(1,10:11);
    
    % Use the corner coordinates to get the height and width of one box to
    % divide the arena into 5x5 grid of boxes
    width = round((tr(1) - tl(1))/5);
    height = round((bl(2) - tl(2))/5);
    
    %Divide the width of the arena in pixels by it's width in meters to get
    %the pixels per meter value;
    pix_per_m = (tr(1) - tl(1))/0.5;
    
%     A = round(tl(1)); B = A + width; C = B + width; D = C + width; E = D + width; F = E + width; G = F + width; H = round(tr(1)); 
%     A = [A,B,C,D,E,F,G,H];
    
    %Find the columns where the boxes with start and stop such that A is
    %start of box 1 and F is end of box 5
    A = round(tl(1)); B = A + width; C = B + width; D = C + width; E = D + width; F = round(tr(1));
    A = [A,B,C,D,E,F];
    
%     S = round(tl(2)); T = S + height; U = T + height; V = U + height; W = V + height; X = W + height; Y = X + height; Z = round(bl(2));
%     B = [S,T,U,V,W,X,Y,Z];

    %Find the rows where the boxes with start and stop such that S is
    %start of box 1 and X is end of box 5
    S = round(tl(2)); T = S + height; U = T + height; V = U + height; W = V + height; X = round(bl(2));
    B = [S,T,U,V,W,X];
    
    %Blocks is an array of ROI's that represent the grid using the
    %coordinates in vectors A and B
    blocks = cell(5,5);
    for j = 1:5
        for k = 1:5
            blocks{j,k} = images.roi.Rectangle('Position',[A(k),B(j),A(k+1),B(j+1)],'StripeColor','r');
        end
    end
    
    %Open the new video file
    open(newv)
    
    %the dist vector is preallocated as a vector of zeros
    dist = zeros(length(time),1);
    %In is the points in the center. out is the points in the periphery. These are dummy values that will
    %be set later in the for loop.
    in = [4,4];
    out = [4,4];
    in_count = 2;
    out_count = 2;
    for i = 1:length(dlc)
        %The frame #
        interactions(i,1) = i;
        
        %Find the distance traveled since last point
        if (i == 1)
            %The first time value has to be set to 0
            time(i) = 0;
        else
            %Use the distance formula to find the distance between the last
            %point and this point
            pixels = sqrt(((dlc(i,13)-dlc(i-1,13)).^2) + ((dlc(i,14)-dlc(i-1,14)).^2));
            
            %Convert that value from pixels to meters
            dist(i) = pixels/pix_per_m;
        end 
        
        %Check Likelihood value is above threshold
        if(dlc(i,15) >= thresh)
            %Use the centroid
             coords = dlc(i,13:14);
             chance = true;
        else
             chance = false;
        end
        
        %Recor which box the mouse is in. Present num as the box 0,0 (does
        %not exist)
        num = [0 0];
        if (chance == true)
            %Check each ROI for the centroid coordinates and record which
            %are true in num
            for d = 1:5
                for e = 1:5
                    if (inROI(blocks{d,e},coords(2),coords(1)))
                        num = [d,e];
                    end
                end
            end
            %Interactison(:,2) is the periphery and Interactions(:,3) is
            %the center
            if ((num(1) == 1)||(num(1) == 5))
                %It's on the sides
                interactions(i,2) = true;
            elseif ((num(2) == 1)||(num(2) == 5))
                %It's on the top or bottom
                interactions(i,2) = true;
            elseif (num(1) == 0)
                %It's up on the walls
                interactions(i,2) = true;
            else  
                %It's in the center
                interactions(i,3) = true;
            end
        end
        
        %If the video is available mark up the video
        if ((vid == 1) && (hasFrame(oldv)))
            
            %Read in the frame from the behavCam file
            frame = readFrame(oldv);
            [r,c,~] = size(frame);
            
            %If this is the first frame, create the canvas which is the
            %arena with no mouse and the periphery in green and the center
            %in red
            if (count == 0)
                canvas = zeros(r,c,3);
                
                canvas(B(1):B(6),A(1):A(6),1) = 157;
                canvas(B(1):B(6),A(1):A(6),2) = 188;
                canvas(B(1):B(6),A(1):A(6),3) = 64;
                
                canvas(B(2):B(5),A(2):A(5),1) = 175;
                canvas(B(2):B(5),A(2):A(5),2) = 54;
                canvas(B(2):B(5),A(2):A(5),3) = 60;
               
                count = 1;
            end
            
            %Mark horizontal lines
            frame((B(1)-1):(B(1)+1),A(1):A(6),:) = 242;
            frame((B(2)-1):(B(2)+1),A(1):A(6),:) = 242;
            frame((B(3)-1):(B(3)+1),A(1):A(6),:) = 242;
            frame((B(4)-1):(B(4)+1),A(1):A(6),:) = 242;
            frame((B(5)-1):(B(5)+1),A(1):A(6),:) = 242;
            frame((B(6)-1):(B(6)+1),A(1):A(6),:) = 242;
%             frame((B(7)-1):(B(7)+1),A(1):A(8),:) = 242;
%             frame((B(8)-1):(B(8)+1),A(1):A(8),:) = 242;

            %Mark vertical lines
            frame(B(1):B(6),(A(1)-1):(A(1)+1),:) = 242;
            frame(B(1):B(6),(A(2)-1):(A(2)+1),:) = 242;
            frame(B(1):B(6),(A(3)-1):(A(3)+1),:) = 242;
            frame(B(1):B(6),(A(4)-1):(A(4)+1),:) = 242;
            frame(B(1):B(6),(A(5)-1):(A(5)+1),:) = 242;
            frame(B(1):B(6),(A(6)-1):(A(6)+1),:) = 242;
%             frame(B(1):B(8),(A(7)-1):(A(7)+1),:) = 242;
%             frame(B(1):B(8),(A(8)-1):(A(8)+1),:) = 242;
            
            %If this point is above the threshold likely hood, add it to
            %the list of points to mark in the video
            if (chance == true)
                n = round(coords(1)); 
                m = round(coords(2)); 
                %If the point is not too close to the edges
                if ((m <= (r-7))&&(n <= (c-7)))
                    if ((m >= 7) && (n >= 7))
                        %Add to in list if in the center
                        if (interactions(i,3) == 1)
                            in(in_count,:) = [m,n];
                            in_count = in_count + 1;
                            
                        %Add to out list if in the periphery    
                        else
                            out(out_count,:) = [m,n];
                            out_count = out_count + 1;
                            
                        end
                        %plot the center points in the ROI video as red
                        for j = 1:(in_count - 1)
                            frame((in(j,1)-3):(in(j,1)+3),(in(j,2)-3):(in(j,2)+3),1) = 175;
                            frame((in(j,1)-3):(in(j,1)+3),(in(j,2)-3):(in(j,2)+3),2) = 54;
                            frame((in(j,1)-3):(in(j,1)+3),(in(j,2)-3):(in(j,2)+3),3) = 60;
                        end
                        %plot the periphery points in the ROI video as
                        %green
                        for j = 1:(out_count -1)
                            frame((out(j,1)-3):(out(j,1)+3),(out(j,2)-3):(out(j,2)+3),1) = 157;
                            frame((out(j,1)-3):(out(j,1)+3),(out(j,2)-3):(out(j,2)+3),2) = 188;
                            frame((out(j,1)-3):(out(j,1)+3),(out(j,2)-3):(out(j,2)+3),3) = 64;
                        end
                    end
                end
                %Write to marked up frame to the new video file
                writeVideo(newv,frame);
            end
        %After the ROI has been made there are still many more frames to
        %add to the path image
        elseif (chance == true)
            n = round(coords(1)); 
            m = round(coords(2)); 
            if ((m <= (r-7))&&(n <= (c-7)))
                if ((m >= 7) && (n >= 7))
                    if (interactions(i,3) == 1)
                        in(in_count,:) = [m,n];
                        in_count = in_count + 1;

                    else
                        out(out_count,:) = [m,n];
                        out_count = out_count + 1;

                    end
                end
            end
        end 
    end
    
    %Close the new video file
    close(newv) 
    
    %create the path image if desired
    if (vid == 1)
        % canvas is a matrix of the path image. 
         for j = 1:length(in)
             canvas((in(j,1)-1):(in(j,1)+1),(in(j,2)-1):(in(j,2)+1),:) = 0;
         end

         for j = 1:length(out)
             canvas((out(j,1)-1):(out(j,1)+1),(out(j,2)-1):(out(j,2)+1),:) = 0;
         end
        %Convert the canvas matrix into an image 
        path = uint8(canvas);
    else
        path = 0;
    end
    
    %Find the speeds using distance and time
    speeds = peaks_per_quart(dist, time');
    interactions(:,4) = speeds;
    interactions(:,5) = dist;
    
    close(newv);
end

function [speeds] = peaks_per_quart(dist, behavTime)
    speeds = zeros(length(dist),1);
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
    for i = seconds
        rows = find(new_behavTime == i);
        total_dist = sum(dist(rows));
        time = (behavTime(rows(end)) - behavTime(rows(1)))/1000;
        if ((total_dist/time) < Inf)
            speeds(rows) = total_dist/time;
        end 
    end
    
end