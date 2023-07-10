function [ centerLeft,centerRight, Aspect_ratio, texture_rectangle]=CalibrateMirrors2(windowPtr,EXPCONSTANTS)

% Open double-buffered onscreen window with the requested stereo mode and
% display an image in each buffer

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Inputs:
%       windowPtr: Integer (number that designates the window that you want to use)
%       EXPCONSTANTS: structure containing with at least following fields:
%           STEREOMODE: Integer, Type of stereo display algorithm to use: 
%                 - 0: Monoscopic viewing 
%                 - 1: Stereo output
%                 - 2: Left view compressed into top half, right view into bottom half
%                 - 3: Left view compressed into bottom half, right view compressed into top half
%                 - 4: Left view is shown in left half, right view is shown in right half or the display
%                 - 5: does the opposite of 4 (cross-fusion)
%           CALIBRATE_BACK_COLOUR: Integer (window background colour in grey scale) 
%                                    or Integer 1x3 (window background colour with RGB indexes)  
%           CALIBRATE_IMAGE: String (specifies image that you'll use in the
%                                   calibration
%           RADIUS_CIRCLE: Integer (radius of mean circle, pixels)
%           RADIUS_JITTER: Integer 1xn (jitter to mean circle, pixels)
%           CALIBRATE_IMAGE_LEFT_COLOUR: Integer 1x3 (Image colour in Left Buffer with RGB indexes)  
%           CALIBRATE_FRAME_COLOUR: Integer (frame colour in grey scale) 
%                                    or Integer 1x3 (frame colour with RGB indexes)
%           CALIBRATE_FRAME_WIDHT: Integer (frame widht, pixels)
%           CALIBRATE_IMAGE_RIGHT_COLOUR: Integer 1x3 (Image colour in Right Buffer with RGB indexes)  
%          
% Outputs:
%       centerLeft: Integer 2x1 (return the value of left buffer center)
%       centerRight: Integer 2x1 (return the value of right buffer center)
%       Aspect_ratio: Float (in order to rescale images in stereoscopic
%                         view)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%GENERAL CONFIGURATION
AssertOpenGL;

stereoMode=EXPCONSTANTS.STEREOMODE;
windowRect=Screen('Rect',windowPtr);
RestrictKeysForKbCheck([32 81 82]); %keys check restriction
Size=EXPCONSTANTS.RADIUS_CIRCLE; %radius circle size
maxTime=EXPCONSTANTS.CALIBRATE_MAXTIME; %Duration of image displaying

%Fixation cross constants
width=windowRect(3);
height=windowRect(4);

EXPCONSTANTS.FIX_POSITION=[-EXPCONSTANTS.FIXCROSSLONG,EXPCONSTANTS.FIXCROSSLONG,0,0;0,0,-EXPCONSTANTS.FIXCROSSLONG,EXPCONSTANTS.FIXCROSSLONG];
EXPCONSTANTS.FIX_POSITION=EXPCONSTANTS.FIX_POSITION+0.5*[width width width width; height height height height];

%STIMULUS SETTINGS: HERE GO YOUR SETTINGS

xmax = RectWidth(windowRect)/2;
ymax = RectHeight(windowRect)/2;


% Resize images in order not to deform them!
if stereoMode<3
    Aspect_ratio=RectWidth(windowRect)/(RectHeight(windowRect));
else
   Aspect_ratio=RectWidth(windowRect)/(RectHeight(windowRect));
end

%%%%%%%%%%%%%%% END OF YOUR SETTINGS


%%%%%%%%%%%%%%% PRESENTATION STARTS

% Initially fill left- and right-eye image buffer with black background
% color:
Screen('SelectStereoDrawBuffer', windowPtr, 0);
Screen('FillRect', windowPtr, EXPCONSTANTS.CALIBRATE_BACK_COLOUR);
Screen('SelectStereoDrawBuffer', windowPtr, 1);
Screen('FillRect', windowPtr, EXPCONSTANTS.CALIBRATE_BACK_COLOUR);

% Show cleared start screen:
Screen('Flip', windowPtr);
WaitSecs(1);

% Set up alpha-blending for smooth (anti-aliased) drawing of dots:
Screen('BlendFunction', windowPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');


% %%% SETTINGS FOR STIMULUS
p=imread([pwd '\' EXPCONSTANTS.CALIBRATE_IMAGE ]  );    
text_index=Screen('Maketexture',windowPtr,p);
text_r=[xmax ymax];
%text_r=0;
%Change texture dimension
if stereoMode<4
texture_rectangle=[text_r(1,1)-Size text_r(1,2)-Size/Aspect_ratio text_r(1,1)+Size text_r(1,2)+Size/Aspect_ratio];
else
texture_rectangle=[text_r(1,1)-1*Size text_r(1,2)-1*Size*Aspect_ratio text_r(1,1)+1*Size text_r(1,2)+1*Size*Aspect_ratio];
end


exit_loop=0;
while not(exit_loop)
%Run until 'q' or 'space' is pressed  

    [~, ~, keyCode]=KbCheck;
    
    exit_loop=keyCode(32);    
    quit = keyCode(81);    % 'key q' 
    start_key= keyCode(82); % 'key r'
    
    if quit
            Screen('CloseAll');
            PsychPortAudio('Close');
            ListenChar(0);
            error ('Experiment stopped by user pressing "quit key"');
    end
    
    inTime=GetSecs();
    outTime=0;

    while ((start_key) && (outTime<maxTime))
    
    %DRAWING COMMANDS 
    % Select left-eye image buffer for drawing:
    %Screen('SelectStereoDrawBuffer', windowPtr, 0);
    % Draw left stim:
    TR=texture_rectangle;
    Screen('DrawTexture',windowPtr,text_index,[],TR-[xmax/2 0 xmax/2 0],[],[],[],EXPCONSTANTS.CALIBRATE_IMAGE_LEFT_COLOUR); 
    %Draw also a frame on the texture
    Screen('FrameRect', windowPtr ,EXPCONSTANTS.CALIBRATE_FRAME_COLOUR, TR-[xmax/2 0 xmax/2 0], EXPCONSTANTS.CALIBRATE_FRAME_WIDTH);
    Screen('DrawLines',windowPtr,EXPCONSTANTS.FIX_POSITION-[xmax/2 xmax/2 xmax/2 xmax/2;0 0 0 0],EXPCONSTANTS.FIXCROSSWIDE,EXPCONSTANTS.FIXATION_COLOUR,[0 0]);
    % Select right-eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', windowPtr, 1);
    
    % Draw right stim:
    TR=texture_rectangle;
    Screen('DrawTexture',windowPtr,text_index,[],TR+[xmax/2 0 xmax/2 0],[],[],[],EXPCONSTANTS.CALIBRATE_IMAGE_RIGHT_COLOUR); 
    Screen('FrameRect', windowPtr ,EXPCONSTANTS.CALIBRATE_FRAME_COLOUR, TR+[xmax/2 0 xmax/2 0], EXPCONSTANTS.CALIBRATE_FRAME_WIDTH);
    Screen('DrawLines',windowPtr,EXPCONSTANTS.FIX_POSITION+[xmax/2 xmax/2 xmax/2 xmax/2;0 0 0 0],EXPCONSTANTS.FIXCROSSWIDE,[255 0 0],[0 0]);
    Screen('DrawingFinished', windowPtr);
    Screen('Flip', windowPtr);
        
    [~, ~, keyCode]=KbCheck;
   
    
    exit_loop=keyCode(32);
    quit = keyCode(81);    % 'key q' 
    
     if quit
            Screen('CloseAll');
            ListenChar(1);
            error ('STOP');
     end

       
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
     auxTime=GetSecs;
     outTime=auxTime-inTime;
     
     if outTime>maxTime   %To put again the screen in grey

         Screen('SelectStereoDrawBuffer', windowPtr, 0); 
         Screen('FillRect', windowPtr, EXPCONSTANTS.BACKGROUNDCOLOR);
         Screen('SelectStereoDrawBuffer', windowPtr, 1); 
         Screen('FillRect', windowPtr, EXPCONSTANTS.BACKGROUNDCOLOR);
         Screen('Flip', windowPtr);

     end
     
    end
    

end
%Centers of each buffer
centerLeft=[0 ;0];
centerRight=[0 ;0];

% Last Flip:
Screen('Flip', windowPtr);
Screen('Close',text_index);
end