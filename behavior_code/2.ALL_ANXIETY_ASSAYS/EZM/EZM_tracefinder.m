%% Values to Set when using xtrapts
clear

%Enter the columns of the DLCcoordinates.csv for each marker w/ likelihood
snout = 29:31;  
nose_bridge = 32:34;
head =35:37;  
neck=44:46;
bodypoint1=47:49;
centroid = 50:52;
bodypoint2=53:55;
tailbase=56:58;

%Set threshold DLC confidence for choice between snout and head tracking
thresh = 0.90;


%% Gather video names and locations for analysis
tic
p_folder = uigetdir('Y:\Luke\Behavior\');


logs = dir(fullfile(p_folder,'**','DLCcoordinates.csv'));

%%
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
addpath(genpath('Y:\Lab Software and Code\RhushStuff'));


[numFiles,~]=size(logs);
f = waitbar(0, 'Starting');
for i = 1:numFiles
   
    waitbar(i/numFiles, f, sprintf('Processing: %d %%', floor(100*i/numFiles)));
    
    s = regexp(logs(i).folder, '\', 'split');
  
    file_delim = strsplit(logs(i).folder, '\');
    
    [~,dsize]=size(file_delim);
    
    currentfile = file_delim(dsize);
    
    
    load(fullfile(logs(i).folder,'startframe.mat'));
     
    [NUM,~,~] = xlsread(fullfile(logs(i).folder,logs(i).name));
    
    mouse=NUM(:,[centroid,bodypoint1,bodypoint2,neck,tailbase]);
    
    mouse=mouse(startframe:end,:);
    
    [m,~]=size(mouse);
    
    xpos=zeros(m,1);
    ypos=zeros(m,1);
    
    for j=1:m
       
       m_frame=mouse(j,[1:2,4:5,7:8,10:11,13:14]);
       mt_frame=mouse(j,[3,6,9,12,15]); 
        
       idx=0;
       flag=1;
       for k=1:length(mt_frame)
           if mt_frame(k)>thresh && flag==1
              idx=k;
              flag=0;
           end
       end
       
       if idx>0
           xpos(j,1)= m_frame(2*idx-1);
           ypos(j,1)= m_frame(2*idx);
       end
       
       if idx==0
          rewind_flag=0;
          rewind_row=j-1;
          while (rewind_flag==0) && (rewind_row>1)
              mt_frame=mouse(rewind_row,[3,6,9,12,15]);
              B=(mt_frame>thresh);
              if any(B)
                  rewind_flag=1;
              end
              rewind_row=rewind_row-1;
          end
          
          if rewind_row>1
              rewind_row=rewind_row+1;
          end
          
           m_frame=mouse(rewind_row,[1:2,4:5,7:8,10:11,13:14]);
           mt_frame=mouse(rewind_row,[3,6,9,12,15]); 

           idx=0;
           flag=1;
           for k=1:length(mt_frame)
               if mt_frame(k)>thresh && flag==1
                  idx=k;
                  flag=0;
               end
           end

           if idx>0
               xpos(j,1)= m_frame(2*idx-1);
               ypos(j,1)= m_frame(2*idx);
           end
          
       end
       
    end
    
    
     
 
    
      %Make the plot 
     figure(i)
     plot(xpos,-ypos,'color','k')
     %axis([tl(1)-10,tr(1)+10,-10-bl(2),-tl(2)+10]);
     title(strcat(currentfile,' mouse position'))
     xlabel('x')
     ylabel('y')
     figname=strcat('_mouse_position','.jpg');
     hold off
    
    figpath=strcat(logs(i).folder,'\','_mouse_position.jpg');
    saveas(gcf,figpath);
    close(gcf);
    
end
close(f)