function [AnTIP1, AnTIP2, path1, PLeng, STS, Values]=getTip1(Temp, dims, AnTIP1, AnTIP2, ii)

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

end %function