function [AnTIP7, AnTIP8] = ROTpoints(dims, Ang, Centroids, AnTIP1, AnTIP2)

CorAng=Ang-90; %counter clockwise is +
for ii=1:length(AnTIP1) %one is already user picked

New(ii,:)=AnTIP1(ii,:)+[dims(3)-1, dims(1)-1]; %this gets you back to values in ROT (cropped)
New2(ii,:)=AnTIP2(ii,:)+[dims(3)-1, dims(1)-1];

%this is the distance from center of ROT (origin)
New(ii,1)=New(ii,1)-101;
New(ii,2)=101-New(ii,2);

New2(ii,1)=New2(ii,1)-101;
New2(ii,2)=101-New2(ii,2);

%rotate
AnTIP3(ii,1)= New(ii,1)*cosd(CorAng(ii)) - New(ii,2)*sind(CorAng(ii));
AnTIP3(ii,2)= New(ii,2)*cosd(CorAng(ii)) + New(ii,1)*sind(CorAng(ii)); 

AnTIP4(ii,1)= New2(ii,1)*cosd(CorAng(ii)) - New2(ii,2)*sind(CorAng(ii));
AnTIP4(ii,2)= New2(ii,2)*cosd(CorAng(ii)) + New2(ii,1)*sind(CorAng(ii));

% convert to px above origin/center of BWcrop
AnTIP5(ii,1)= AnTIP3(ii,1)+101;
AnTIP5(ii,2)=101-AnTIP3(ii,2);

AnTIP6(ii,1)= AnTIP4(ii,1)+101;
AnTIP6(ii,2)=101-AnTIP4(ii,2);

%this should get you back to values in Mov
AnTIP7(ii,1) =round(AnTIP5(ii,1)  + (Centroids(ii,1)-101));
AnTIP7(ii,2) =round(AnTIP5(ii,2) + (Centroids(ii,2)-101));

AnTIP8(ii,1) =round(AnTIP6(ii,1)  + (Centroids(ii,1)-101));
AnTIP8(ii,2) =round(AnTIP6(ii,2) + (Centroids(ii,2)-101));

end

end

