% Subtract Bg/Invert and Extract the Background (Max intensity Proj)

function [MIP,Mov]=SubBG(Mov, f, wi, hi)

d = dialog('Position',[500 300 450 150],'Name','Subtract Background from Movie?');
   
     % Create push button
        btn1 = uicontrol('Parent',d, 'Position', [25 25 200 100], 'String', 'No Background Subtraction', 'Callback', @b1);
        function b1(btn1, callbackdata)
        delete(gcf); 
        button=1; 
        pause(0.1);
        end
  
        % Create push button
        btn2 = uicontrol('Parent',d, 'Position', [225 25 200 100], 'String', 'Max Intensity Projection (Recommended)', 'BackgroundColor',[0,1,0], 'Callback', @b2);       
        function b2(btn2, callbackdata)
        delete(gcf); 
        button=2; 
        pause(0.1);
        end
    
uiwait(d);

switch button
    case 2  
    MIP=max(Mov,[],3);
    
    otherwise
        disp('No BG Subtraction! Dont do this unless you already subtracted BG. It will cause errors');
        MIP=uint8(zeros(hi,wi,1));
        MIP(:,:,1)=255;
end

% delete background
for ii=1:f
Mov(:,:,ii)=(MIP-(Mov(:,:,ii)));  %creates a bg corrected and/or inverted movie
end

end