% Select the AVI file and import

function [f, hi, wi, Mov, PathName, FileName]=OpenMov()

if ispc % set for PC
[FileName,PathName] = uigetfile('*.*', 'Slect the AVI File');
else % set for Mac
[FileName,PathName] = uigetfile('*.*', 'Slect the AVI File');
end

% Write the video to a variable
Obj= VideoReader(fullfile(PathName, FileName)); 
wi = Obj.Width;
hi = Obj.Height;
f=0;
estf=round(Obj.Duration*Obj.FrameRate);
Mov = zeros(hi,wi,'uint8');

% for RGB movies
if strcmp(Obj.VideoFormat, 'RGB24')
    j=waitbar(0,'1', 'Name','Importing Movie');
        while hasFrame(Obj)
        f = f+1;
        waitbar(f/estf,j, sprintf(['Frame ' num2str(f)]));
        Mov(:,:,f) = rgb2gray(readFrame(Obj)); 
        end
        
% for Grayscale movies      
else
    j=waitbar(0,'1', 'Name','Importing Movie');
        while hasFrame(Obj)
        f = f+1;
        waitbar(f/estf,j, sprintf(['Frame ' num2str(f)]));
        Mov(:,:,f) = readFrame(Obj); %for grayscale movies
        end
end

close(j);
end