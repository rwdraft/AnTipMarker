
dims=[round(101-bodyAx*4);101;51;151;51];
% seed Y value: one bodyAx abouve bottom of the image (=Head Center Point)
dims(6)=dims(2)-dims(1)-round(bodyAx);
% set some boundaries where auto-marking would likely be wrong
TooFar=bodyAx*1.3; % pause and check if > ~20 px away from previous frame's antenna tip
limit=round(dims(6)-(bodyAx-(bodyAx/2))); % pause and check if tip position is at ~ head level;
ii=1;

d=figure('Position', [350 200 1000 650]);
ha = axes('Parent',d);

for ii=11:f
%these variable chage values each iteration; have to be deleted/set 0
clear indy* Values PL* Temp test STS path* putative* Prox

% take the viewing area within the rotated/aligned image using user defined threshold
Temp=imbinarize(ROT(dims(1):dims(2),dims(3):dims(4), ii), TH);

% get first anTIP function
PLeng = bwdistgeodesic(Temp(1:dims(6), :),dims(5), dims(6), 'quasi-euclidean'); % quasi-euclidean works 
PLeng(isinf(PLeng) | isnan(PLeng)) = 0; % set unconnected pixels (outside threshold) and subtreshold pixels = 0

test=imregionalmax(round(PLeng)); % find regional maxima in connected distances
%test=(bwmorph(test, 'bridge')); % combined any very nearby regional maxes;
%this is good but creates probs as centroid from bidge not always in temp

STS=regionprops(test, 'Centroid','PixelList'); % get seperate region max locations

for n=1:length(STS) %get distance transform value in PLeng - ie, how far each regionalmax is from seed
Values(n)=PLeng(STS(n).PixelList(1,2),STS(n).PixelList(1,1));
end
[~, indy]=sort(Values, 'descend'); %sort to find highest distance transform value
% see if any Values are very close to max distance (ie, 5 units)
putativeTips=find(Values(indy(1)) - Values < 5);
if length(putativeTips)==1
% if nothing is close, use highest distance
AnTIP1(ii,:)=round(STS(indy(1)).Centroid(1,:)); %index of highest val 
STS(indy(1))=[]; %remove from possible Tips
Values(indy(1))=[];
else
% if there are a couple points similar in distance, take the one with the
% lowest Y value (ie, most away from head point)
winner=1; % set first putativeTip as best (winner)
for li=2:length(putativeTips) % cycle through other possible Tips
if STS(putativeTips(li)).PixelList(1,2)< STS(putativeTips(li-1)).PixelList(1,2)
    winner=li;
else
end
end
AnTIP1(ii,:)=round(STS(putativeTips(winner)).Centroid(1,:)); %index of highest Y value
STS(putativeTips(winner))=[]; %remove from possible Tips
Values(putativeTips(winner))=[];
end

%
% make a path to highest value; use to guess whether L or R antenna
% This method is described in detail here at Steve's awesome MATLAB blog
% https://blogs.mathworks.com/steve/2011/11/01/exploring-shortest-paths-part-1/

PLeng0 = bwdistgeodesic(Temp(1:dims(6), :),dims(5), dims(6), 'quasi-euclidean'); % get distances from seed to all px
PLeng2 = bwdistgeodesic(Temp(1:dims(6), :), AnTIP1(ii,1), AnTIP1(ii,2), 'quasi-euclidean'); % get distances from tip to all pixels
PLeng3 = PLeng0+PLeng2; % add distances together to find the shortest path
PLeng3 = round(PLeng3  * 8) / 8; % a little rounding to reduce round off error
PLeng3(isnan(PLeng3)) = inf;  % remove any infinite values if present
path1 = imregionalmin(PLeng3); % regional min finds the shortest path


[~, c]=find(path1>0); % get X coordinates along the path
AnT1Pos=mean(c); %get mean of path1 - to determine if right or left of head center

% get LEFT anTIP function

if ii==1 && AnT1Pos < 51 % if no previous frame and 1st Tip was Left Tip 
% assign 2nd antenna after checking constraints
    for t=1:length(Values)
        % eliminate if it is on the extreme left, or at/below head point 
        if round(STS(t).Centroid(1))<=45 || round(STS(t).Centroid(2))>=dims(6)
           Values(t)=0;
        else
        end
    end
elseif ii==1 && AnT1Pos >= 51 % if no previous frame and first Tips was Right Tip 
    % assign 2nd antenna after checking constraints
    for t=1:length(Values)
        % eliminate if it is on the extreme right, or at/below head point 
        if round(STS(t).Centroid(1))>=55 || round(STS(t).Centroid(2))>=dims(6)
           Values(t)=0;
        else
        end
    end
elseif ii>1 && AnT1Pos < 51 
    % assign 2nd antenna after checking constraints
    for t=1:length(Values)
    Prox(t)=pdist2(AnTIP2(ii-1,:),STS(t).Centroid); % how close to previous right tip?
        % eliminate if it is TooFar, on the extreme left, or at/below head point 
        if Prox(t)>=TooFar || round(STS(t).Centroid(1))<=45 || round(STS(t).Centroid(2))>=dims(6)
           Values(t)=0;
        else
        end
    end
else
    for t=1:length(Values)
    Prox(t)=pdist2(AnTIP1(ii-1,:),STS(t).Centroid); % how close to previous left tip?
        % eliminate if it is TooFar, on the extreme left, or at/below head point 
        if Prox(t)>=TooFar || round(STS(t).Centroid(1))>=55 || round(STS(t).Centroid(2))>=dims(6)
           Values(t)=0; 
        else
        end
    end
end
STS(Values==0)=[]; % get rid of any points that are not TIPs
Values(Values==0)=[]; %Values(find(Values==0))=[];

[~, indy2]=sort(Values, 'descend'); %sort to find highest distance transform value
% see if any Values are very close to max distance (ie, 5 units)
putativeTips2=find(Values(indy2(1)) - Values < 5);
if length(putativeTips2) ==1
% if nothing is close, use highest distance
    if AnT1Pos < 51
    AnTIP2(ii,:)=round(STS(indy2(1)).Centroid(1,:)); %index of highest Y value to right
    else
    AnTIP2(ii,:)=AnTIP1(ii,:);
    AnTIP1(ii,:)=round(STS(indy2(1)).Centroid(1,:)); %index of highest Y value to left 
    end
else
    % if there are a couple points similar in distance, take the one with the
    % lowest Y value (ie, most away from head point)
    winner=1; % set first putativeTip as best (winner)
    for li=2:length(putativeTips2) % cycle through other possible Tips
        if STS(putativeTips2(li)).PixelList(1,2)< STS(putativeTips2(li-1)).PixelList(1,2)
            winner=li;
        else
        end
    end
    if AnT1Pos < 51
    AnTIP2(ii,:)=round(STS(putativeTips2(winner)).Centroid(1,:)); %index of highest Y value to right
    else
    AnTIP2(ii,:)=AnTIP1(ii,:);
    AnTIP1(ii,:)=round(STS(putativeTips2(winner)).Centroid(1,:)); %index of highest Y value to left 
    end
end

% make a path to highest value; use to guess whether L or R antenna
% This method is described in detail here at Steve's awesome MATLAB blog
% https://blogs.mathworks.com/steve/2011/11/01/exploring-shortest-paths-part-1/

PLeng4 = bwdistgeodesic(Temp(1:dims(6), :),dims(5), dims(6), 'quasi-euclidean'); % get distances from seed to all px
if AnT1Pos < 51
PLeng5 = bwdistgeodesic(Temp(1:dims(6), :), AnTIP2(ii,1), AnTIP2(ii,2), 'quasi-euclidean'); % get distances from tip to all pixels
else
PLeng5 = bwdistgeodesic(Temp(1:dims(6), :), AnTIP1(ii,1), AnTIP1(ii,2), 'quasi-euclidean'); % get distances from tip to all pixels
end
PLeng6 = PLeng4+PLeng5; % add distances together to find the shortest path
PLeng6 = round(PLeng6  * 8) / 8; % a little rounding to reduce round off error
PLeng6(isnan(PLeng6)) = inf;  % remove any infinite values if present
path2 = imregionalmin(PLeng6); % regional min finds the shortest path


% Display your stuff

paththin = bwmorph(path1, 'thin', inf);
paththin2 = bwmorph(path2, 'thin', inf);
P = false(size(test));
P = imoverlay(P, Temp(1:57,:), [1 1 1]);
P = imoverlay(P, path1, [.5 .5 .5]);
P = imoverlay(P, paththin, [0 1 0]);
P = imoverlay(P, paththin2, [0 0 1]);
P = imoverlay(P, test, [1 0 0]);
imshow(P, 'InitialMagnification', 1200)
str={['Frame = ' num2str(ii)]};
t=title(str, 'FontSize', 15);

waitforbuttonpress;
end
