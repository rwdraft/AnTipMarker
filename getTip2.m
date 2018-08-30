function [AnTIP1, AnTIP2, path2]=getTip2(path1, Temp, dims, AnTIP1, AnTIP2, STS, Values, TooFar, ii)


[~, c]=find(path1>0); % get X coordinates along the path
AnT1Pos=mean(c); %get mean of path1 - to determine if right or left of head center

[~, indy]=sort(Values, 'descend'); %sort to find highest distance transform value
BestGuess=Values(indy(1)); % use this if all else fails.

% get LEFT anTIP function

if (ii==1 || AnTIP2(ii-1, 1)==0) && AnT1Pos < 51 % if no previous frame (or skipped) and 1st Tip was Left Tip 
% assign 2nd antenna after checking constraints
    for t=1:length(Values)
        % eliminate if it is on the extreme left, or at/below head point 
        if round(STS(t).Centroid(1))<=45 || round(STS(t).Centroid(2))>=dims(6)+1
           if length(find(Values>0)) >1 % don't delete if the last available value! The garbage will do!
           Values(t)=0; 
           else
           Values(t)=BestGuess;
           disp('The garbage will due')
           end
        else
        end
    end
elseif (ii==1 || AnTIP2(ii-1, 1)==0) && AnT1Pos >= 51 % if no previous frame (or skipped) and first Tips was Right Tip 
    % assign 2nd antenna after checking constraints
    for t=1:length(Values)
        % eliminate if it is on the extreme right, or at/below head point 
        if round(STS(t).Centroid(1))>=55 || round(STS(t).Centroid(2))>=dims(6)+1
           if length(find(Values>0)) >1 % don't delete if the last available value! The garbage will do!
           Values(t)=0; 
           else
           Values(t)=BestGuess;
           disp('The garbage will due')
           end
        else
        end
    end
elseif ii>1 && AnT1Pos < 51 
    % assign 2nd antenna after checking constraints
    for t=1:length(Values)
    Prox(t)=pdist2(AnTIP2(ii-1,:),STS(t).Centroid); % how close to previous right tip?
        % eliminate if it is TooFar, on the extreme left, or at/below head point 
        if Prox(t)>=TooFar || round(STS(t).Centroid(1))<=45 || round(STS(t).Centroid(2))>=dims(6)
           if length(find(Values>0)) >1 % don't delete if the last available value! The garbage will do!
           Values(t)=0; 
           else
           Values(t)=BestGuess;
           disp('The garbage will due')
           end
        else
        end
    end
else
    for t=1:length(Values)
    Prox(t)=pdist2(AnTIP1(ii-1,:),STS(t).Centroid); % how close to previous left tip?
        %eliminate if it is TooFar, on the extreme left, or at/below head point 
        if Prox(t)>=TooFar || round(STS(t).Centroid(1))>=55 || round(STS(t).Centroid(2))>=dims(6)
           if length(find(Values>0)) >1 % don't delete if the last available value! The garbage will do!
           Values(t)=0; 
           else
           Values(t)=BestGuess;
           disp('The garbage will due')
           end
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


end %function