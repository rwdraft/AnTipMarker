% select a threshold level and get Heads and Butts
% This is necessary to know which direction the ant is facing, and how to
% rotate the images for alignment

function [FirstFrame, Heads, Butts, bodyAx, P1, P2, f, Mov, Areas, Centroids, Orientations, DeletedFrames]=GetHandBs(Mov, Centroids, Areas, Orientations, f, aLength)

% set some initial conditions
ii=1; % start at frame 1
stay=true;

d=figure('Position',[400 200 800 800]);

while stay
  
% Ask user for Start Frame and Ant Head
% display the binary image
ha = axes('Parent',d,'visible', 'off');
hold on
imshow(Mov(:,:,ii), [0,200], 'InitialMagnification','fit', 'Parent', ha)
xlim([Centroids(ii,1)-aLength, Centroids(ii,1)+aLength])
ylim([Centroids(ii,2)-aLength, Centroids(ii,2)+aLength])

scatter(Centroids(ii,1),Centroids(ii,2),400,'o','MarkerEdgeColor','yellow', 'MarkerFaceColor','blue','LineWidth', 3);
t=title({'Set the first frame then Get Head Center Point'; ['Frame= ', num2str(ii), ' will be the First Frame']}, 'FontSize', 20);
hold off

% Create push buttons for controls
    % Ask User to Get Head Position
    btn1 = uicontrol('String', 'Get Head Point','Position', [5 500 100 100], 'BackgroundColor',[0,1,0],'Callback', @b1);

    % Previous Frame
    btn2 = uicontrol('Position', [130 30 100 50], 'String', 'Previous Frame', 'Callback', @b2);
    
    % Next Frame
    btn3 = uicontrol('Position', [570 30 100 50], 'String', 'Next Frame', 'Callback', @b3);
     
uiwait();
delete(t);
end

%% button functions

%user gets head point
  function b1(btn1, callbackdata)
        [Head(1,1), Head(1,2)] = ginputc(1, 'Color', 'r'); 
        Head=round(Head); % round to nearest pixel
        stay = false; % close things up
        close(gcf);
        
        if ii==1 % if first frame has changed, update data 
        else
        Mov(:,:,1:(ii-1))=[]; % remove unwanted Movie frames
        f=size(Mov,3); % update total frames
        Centroids(1:(ii-1),:)=[]; % remove unwanted Centroid frames
        Areas(1:(ii-1),:)=[]; % remove unwanted area frames
        Orientations(1:(ii-1),:)=[]; % remove unwanted angle frames
        end
        DeletedFrames=ii-1;
        FirstFrame=Mov(:,:,1+DeletedFrames); % keep first frame
  end
    
    % previous frame
    function b2(btn2, callbackdata)
        if ii==1 % can't go beyond first frame
        else
          ii=ii-1;
        end
     uiresume();
     end
    
        % next frame
    function b3(btn3, callbackdata)
        if ii==f % can't go beyond last frame
        else
          ii=ii+1;
        end
    uiresume();
    end

close;

%% Use user input to identify heads and butts
% This code runs after user exits the function

bodyAx=round(pdist2(Head(1,:), Centroids(1,:))); % get distance of user defined head to centroid

% use angles to get end points one body axis away from the centroids

YDis=-(sind(Orientations)*bodyAx);
XDis=(cosd(Orientations)*bodyAx);

% calculate location of one end point
P1(:,1)=Centroids(:,1)-round(XDis(:));
P1(:,2)=Centroids(:,2)-round(YDis(:));

% calculate location of the other end point
P2(:,1)=Centroids(:,1)+round(XDis(:));
P2(:,2)=Centroids(:,2)+round(YDis(:));

clear XDis YDis temp1 temp2 

% assign end points (P1 and P2) as heads or butts using first head position
 
% get distance of end point to the head
D1=pdist2([Head(1,1) Head(1,2)], [P1(1,1) P1(1,2)]); 
D2=pdist2([Head(1,1) Head(1,2)], [P2(1,1) P2(1,2)]); 

% assign whichever is closer as the head; the other as the butt
if ge(D2, D1)
Heads(1,1:2)=P1(1,1:2);
Butts(1,1:2)=P2(1,1:2);

else
Heads(1,1:2)=P2(1,1:2);
Butts(1,1:2)=P1(1,1:2);  

end

% now use first head to get all heads and butts

for ii=1:f-1

%this code ensures that if the ant moves very fast, the butt isn't closer than the
%previous head

% if centroid moved more than half a body axes between frames, 
if pdist2([Centroids(ii,1) Centroids(ii,2)], [Centroids(ii+1,1) Centroids(ii+1,2)]) >= bodyAx/2
    
% Adjust the distance of the head of current frame by the amount moved
chX= Centroids(ii+1,1)-Centroids(ii, 1);
chY= Centroids(ii+1,2)-Centroids(ii, 2);

D1=pdist2([(Heads(ii,1)+chX) (Heads(ii,2)+chY)], [P1(ii+1,1) P1(ii+1,2)]); 
D2=pdist2([(Heads(ii,1)+chX) (Heads(ii,2)+chY)], [P2(ii+1,1) P2(ii+1,2)]); 

% assign whichever is closer as the head; the other as the butt
if ge(D2, D1)
Heads(ii+1,1:2)=P1(ii+1,1:2);
Butts(ii+1,1:2)=P2(ii+1,1:2);
else
Heads(ii+1,1:2)=P2(ii+1,1:2);
Butts(ii+1,1:2)=P1(ii+1,1:2);  
end
    
else
% find the distance from head of current frame to next P-point
D1=pdist2([Heads(ii,1) Heads(ii,2)], [P1(ii+1,1) P1(ii+1,2)]); 
D2=pdist2([Heads(ii,1) Heads(ii,2)], [P2(ii+1,1) P2(ii+1,2)]); 

% assign whichever is closer as the head; the other as the butt    
if ge(D2, D1)
Heads(ii+1,1:2)=P1(ii+1,1:2);
Butts(ii+1,1:2)=P2(ii+1,1:2);
else
Heads(ii+1,1:2)=P2(ii+1,1:2);
Butts(ii+1,1:2)=P1(ii+1,1:2);  
end
    
end

end

end