function Training(EXPCONSTANTS,bufferGabor,bufferRadial)

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
orientation=EXPCONSTANTS.GABOR_ORIENTATION;
highContrastGabor=EXPCONSTANTS.GABOR_HIGH_CONTRAST;

% Buffer constants
EXPCONSTANTS.BUFFER_GABOR = bufferGabor;
EXPCONSTANTS.BUFFER_RADIAL = bufferRadial;

%KEY CONSTANTS
%KEY CONSTANTS
SkipKey=KbName('w'); %code is 87,
key_Radial=KbName('d'); %code is 68,
key_Gabor=KbName('x'); %code is 88,
quitKey = KbName('q'); %code is 81

RestrictKeysForKbCheck([32 81 87 88 68 ]);

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
gaborPatch = GenerateGaborPatch(spatialFrequency,orientation, contrast, sigma, TotalGsize, phase, display,background,blob);
gaborPatchbiggercontrast = GenerateGaborPatch(spatialFrequency,orientation, highContrastGabor, sigma, TotalGsize, phase, display,background,blob);

gaborTexture=Screen('MakeTexture',wPtr,gaborPatch);


% Initially fill left- and right-eye image buffer with specified background color:
Screen('SelectStereoDrawBuffer', wPtr, 0);
Screen('FillRect', wPtr, EXPCONSTANTS.BACKGROUNDCOLOR);
Screen('SelectStereoDrawBuffer', wPtr, 1);
Screen('FillRect', wPtr, EXPCONSTANTS.BACKGROUNDCOLOR);

% Show cleared start screen:
Screen('Flip', wPtr);

% Set up alpha-blending for smooth (anti-aliased) drawing of dots:
Screen('BlendFunction', wPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');



%Dominant Stimuli Creation and constants
wedges=EXPCONSTANTS.DOMSTIM_WEDGES;
rings=EXPCONSTANTS.DOMSTIM_RINGS;
DarkColour= EXPCONSTANTS.DOMSTIM_DARKER_COLOUR;
LightColour=EXPCONSTANTS.DOMSTIM_LIGHTER_COLOUR;

% linesInc=10; %to avoid flash problem
angle=360/wedges;
sizeRing=Size/rings;
S_TR0=0.5*[width; height; width; height];
S_TR1=[S_TR0(1)-sizeRing  S_TR0(2)-sizeRing S_TR0(3)+sizeRing S_TR0(4)+sizeRing];
S_TR2=[S_TR1(1)-sizeRing  S_TR1(2)-sizeRing S_TR1(3)+sizeRing S_TR1(4)+sizeRing];
S_TR3=[S_TR2(1)-sizeRing  S_TR2(2)-sizeRing S_TR2(3)+sizeRing S_TR2(4)+sizeRing];
S_TR4=[S_TR3(1)-sizeRing  S_TR3(2)-sizeRing S_TR3(3)+sizeRing S_TR3(4)+sizeRing];
S_TR5=[S_TR4(1)-sizeRing  S_TR4(2)-sizeRing S_TR4(3)+sizeRing S_TR4(4)+sizeRing];
S_TR6=[S_TR5(1)-sizeRing  S_TR5(2)-sizeRing S_TR5(3)+sizeRing S_TR5(4)+sizeRing];
S_dif=TR-S_TR6;
S_TR6=[S_TR6(1)+S_dif(2) S_TR6(2)+S_dif(2) S_TR6(3)+S_dif(4) S_TR6(4)+S_dif(4)];
lastRingSize=S_dif(4)+sizeRing;
%Flip only with Dartboard (without smoothing):
Screen('SelectStereoDrawBuffer', screenPointer, 0);
Screen('FillRect', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR);
%DartboardStimuli
arcCount=0;
startAngle=0;
while arcCount~=(wedges+1)
    
    Screen('FrameArc',screenPointer, DarkColour ,S_TR1,startAngle,angle, sizeRing);
    Screen('FrameArc',screenPointer, LightColour,S_TR2,startAngle,angle, sizeRing);
    Screen('FrameArc',screenPointer, DarkColour ,S_TR3,startAngle,angle, sizeRing);
    Screen('FrameArc',screenPointer, LightColour,S_TR4,startAngle,angle, sizeRing);
    Screen('FrameArc',screenPointer, DarkColour ,S_TR5,startAngle,angle, sizeRing);
    Screen('FrameArc',screenPointer, LightColour,S_TR6,startAngle,angle, lastRingSize);
    
    Screen('FrameArc',screenPointer, LightColour,S_TR1,startAngle+angle,angle, sizeRing);
    Screen('FrameArc',screenPointer, DarkColour,S_TR2,startAngle+angle,angle, sizeRing);
    Screen('FrameArc',screenPointer, LightColour,S_TR3,startAngle+angle,angle, sizeRing);
    Screen('FrameArc',screenPointer, DarkColour,S_TR4,startAngle+angle,angle, sizeRing);
    Screen('FrameArc',screenPointer, LightColour,S_TR5,startAngle+angle,angle, sizeRing);
    Screen('FrameArc',screenPointer, DarkColour,S_TR6,startAngle+angle,angle, lastRingSize);
    
    startAngle=startAngle+angle*2;
    arcCount=arcCount+1;
    
end

% Screen('FrameOval', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR,TRback, Width_back);
% Screen('FillOval', screenPointer, [50 50 50],TR2, EXPCONSTANTS.DOT_FRAME_WIDTH);
% Screen('DrawLines',screenPointer,EXPCONSTANTS.FIX_POSITION,EXPCONSTANTS.FIXCROSSWIDE,EXPCONSTANTS.FIXATION_COLOUR,EXPCONSTANTS.FIXATION_CENTRE_B1');
% Screen('FrameOval', screenPointer, EXPCONSTANTS.DOT_FRAME_COLOUR,TR, EXPCONSTANTS.DOT_FRAME_WIDTH);
% Screen('FrameOval', screenPointer, EXPCONSTANTS.DOT_FRAME_COLOUR, TR2b,EXPCONSTANTS.FIXATION_CENTRE_FRAME_WIDTH)

Screen('DrawingFinished',screenPointer);

Screen('Flip', screenPointer);


auxRadialArray = Screen('GetImage',screenPointer, TR);
Screen('Flip', screenPointer);
radialArray=auxRadialArray(:,:,1);
radialTexture=Screen('MakeTexture',wPtr,radialArray);
blurop = CreateGLOperator(wPtr);


HsizeBlur = EXPCONSTANTS.RADIAL_BLUR_HSIZE;
sigmaBlur = EXPCONSTANTS.RADIAL_BLUR_SIGMA;
Add2DConvolutionToGLOperator(blurop, fspecial('gaussian',HsizeBlur ,sigmaBlur));
% Application:
RadialBlurredTex = Screen('TransformTexture', radialTexture, blurop);



exit_loop=0;
while not(exit_loop)
    
    alternation=2;
    finTime=0;
    iniTime=GetSecs();
    T_alternation=0;
    key_press_stored=0;
    
    
    while (finTime<EXPCONSTANTS.TRAINING_MAXTIME)
        
        [~, secs, keyCode]=KbCheck;
        key_press= 3-2*(keyCode(key_Radial))-(keyCode(key_Gabor));
        FlushEvents;
        
        exit_loop=keyCode(SkipKey); %'w' key
        quit = keyCode(quitKey);    % 'q' key
        
        % y= 3-2left-right :
        % y= 3-2*1-1=0 both
        % y= 3-2*1-0=1 left
        % y= 3-2*0-1=2 right
        
        if quit
            Screen('CloseAll');
            ListenChar(1);
            error ('Experiment stopped by user pressing "quit key"');
            
        end
        if exit_loop
            fprintf('\n Function skipped by user pressing "skip key" \n');
            break;
        end
        
        Screen('SelectStereoDrawBuffer', screenPointer,EXPCONSTANTS.BUFFER_GABOR); %Buffer 0
        Screen('FillRect', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR);
        Screen('DrawTextures', screenPointer,  gaborTexture ,[] , texture_rectangleB0, [], [],alphaBack); %0.
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
        
        Screen('SelectStereoDrawBuffer', screenPointer, EXPCONSTANTS.BUFFER_RADIAL);%Buffer 1
        Screen('FillRect', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR);
        %DartboardStimuli
        arcCount=0;
        startAngle=0;
        while arcCount~=(wedges+1)
            
            Screen('FrameArc',screenPointer, DarkColour ,S_TR1,startAngle,angle, sizeRing);
            Screen('FrameArc',screenPointer, LightColour,S_TR2,startAngle,angle, sizeRing);
            Screen('FrameArc',screenPointer, DarkColour ,S_TR3,startAngle,angle, sizeRing);
            Screen('FrameArc',screenPointer, LightColour,S_TR4,startAngle,angle, sizeRing);
            Screen('FrameArc',screenPointer, DarkColour ,S_TR5,startAngle,angle, sizeRing);
            Screen('FrameArc',screenPointer, LightColour,S_TR6,startAngle,angle, lastRingSize);
            
            Screen('FrameArc',screenPointer, LightColour,S_TR1,startAngle+angle,angle, sizeRing);
            Screen('FrameArc',screenPointer, DarkColour,S_TR2,startAngle+angle,angle, sizeRing);
            Screen('FrameArc',screenPointer, LightColour,S_TR3,startAngle+angle,angle, sizeRing);
            Screen('FrameArc',screenPointer, DarkColour,S_TR4,startAngle+angle,angle, sizeRing);
            Screen('FrameArc',screenPointer, LightColour,S_TR5,startAngle+angle,angle, sizeRing);
            Screen('FrameArc',screenPointer, DarkColour,S_TR6,startAngle+angle,angle, lastRingSize);
            
            startAngle=startAngle+angle*2;
            arcCount=arcCount+1;
            
        end
        Screen('FrameOval', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR,TRback, Width_back);
        Screen('FillOval', screenPointer, [50 50 50],TR2, EXPCONSTANTS.DOT_FRAME_WIDTH);
        Screen('DrawLines',screenPointer,EXPCONSTANTS.FIX_POSITION,EXPCONSTANTS.FIXCROSSWIDE,EXPCONSTANTS.FIXATION_COLOUR,EXPCONSTANTS.FIXATION_CENTRE_B1');
        Screen('FrameOval', screenPointer, EXPCONSTANTS.DOT_FRAME_COLOUR,TR, EXPCONSTANTS.DOT_FRAME_WIDTH);
        Screen('FrameOval', screenPointer, EXPCONSTANTS.DOT_FRAME_COLOUR, TR2b,EXPCONSTANTS.FIXATION_CENTRE_FRAME_WIDTH)
        
        Screen('DrawingFinished',screenPointer);
        
        Screen('Flip', screenPointer);
        
        
        
        T_alternation(alternation)=secs;
        key_press_stored(alternation)=key_press;
        alternation=alternation+1;
        
        finTime=secs-iniTime;
        
    end
    
    exit_loop=1;
    %Last Flip
    Screen('Flip', wPtr);
end

end