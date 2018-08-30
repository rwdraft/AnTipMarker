% Adjust Precise Threshold 
% this threshold allows the program to find a path from the head to the tip
% of the antennae. As such, antennae must be above threshold.

function [TH]=AdjPrecise(ROT, f, TH, bodyAx)

%create window
d=figure ('Position', [400 200 1000 800]);

% set some initial conditions
ii=1; 
val=TH;
Inc=0.01;
State='Fine';
PM=2;
stay = true;

while stay

BWantT=im2bw(ROT(:,:,ii), val);
ha = axes('Parent',d,'visible', 'off');
imshow(imfuse(BWantT, ROT(:,:,ii)),'InitialMagnification','fit', 'Parent', ha);

xlim([101-bodyAx*4,101+bodyAx*4]);
ylim([101-(bodyAx*4),101+(bodyAx*4)]);

str={['Threshold= ' num2str(val), '   Mode = ' num2str(State), '   Frame = ' num2str(ii)]};
t=title(str, 'FontSize', 15);


% Create push buttons for controls
    % text instructions
    tt=uicontrol('Style','text','Parent',d, 'horizontalAlignment', 'left','String', {'Raise threshold until antennae are above threshold.'; '';'It is crucial that antennae (tip to head) are above threshold';'';'When your satisfied, press "set and exit"'},'Position', [20 400 100 300], 'FontSize', 12);

    % set and exit button
    btn1 = uicontrol('Parent',d, 'String', 'Set & Exit','Position', [20 450 100 50], 'BackgroundColor',[0,1,0], 'Callback', @b1);

    % Previous Frame button
    btn2 = uicontrol('Parent',d,'Position', [270 40 100 50], 'String', 'Previous Frame', 'Callback', @b2);
    
    % Next Frame button
    btn3 = uicontrol('Parent',d,'Position', [670 40 100 50], 'String', 'Next Frame', 'Callback', @b3);
     
    % Threshold increment adjuster: crude, fine, superfine
    btn10 = uicontrol('Parent',d,'Style', 'popupmenu','Position', [460 35 100 50], 'Value',PM,...
        'String', {'Crude', 'Fine' 'SuperFine'}, ...
       'Callback', @b10);  
   
    % Display static Txt
    uicontrol('Style','text','Position',[430 25 170 30], 'String',{'Threshold Adjustment'});

    % Threshold controls (increase, decrease)
    btn7 = uicontrol('Parent',d,'Position', [400 30 60 30], 'String', {'<<', 'more detail'}, 'Callback', @b7);
    btn6 = uicontrol('Parent',d,'Position', [570 30 60 30], 'String', {'>>', 'more detail'}, 'Callback', @b6);
    
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
end