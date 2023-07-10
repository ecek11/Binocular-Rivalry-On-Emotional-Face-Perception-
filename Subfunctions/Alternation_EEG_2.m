function [T0, T_alternation,key_press_stored]=Alternation_EEG_2(EXPCONSTANTS,GaborBuffer,RadialBuffer,mode,ioObj,address)
%[gaborPatchHor,gaborPatchVer,finalTime, switch_time,switch_key,absolute_time,relative_key_switching_time, T_alternation,key_press_stored,finalDomTime,finalSupTime]=Alternation_EEG_2(EXPCONSTANTS,GaborBuffer,RadialBuffer,mode,ioObj,address)

% Use this function to calculate keys alternation time using a texture of gabor patches in a stereo
% displaying with horizontal-vertical movement.
% Inside this function we also creates the gabor patches useful for future
% work.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Inputs:
%       EXPCONSTANTS: structure containing with at least following fields:
%            EXPCONSTANTS.SCREENPOINTER: Integer (number that designates the window you just created)
%            EXPCONSTANTS.RADIUS_CIRCLE: Integer (radius of mean circle, pixels)
%            EXPCONSTANTS.SCREENRECT: Integer 1x2 (size of new window)
%            EXPCONSTANTS.ASPECT_RATIO: Float (in order to rescale images in stereoscopic
%                          view)
%            EXPCONSTANTS.BACKGROUNDCOLOR: Integer scalar or 1x3 [r g b] (specify the colour
%                   of the window background)
%
%            EXPCONSTANTS.IMAGE_TYPE_FIRST: Integer (First image mode that appears)
%
%            EXPCONSTANTS.GABOR_VELOCITY_x: Float, x-velocity of gabor patches
%            EXPCONSTANTS.GABOR_VELOCITY_y: Float, y-velocity of gabor patches
%            DRAWREGIONSIZE:Integer 1x2 (expected window size)
%
%            EXPCONSTANTS.FIXCROSSLONG: Integer (Fixation cross longitude, pixels)
%            EXPCONSTANTS.FIX_POSITION: Integer 1x1 (Fixation cross position)
%            EXPCONSTANTS.FIXCROSSWIDE: Integer (Fixation cross wide, pixels)
%            EXPCONSTANTS.FIXATION_COLOUR: Integer 1x3 [r g b] (Fixation cross colour, 0 to 255)
%            EXPCONSTANTS.FIXATION_CENTRE_B0: Integer 1x2 (Fixation center position)
%            EXPCONSTANTS.FIXATION_CENTRE_B1: Integer 1x2 (Fixation center position)
%            EXPCONSTANTS.FIXATION_CENTRE_FRAME_WIDTH: Integer (Fixation frame width, pixels)
%
%            EXPCONSTANTS.ALTERNATION_MAXTIME: Integer (specify alternance calculation duration, seconds)
%
%         Gabor properties required in EXPCONSTANTS:
%                 EXPCONSTANTS.GABOR_SPTFREQUENCY: Float (specify spatial frequency of gabor patches, in cycles per pixel)
%                 EXPCONSTANTS.GABOR_CONTRAST: Float (contrast of gabor patches, ranging from 0 to 1)
%                 EXPCONSTANTS.GABOR_SIGMA: Integer (standard deviation of the Gaussian window in pixels)
%                 EXPCONSTANTS.GABOR_TOTALSIZE: Integer NxN (gabor image size, N x N)
%                 EXPCONSTANTS.GABOR_BACKGROUND: Integer (gabor background color in gray scale, 0 to 255)
%                 EXPCONSTANTS.GABOR_BLOB: (true: apply gaussian blog, 0: do not apply gaussian blob)
%                 EXPCONSTANTS.GABOR_PHASE1_3: Float (specify gaborPatch1 and gaborPatch3 phase, in cycles, from 0 to 1)
%                 EXPCONSTANTS.GABOR_PHASE2_4: Float (specify gaborPatch2 and gaborPatch4 phase, in cycles, from 0 to 1)
%                 EXPCONSTANTS.GABOR_ORIENTATION1_2: Integer (specify gaborPatch1 and gaborPatch2 orientation in degrees)
%                 EXPCONSTANTS.GABOR_ORIENTATION3_4: Integer (specify gaborPatch1 and gaborPatch2 orientation in degrees)
%                 EXPCONSTANTS.GABOR_VELOCITY_x: Float, x-velocity of gabor patches
%                 EXPCONSTANTS.GABOR_VELOCITY_y: Float, y-velocity of gabor patches

%
% Outputs:
%         gaborPatch1: 2Nx2N matrix of Gabor patch (containing values scaled from 0 to 255)
%         gaborPatch2: 2Nx2N matrix of Gabor patch (containing values scaled from 0 to 255)
%         gaborPatch3: 2Nx2N matrix of Gabor patch (containing values scaled from 0 to 255)
%         gaborPatch4: 2Nx2N matrix of Gabor patch (containing values scaled from 0 to 255)
%         finalTime: Float (arithmetic mean)
%         key_times_stored: Array with all key times stored
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%GENERAL CONFIGURATION
AssertOpenGL;

%G-PATCHES CONSTANTS

wPtr = EXPCONSTANTS.SCREENPOINTER;
screenPointer=wPtr;
spatialFrequency=EXPCONSTANTS.GABOR_SPTFREQUENCY;
contrast = EXPCONSTANTS.GABOR_CONTRAST;
sigma = EXPCONSTANTS.GABOR_SIGMA;
TotalGsize = EXPCONSTANTS.GABOR_TOTALSIZE;
display = 0; %display=0, not display the result
background = EXPCONSTANTS.GABOR_BACKGROUND;
blob= EXPCONSTANTS.GABOR_BLOB;
phase=EXPCONSTANTS.GABOR_PHASE;
orientation_horizontal=EXPCONSTANTS.GABOR_ORIENTATION_HORIZONTAL;
orientation_vertical=EXPCONSTANTS.GABOR_ORIENTATION_VERTICAL;
% highContrastGabor=EXPCONSTANTS.GABOR_HIGH_CONTRAST;

%Buffer constants

% GaborBuffer=EXPCONSTANTS.BUFFER_GABOR;
% RadialBuffer=EXPCONSTANTS.BUFFER_RADIAL;

%KEY CONSTANTS
SkipKey=EXPCONSTANTS.SkipKey;
key_Radial=EXPCONSTANTS.key_Radial;
key_Gabor=EXPCONSTANTS.key_Gabor;
keyQuit = EXPCONSTANTS.keyQuit;
spacekey=EXPCONSTANTS.spacekey;

RestrictKeysForKbCheck([spacekey SkipKey key_Radial key_Gabor keyQuit]);
%FRAME DIMENSION CONSTANTS

Size=EXPCONSTANTS.RADIUS_CIRCLE;
Size2=EXPCONSTANTS.FIXCROSSLONG*2;
windowRect=EXPCONSTANTS.SCREENRECT;
xmax = RectWidth(windowRect)/2;
ymax = RectHeight(windowRect)/2;
Aspect_ratio= EXPCONSTANTS.ASPECT_RATIO;
text_r=[xmax ymax];

TR=[(text_r(1,1)-1*Size) (text_r(1,2)-0.7*Size/Aspect_ratio) (text_r(1,1)+1*Size) (text_r(1,2)+0.7*Size/Aspect_ratio)];
TR2=[text_r(1,1)-1*Size2 text_r(1,2)-0.7*Size2/Aspect_ratio text_r(1,1)+1*Size2 text_r(1,2)+0.7*Size2/Aspect_ratio];
TR2b=[TR2(1,1)-EXPCONSTANTS.FIXATION_CENTRE_FRAME_WIDTH TR2(1,2)-EXPCONSTANTS.FIXATION_CENTRE_FRAME_WIDTH TR2(1,3)+EXPCONSTANTS.FIXATION_CENTRE_FRAME_WIDTH TR2(1,4)+EXPCONSTANTS.FIXATION_CENTRE_FRAME_WIDTH];
TRback=[xmax-2*xmax ymax-2*0.7*xmax/Aspect_ratio xmax+2*xmax ymax+0.7*2*xmax/Aspect_ratio];
Width_back=round(2*xmax-Size+22);%+2*EXPCONSTANTS.DOT_FRAME_WIDTH);

[width, height]=Screen('WindowSize', wPtr);
increaseforConstantGabor=20;
texture_rectangle=[-EXPCONSTANTS.RADIUS_DOT-increaseforConstantGabor; -EXPCONSTANTS.RADIUS_DOT-increaseforConstantGabor; ...
    EXPCONSTANTS.RADIUS_DOT+increaseforConstantGabor; EXPCONSTANTS.RADIUS_DOT+increaseforConstantGabor];
texture_rectangle=texture_rectangle+0.5*[width; height; width; height];
texture_rectangleB0=texture_rectangle;
% texture_rectangleB1=texture_rectangle;

% FIXATION CROSS CONSTANTS

EXPCONSTANTS.FIX_POSITION=[-EXPCONSTANTS.FIXCROSSLONG,EXPCONSTANTS.FIXCROSSLONG,0,0; ...
    0,0,-EXPCONSTANTS.FIXCROSSLONG,EXPCONSTANTS.FIXCROSSLONG];
EXPCONSTANTS.FIX_POSITION=EXPCONSTANTS.FIX_POSITION+0.5*[width width width width; height height height height];

% GENERATION OF GABOR PATCHES
alphaBack=EXPCONSTANTS.GABOR_TEXTURE_BACK_ALPHA;
tgaborPatchHor = GenerateGaborPatch(spatialFrequency,orientation_horizontal, contrast, sigma, TotalGsize, phase, display,background,blob);
tgaborPatchVer = GenerateGaborPatch(spatialFrequency,orientation_vertical, contrast, sigma, TotalGsize, phase, display,background,blob);
% gaborPatchbiggercontrast = GenerateGaborPatch(spatialFrequency,orientation, highContrastGabor, sigma, TotalGsize, phase, display,background,blob);

gaborPatchHor(:,:,1)=tgaborPatchHor*EXPCONSTANTS.Red_Level/255;
gaborPatchHor(:,:,2:3)=0;


gaborPatchVer(:,:,2)=tgaborPatchVer*EXPCONSTANTS.Green_Level/255;
gaborPatchVer(:,:,[1 3])=0;

gaborTextureHorizontal=Screen('MakeTexture',wPtr,gaborPatchHor);
gaborTextureVertical=Screen('MakeTexture',wPtr,gaborPatchVer);

% Initially fill left- and right-eye image buffer with specified background color:
Screen('SelectStereoDrawBuffer', wPtr, 0);
Screen('FillRect', wPtr, EXPCONSTANTS.BACKGROUNDCOLOR);
Screen('SelectStereoDrawBuffer', wPtr, 1);
Screen('FillRect', wPtr, EXPCONSTANTS.BACKGROUNDCOLOR);

% Show cleared start screen:
Screen('Flip', wPtr);

% Set up alpha-blending for smooth (anti-aliased) drawing of dots:
Screen('BlendFunction', wPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');



%Dominant Stimuli Constants
blurop = CreateGLOperator(wPtr);
HsizeBlur = EXPCONSTANTS.RADIAL_BLUR_HSIZE;
sigmaBlur = EXPCONSTANTS.RADIAL_BLUR_SIGMA;
Add2DConvolutionToGLOperator(blurop, fspecial('gaussian',HsizeBlur ,sigmaBlur));
% Blurring application:
%Prepare radial:
% radialArray=EXPCONSTANTS.RADIAL_ARRAY;
% radialTexture=Screen('MakeTexture',wPtr,radialArray);
%Apply blurring:
% RadialBlurredTex = Screen('TransformTexture', radialTexture, blurop);

switch mode
    case 'training'
     EXPCONSTANTS.ALTERNATION_MAXTIME=EXPCONSTANTS.TRAINING_MAXTIME;   
end

%Draw the images to show
Screen('SelectStereoDrawBuffer', screenPointer,GaborBuffer); %Buffer 0
Screen('FillRect', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR);
Screen('DrawTextures', screenPointer,  gaborTextureHorizontal ,[] , texture_rectangleB0, [], [],alphaBack); %0.
%Screen('DrawTextures', win, gabortex, srcRect, dstRects, [], [], ALPHA);
%win: Monitor pointer
%gabortex: Textures
%srcRect: part of the texture to be drawn []: draw all the texture
%dstRects: where do we draw the texture
%ALPHA: Transparency of the textures (set to 0.5)
Screen('FrameOval', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR,TRback, Width_back);
Screen('FillOval', screenPointer, [50 50 50],TR2, EXPCONSTANTS.DOT_FRAME_WIDTH);
Screen('DrawLines',screenPointer,EXPCONSTANTS.FIX_POSITION,EXPCONSTANTS.FIXCROSSWIDE,EXPCONSTANTS.FIXATION_COLOUR,EXPCONSTANTS.FIXATION_CENTRE_B0');
Screen('FrameOval', screenPointer, EXPCONSTANTS.DOT_FRAME_COLOUR,TR,EXPCONSTANTS.DOT_FRAME_WIDTH);
Screen('FrameOval', screenPointer, EXPCONSTANTS.DOT_FRAME_COLOUR, TR2b,EXPCONSTANTS.FIXATION_CENTRE_FRAME_WIDTH)

Screen('SelectStereoDrawBuffer', screenPointer, RadialBuffer);%Buffer 1
Screen('FillRect', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR);
Screen('DrawTextures', screenPointer,  gaborTextureVertical ,[] , texture_rectangleB0, [], [],alphaBack); %0.
Screen('FrameOval', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR,TRback, Width_back);
Screen('FillOval', screenPointer, [50 50 50],TR2, EXPCONSTANTS.DOT_FRAME_WIDTH);
Screen('DrawLines',screenPointer,EXPCONSTANTS.FIX_POSITION,EXPCONSTANTS.FIXCROSSWIDE,EXPCONSTANTS.FIXATION_COLOUR,EXPCONSTANTS.FIXATION_CENTRE_B1');
Screen('FrameOval', screenPointer, EXPCONSTANTS.DOT_FRAME_COLOUR,TR, EXPCONSTANTS.DOT_FRAME_WIDTH);
Screen('FrameOval', screenPointer, EXPCONSTANTS.DOT_FRAME_COLOUR, TR2b,EXPCONSTANTS.FIXATION_CENTRE_FRAME_WIDTH)

Screen('DrawingFinished',screenPointer);
FlushEvents;
%Initialize time
T0=Screen('Flip', screenPointer);
% img1 = Screen('GetImage',screenPointer);
% imwrite(img1,'im1.png');
%Now wait until the participant presses any key
pressed=0;
key_prev=3;
while not(pressed)|(key_prev==3)
    [pressed, secs, keyCode]=KbCheck;
    key_prev= 3-2*(keyCode(key_Gabor))-(keyCode(key_Radial));
end

FlushEvents;

T_alternation(1)=secs;
key_press_stored(1)=key_prev;
exit_loop=0;
while not(exit_loop)
    
    alternation=1;
    finTime=0;
    iniTime=GetSecs();
    T_alternation=0;
    key_press_stored=0;
    key_prev=Inf;
    
    while (finTime<EXPCONSTANTS.ALTERNATION_MAXTIME)
        
        [~, secs, keyCode]=KbCheck;
        key_press= 3-2*(keyCode(key_Gabor))-(keyCode(key_Radial));
        FlushEvents;
        exit_loop=keyCode(SkipKey);
        quit = keyCode(keyQuit);    
        
        if key_press~=key_prev
            %EEG_code=(key_press+EXPCONSTANTS.Trigger);
            %0 both, 1 red, 2 green, 3 none
            EEG_code=EXPCONSTANTS.Triggers(key_press+1);
            %disp(num2str(EEG_code));
            io64(ioObj,address,EEG_code);
            %Clear the parallel port
            WaitSecs(0.01);
            io64(ioObj,address,0);
            key_prev=key_press; 
            T_alternation(alternation)=secs;
            key_press_stored(alternation)=key_press;
            alternation=alternation+1;
            %Make sure we always end after an alternation
            finTime=secs-iniTime;
        end
        
        % y= 3-2left-right :
        % y= 3-2*1-1=0 both
        % y= 3-2*1-0=1 red
        % y= 3-2*0-1=2 green
        % y= 3-2*0-0=3 none
        
        if quit
            Screen('CloseAll');
            ListenChar(1);
            error ('Experiment stopped by user pressing "quit key"');
            
        end
        if exit_loop
            save(['tmp_alt' datestr(now,'YYMMDDHHmm') '.mat'],'T_alternation','key_press_stored','T0');
            break;
        end
        
       
        
        
        
       
        
        
      
    end
    
    exit_loop=1;
    
end


% Last Flip:
 Screen('SelectStereoDrawBuffer', screenPointer,GaborBuffer); %Buffer 0
 Screen('FillRect', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR);
 Screen('SelectStereoDrawBuffer', screenPointer, RadialBuffer);%Buffer 1
 Screen('FillRect', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR);
%              
 Screen('Flip', wPtr);
Screen('Close',gaborTextureHorizontal);
Screen('Close',gaborTextureVertical);
WaitSecs(0.05);

end