% select a threshold level and get Centroids, Body Angles, and more

function [TH, Centroids, Areas, Orientations, aLength, BWanT]=GetCentroids(Mov, f, mini, maxi)
% this only used to get a centroid. Exact threshold not important

%create window
d=figure ('Position', [200 200 1000 800]);

% set initial conditions
ii=1; 
TH=graythresh(Mov(:,:,1));
val=TH;
Inc=0.1;
State='Crude'; 
PM=1; % Mode value (1=crude; 2=fine; 3=superfine)
stay = true; 

% display image and values
while stay

% make a binary image     
BWantT=imbinarize(Mov(:,:,ii), val); 

% display the binary image
ha = axes('Parent',d,'visible', 'off');
imshow(BWantT, [0,1], 'InitialMagnification','fit', 'Parent', ha);

% display value
str={['Threshold= ' num2str(val), '   Mode = ' num2str(State), '   Frame = ' num2str(ii)]};
t=title(str, 'FontSize', 15);


% Create push buttons for controls
    % text instructions
    tt=uicontrol('Style','text','Parent',d, 'horizontalAlignment', 'left','String', {'Lower threshold until ant body is just above threshold.'; '';'Legs and antenna should mostly be below threshold.'; '';'The blob gives you ant length and centroid.';'';'When your satisfied, press "set and exit"'},'Position', [20 400 100 300], 'FontSize', 12);

    % set and exit button
    btn1 = uicontrol('Parent',d, 'String', 'Set & Exit','Position', [20 350 100 50], 'BackgroundColor',[0,1,0], 'Callback', @b1);

    % Previous Frame button
    btn2 = uicontrol('Parent',d,'Position', [270 60 100 50], 'String', 'Previous Frame', 'Callback', @b2);
    
    % Next Frame button
    btn3 = uicontrol('Parent',d,'Position', [670 60 100 50], 'String', 'Next Frame', 'Callback', @b3);
     
    % Threshold increment adjuster: crude, fine, superfine
    btn10 = uicontrol('Parent',d,'Style', 'popupmenu','Position', [460 55 100 50], 'Value',PM,...
        'String', {'Crude', 'Fine' 'SuperFine'}, ...
       'Callback', @b10);  
   
    % Display static Txt
    uicontrol('Position',[430 45 170 30], 'String',{'Threshold Adjustment'});

    % Threshold controls (increase, decrease)
    btn7 = uicontrol('Parent',d,'Position', [430 20 60 30], 'String', {'<<', 'more detail'}, 'Callback', @b7);
    btn6 = uicontrol('Parent',d,'Position', [530 20 60 30], 'String', {'>>', 'more detail'}, 'Callback', @b6);
    
uiwait();
delete(t);
end


%% button functions
        % set and exit button
        function b1(btn1, callbackdata)
        stay = false;
        close(gcf);
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
    
        % Adjust threshold mode
        function b10(btn10, callbackdata)
            if btn10.Value==1 %crude
            Inc=0.1; % adjust in 0.1 increments
            State=btn10.String{1}; 
            PM=1; 
            uiresume();
           
            elseif btn10.Value==2 % fine
                Inc=0.01; % adjust in 0.01 increments
                State=btn10.String{2}; 
                PM=2;
                uiresume();
                
            else % superfine
                Inc=0.001; % adjust in 0.001 increments
                State=btn10.String{3}; 
                PM=3;
                uiresume(); 
            end
        end
    
        % decrease threshold used to make binary image
        function b6(btn6, callbackdata)
        if val<Inc % don't allow it to go negative
        else
            val=val-Inc; 
            TH=val; % set threshold level = user input
        end
        uiresume();
        end
    
        % increase threshold used to make binary image
        function b7(btn7, callbackdata)
        if val>0.9 % don't allow it to go over 1
        else
            val=val+Inc;
            TH=val; % set threshold level = user input
        end
        uiresume();
        end

%% Use user input to calculate ant parameters: centroid, body angle, area, and length information 
% This code runs after user exits the function

% Create variables
Centroids=zeros(f,2);
Areas=zeros(f,1);
Orientations=zeros(f,1);
Length=zeros(f,1);
j=waitbar(0,'1', 'Name','Calculating Centroid Data');

% loop through movie
for ii=1:f
waitbar(ii/f,j, sprintf(['Frame ' num2str(ii)])); %update wait bar every iteration

% use threshold value to make binaries
BWanT=imbinarize(Mov(:,:,ii), TH);
STATS2=regionprops(BWanT, 'Centroid', 'Area', 'Orientation','MajorAxisLength');

STATS2([STATS2.Area] > maxi | [STATS2.Area] < mini)=[]; %get rid of big and small objects

if isempty(STATS2) %if no centroid found, error
disp(['Error: Frame ', num2str(ii), ' found no ant centroid']);
continue
else
%find the largest area and assume that is the ant 
[Areas(ii,:), pos]=max([STATS2.Area]);    
Centroids(ii,:)=floor(STATS2(pos).Centroid); % round centroids to pixel positions
Orientations(ii,:)=STATS2(pos).Orientation; % record body angle
Length(ii,:)=STATS2(pos).MajorAxisLength; % record ~ length
end

end

aLength=floor(mean(Length)); % take mean length is ~ length of the ant
close(j); % close waitbar

end