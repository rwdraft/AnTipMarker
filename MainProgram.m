% This program allows semi-automated segmentation of ant and trail parameters:
% - centroid, estimated head points
% - body angle
% - antennae tips
% - trail pixels
% It also aligns the video frames
% Recommended resolution of images is 0.22 mm/pixel or higher and 30 fps 

%% Import the AVI file
if exist('Mov', 'var') >0 % if Mov already exists, skip uplaod.    
   % clear old variables
   clear MIP TH Centroids Areas Orientations aLength Heads Butts bodyAx P1 P2 Deleted Frames Ang ROT 
else
[f, hi, wi, Mov, PathName, FileName]=OpenMov();
end
%%
% Subtract background using Maximum Intensity Projection or no background
% using no background will simply invert the image
[MIP, Mov]=SubBG(Mov, f, wi, hi);
%
% Get centroida, areas, orientations
% Note: set to include areas above threshold > 50 px and < 2500 px in size: ie, the expected size of the ant. 
% it takes the largest area as the ant if multiple areas are found
% Adjust for different ant sizes and fields of view

[TH, Centroids, Areas, Orientations, aLength]=GetCentroids(Mov, f, 50, 2500);

% Get Heads and Butts 
% this section allows let you change the start frame to eliminate any ants
% still half in the holding chamber
%
[FirstFrame, Heads, Butts, bodyAx, P1, P2, f, Mov, Areas, Centroids, Orientations, DeletedFrames]=GetHandBs(Mov, Centroids, Areas, Orientations, f, aLength);
%%
% Align and Crop images 
% Ang = the angle (0 degrees is the horizontal right; angle increases CCW to 359.9)
% ROT - image sequence of cropped and aligned ant (aligned to vertical)
[Ang, ROT]= CropAndRotate(Mov, Orientations, Heads, Centroids);
%%
% Adjust Fine threshold for antenna tip tracking
% IMPORTANT: Make sure whole antenae are above thresheld
[TH]=AdjPrecise(ROT, f, TH, bodyAx);

%% Get Antennae Tips

% Define the viewing area and seed (starting point) within ROT (201x201 pixels)

% dims(1) = upper Y cutoff (pixel distance from the *top* of ROT frame
% dims(2) = lower Y cutoff
% dims(3) = X left cutoff: 50 pixels right of center of ROT (100)
% dims(4) = X right cutoff: 50 pixels right of center of ROT (100)
% dims(5) = seed X value: center of the new search area (51)
dims=[round(101-bodyAx*4);101;51;151;51];

% seed Y value: one bodyAx abouve bottom of the image (=Head Center Point)
dims(6)=dims(2)-dims(1)-round(bodyAx);

% set some boundaries where auto-marking would likely be wrong
TooFar=bodyAx*1.3; % reject tips > ~20 px away from previous frame's antenna tip
limit=round(dims(6)-(bodyAx-(bodyAx/2))); % pause and check if tip position is at ~ head level;

%this allows you to pick up where you left off
if exist('AnTIP1', 'var')
Show=0; %1= error flag to ask user input
else
ii=1;
Show=1; %1= error flag to ask user input
CorCount=0; % counts the number of human corrections made
AnTIP1(1,1:2)=0;
AnTIP2(1,1:2)=0;
end

Stop=0; %1 commands 'stopAndGet' function to break out and manually correct
Manual=1; % allows to switch into error checking mode which stops after each frame (default on)
d=figure('Position', [350 200 900 650]);

while ii<f+1 && Stop==0 

% take the viewing area within the rotated/aligned image using user defined threshold
Temp=imbinarize(ROT(dims(1):dims(2),dims(3):dims(4), ii), TH);    

% get tip  1
[AnTIP1, AnTIP2, path1, PLeng, STS, Values]=getTip1(Temp, dims, AnTIP1, AnTIP2, ii);

% get tip  2
[AnTIP1, AnTIP2, path2]=getTip2(path1, Temp, dims, AnTIP1, AnTIP2, STS, Values, TooFar, ii);

% display results

imshow(imfuse(ROT(dims(1):dims(2),dims(3):dims(4), ii), PLeng), 'InitialMagnification','fit');
title({'Esc key to EXIT, 0 to SKIP, M=Manual Mode';'F (or left click) to advance, Z to go back';'Spacebar (or right click) to FIX (Left Tip then Right Tip)'; 'R to increase threshold, L to lower threshold'}, 'FontSize', 16);
xlabel({['Frame =' num2str(ii) '  of ' num2str(f)  '     Manual Mode= ' num2str(Manual)]}, 'FontSize', 12); 
ylabel({['AnTIP1 X =' num2str(AnTIP1(ii,1))], ['AnTIP1 Y =' num2str(AnTIP1(ii,2))],'', ['AnTIP2 X =' num2str(AnTIP2(ii,1))], ['AnTIP2 Y =' num2str(AnTIP2(ii,2))],'', ['Limit=  ' num2str(limit)],'',['TH=  ' num2str(TH)]},'Rotation', 0, 'Position', [-7 50]); 

hold on
scatter(AnTIP1(ii,1),AnTIP1(ii,2),400,'o','MarkerEdgeColor','yellow', 'MarkerFaceColor','blue','LineWidth', 3);
scatter(AnTIP2(ii,1),AnTIP2(ii,2),400,'*','MarkerEdgeColor','white', 'MarkerFaceColor','white','LineWidth', 3);
hold off

% check for errors or flags
if Manual==1 || AnTIP1(ii,2)>=limit || AnTIP2(ii,2)>=limit || Show==1 % get user input
[TH, ii, AnTIP1, AnTIP2, CorCount, Stop, Show, Manual]=StopAndGet(Stop, ii, AnTIP1, AnTIP2, CorCount, Show, Manual, TH);
else
drawnow;    
ii=ii+1;
end

end %end while

close;

if ii>f
    ii=f;
else
    if length(AnTIP1)>ii %chop all vairables down to quit frame
    AnTIP1((ii+1):end, :)=[];
    AnTIP2((ii+1):end, :)=[];
    disp('deleted AnTIP points beyond quit frame');
    else
    end
end

% revert points back to position in Mov 

%clear any data beyond the quit frame of the movie
  Ang((ii+1):end)=[];
  Areas((ii+1):end)=[];
  Butts((ii+1):end, :)=[];
  Centroids((ii+1):end, :)=[];
  Heads((ii+1):end, :)=[];
  Orientations((ii+1):end)=[];
  P1((ii+1):end, :)=[];
  P2((ii+1):end, :)=[];
  ROT(:,:,(ii+1):end)=[];

clear AnT1Pos c Disty indy indy2 Manual n path1 PLeng PLeng0 PLeng2 PLeng3 Stop Show STS t Temp test Values x   
[AnTIP3, AnTIP4] = ROTpoints(dims, Ang, Centroids, AnTIP1, AnTIP2);
AnTIP3(find(AnTIP1(:,1)==0),1:2)=0; % replaces the 0-skip values
AnTIP4(find(AnTIP2(:,1)==0),1:2)=0; % replaces the 0-skip values
Ant_L=AnTIP3;
Ant_R=AnTIP4;  
%csvwrite(fullfile(PathName, [num2str(FileName) '_L_AnTIP.csv']), AnTIP3);
%csvwrite(fullfile(PathName, [num2str(FileName) '_R_AnTIP.csv']), AnTIP4);
save(fullfile(PathName, [num2str(FileName) '_AnTIPvars.mat']),'Ang','Ant_L', 'Ant_R','Areas','bodyAx','Butts','Heads', 'Centroids','CorCount','DeletedFrames','aLength','MIP','Orientations','P1','P2','TH', 'FirstFrame'); %Add 'IM'
clc

%% save Mov if you deleted frames/want to stop early
v = VideoWriter(fullfile(PathName, FileName),'Grayscale AVI');
open(v);
writeVideo(v,OldMov(:,:,((1+DeletedFrames):(ii))));
close(v);
