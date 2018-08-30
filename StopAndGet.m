% Halt Tracking and Get User Feedback

function [TH, ii, AnTIP1, AnTIP2, CorCount, Stop, Show, Manual]=StopAndGet(Stop, ii, AnTIP1, AnTIP2, CorCount, Show, Manual, TH)
set(gcf,'Color',[0.9 0.8 0.8]); %make it pink to indicate a stop

g=waitforbuttonpress(); %wait for user input
k=get(gcf,'CurrentCharacter');
j=get(gcf,'SelectionType');
set(gcf,'Color',[0.8 0.8 0.8]); %back to grey

if g==0 %mouse click
    switch j
        case 'alt' % right click - get tips
        Show=0;
        [temp1,temp2] = ginputc(2, 'Color', 'r', 'ShowPoints', true);
        disp(['Correction at ' num2str(ii)]);
        CorCount=CorCount+1;
        AnTIP1(ii,1)=round(temp1(1));
        AnTIP1(ii,2)=round(temp2(1));
        AnTIP2(ii,1)=round(temp1(2));
        AnTIP2(ii,2)=round(temp2(2));  
        ii=ii+1;  
        otherwise % single click, double click --> advance
        Show=0;
        ii=ii+1;
    end
else %keyboard click
 switch k
    case 'z' % z goes back 
        Show=1;
        if ii>=2    
        ii=ii-1;   
        else
        disp('At Frame 1')
        end
   case '0' % mark it a zero if unreadable
        Show=0;
        AnTIP1(ii,:)=0;
        AnTIP2(ii,:)=0;
        ii=ii+1;
    case 27 % escape to break out
        Show=0;
        Stop=1;
    case 32 % space bar to fix 
        Show=0;
        [temp1,temp2] = ginputc(2, 'Color', 'r', 'ShowPoints', true);
        disp(['Correction at ' num2str(ii)]);
        CorCount=CorCount+1;
        AnTIP1(ii,1)=round(temp1(1));
        AnTIP1(ii,2)=round(temp2(1));
        AnTIP2(ii,1)=round(temp1(2));
        AnTIP2(ii,2)=round(temp2(2));  
        ii=ii+1;
    case 'f' % move forward and stop
       Show=1;
       ii=ii+1;
     case 'm' % switch to manual mode (Always stop for inspection)
         Manual = 1-Manual;  
         set(gcf,'Color',[0.8 0.9 0.8]);
         pause(0.1);
         set(gcf,'Color',[0.8 0.8 0.8]);
         pause(0.1);
         set(gcf,'Color',[0.8 0.9 0.8]);
         pause(0.1);
         set(gcf,'Color',[0.8 0.8 0.8]);
     case 'l' %decrease gain
            if TH>0.99 
            disp('Minimum threshold reached');
            else
             TH=TH+0.01;
             Show=1;
            end
     case 'r' % increase gain
            if TH<0.01
             disp('Maximum threshold researched');
            else
             TH=TH-0.01;
             Show=1;
            end
     otherwise
         set(gcf,'Color',[1 0 0]);
         pause(0.1);
         set(gcf,'Color',[0.8 0.8 0.8]);
         disp('Error. Try again : press enter to continue, z to go back, esc to cancel or space to fix');
 end
end

end

