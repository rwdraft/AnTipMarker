function [Ang, ROT] =CropAndRotate(Mov, Orientations, Heads, Centroids)

[hi, wi, f]=size(Mov);
inv=90; %this is the degrees to subtrack to get ants aligned to axis: 90 is vertical up, 270 is vertical down, 360 is horizontal right
j=waitbar(0,'1', 'Name','Aligning Images');

for ii=1:f
waitbar(ii/f,j, sprintf(['Frame ' num2str(ii)])); %update wait bar every iteration    
%100 px buffer around image to prevent problems when ant on boundary
if Centroids(ii,1)==0 % put a black frame for frames with no ant
    ROT(:,:,ii)=uint8(zeros(201,201));
else
    Frame=uint8(zeros(hi+200,wi+200));
    Frame(101:hi+100, 101:wi+100)=Mov(:,:,ii);
    BWcrop=(Frame(Centroids(ii,2):Centroids(ii,2)+200, Centroids(ii,1):Centroids(ii, 1)+200)); %crop to 201x201
end

% use orientation and head position to rotate image to align vertically
dx(ii)=Heads(ii,1)-Centroids(ii,1);
dy(ii)=Heads(ii,2)-Centroids(ii,2);

if ge(Orientations(ii), -45) && le(Orientations(ii), 45) % ant facing right or left (-45 to 45)
%------use X coords in this regime because Y coords are too similar
    if dx(ii) >0 && gt(Orientations(ii),0) % head facing NorthEast
        Ang(ii,1)=Orientations(ii);
    elseif  dx(ii) < 0 && gt(Orientations(ii),0) %head facing SouthWest
        Ang(ii,1)=(180+Orientations(ii));
    elseif dx(ii) >0 && le(Orientations(ii),0) %head facing SouthEast
        Ang(ii,1)=(360+Orientations(ii));
    elseif dx(ii) < 0 && le(Orientations(ii),0)% head facing NorthWest
        Ang(ii,1)=(180+Orientations(ii));
    end

else% ant facing up or down (45 to 90 an -45--90)
    if dy(ii) < 0 && gt(Orientations(ii),0) % head facing NorthEast
        Ang(ii,1)=Orientations(ii);
    elseif  dy(ii) > 0 && gt(Orientations(ii),0) %head facing SouthWest
        Ang(ii,1)=(180+Orientations(ii));
    elseif dy(ii) > 0 && le(Orientations(ii),0) %head facing SouthEast
        Ang(ii,1)=(360+Orientations(ii));
    elseif dy(ii) < 0 && le(Orientations(ii),0)% head facing NorthWest
        Ang(ii,1)=(180+Orientations(ii));
    end 
end

ROT(:,:,ii) = imrotate(BWcrop(:,:), inv-Ang(ii), 'bicubic', 'crop');

end
close(j);

end