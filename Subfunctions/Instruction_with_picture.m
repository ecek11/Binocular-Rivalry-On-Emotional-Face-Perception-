function Instruction_with_picture(EXPCONSTANTS,GaborBuffer,RadialBuffer,show_mode)

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
switch lower(show_mode)
    case 'green' 
        EXPCONSTANTS.GABOR_ORIENTATION_HORIZONTAL=EXPCONSTANTS.GABOR_ORIENTATION_VERTICAL;
        text=EXPCONSTANTS.INSTRUCTIONS2;
        color_idx=2;
        COLOR=EXPCONSTANTS.Green_Level;
    case 'red' 
        EXPCONSTANTS.GABOR_ORIENTATION_VERTICAL=EXPCONSTANTS.GABOR_ORIENTATION_HORIZONTAL;
        text=EXPCONSTANTS.INSTRUCTIONS1;
        color_idx=1;
        COLOR= EXPCONSTANTS.Red_Level;
end

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

% %KEY CONSTANTS
% SkipKey=KbName('w'); %code is 87,
% key_Radial=KbName('d'); %code is 68,
% key_Gabor=KbName('x'); %code is 88,
% keyQuit = KbName('q'); %code is 81

RestrictKeysForKbCheck([32 81 87 88 68 ]);

%FRAME DIMENSION CONSTANTS

Size=EXPCONSTANTS.RADIUS_CIRCLE;
Size2=EXPCONSTANTS.FIXCROSSLONG*2;
windowRect=EXPCONSTANTS.SCREENRECT;
xmax = RectWidth(windowRect)/2;
ymax = RectHeight(windowRect)/2;
Aspect_ratio= EXPCONSTANTS.ASPECT_RATIO;
text_r=[xmax ymax];

TR=[(text_r(1,1)-1*Size) (text_r(1,2)-Size) (text_r(1,1)+1*Size) (text_r(1,2)+Size)];
TR2=[text_r(1,1)-1*Size2 text_r(1,2)-Size2 text_r(1,1)+1*Size2 text_r(1,2)+Size2];
TR2b=[TR2(1,1)-EXPCONSTANTS.FIXATION_CENTRE_FRAME_WIDTH TR2(1,2)-EXPCONSTANTS.FIXATION_CENTRE_FRAME_WIDTH TR2(1,3)+EXPCONSTANTS.FIXATION_CENTRE_FRAME_WIDTH TR2(1,4)+EXPCONSTANTS.FIXATION_CENTRE_FRAME_WIDTH];
TRback=[xmax-2*xmax ymax-2*xmax xmax+2*xmax ymax+2*xmax];
Width_back=round(2*xmax-Size+22);%+2*EXPCONSTANTS.DOT_FRAME_WIDTH);


[width, height]=Screen('WindowSize', wPtr);
increaseforConstantGabor=20;
texture_rectangle=[-EXPCONSTANTS.RADIUS_DOT-increaseforConstantGabor; -EXPCONSTANTS.RADIUS_DOT-increaseforConstantGabor; ...
EXPCONSTANTS.RADIUS_DOT+increaseforConstantGabor; EXPCONSTANTS.RADIUS_DOT+increaseforConstantGabor];
texture_rectangle=texture_rectangle+0.5*[width; height; width; height];
texture_rectangleB0=texture_rectangle-0.25*[width;0;width;0];
texture_rectangleB1=texture_rectangle+0.25*[width;0;width;0];
%[width, height]=Screen('WindowSize', wPtr);



increaseforConstantGabor=20;
texture_rectangle=[-EXPCONSTANTS.RADIUS_DOT-increaseforConstantGabor; -EXPCONSTANTS.RADIUS_DOT-increaseforConstantGabor; ...
EXPCONSTANTS.RADIUS_DOT+increaseforConstantGabor; EXPCONSTANTS.RADIUS_DOT+increaseforConstantGabor];
% texture_rectangleB1=texture_rectangle;

TRL=TR-0.25*[width 0 width 0];
TRR=TR+0.25*[width 0 width 0];
TR2L=TR2-0.25*[width 0 width 0];
TR2R=TR2+0.25*[width 0 width 0];
TR2bL=TR2b-0.25*[width 0 width 0];
TR2bR=TR2b+0.25*[width 0 width 0];
TRbackL=TRback-0.25*[width 0 width 0];
TRbackR=TRback+0.25*[width 0 width 0];
% FIXATION CROSS CONSTANTS

EXPCONSTANTS.FIX_POSITION=[-EXPCONSTANTS.FIXCROSSLONG,EXPCONSTANTS.FIXCROSSLONG,0,0; ...
    0,0,-EXPCONSTANTS.FIXCROSSLONG,EXPCONSTANTS.FIXCROSSLONG];
EXPCONSTANTS.FIX_POSITION=EXPCONSTANTS.FIX_POSITION+0.5*[width width width width; height height height height];

% GENERATION OF GABOR PATCHES
alphaBack=EXPCONSTANTS.GABOR_TEXTURE_BACK_ALPHA;
tgaborPatchHor = GenerateGaborPatch(spatialFrequency,orientation_horizontal, contrast, sigma, TotalGsize, phase, display,background,blob);
tgaborPatchVer = GenerateGaborPatch(spatialFrequency,orientation_vertical, contrast, sigma, TotalGsize, phase, display,background,blob);
% gaborPatchbiggercontrast = GenerateGaborPatch(spatialFrequency,orientation, highContrastGabor, sigma, TotalGsize, phase, display,background,blob);
gaborPatchHor=zeros(size(tgaborPatchHor,1),size(tgaborPatchHor,2),3);

gaborPatchHor(:,:,color_idx)=tgaborPatchHor*COLOR/255;
 for x=1:size(gaborPatchHor,1)
        for y=1:size(gaborPatchHor,2)
            lx=x-TotalGsize/2-0.5;
            ly=y-TotalGsize/2-0.5;
            r=sqrt(lx^2+ly^2);
            if r>=Size-increaseforConstantGabor
                
                gaborPatchHor(x,y,1:3)=EXPCONSTANTS.BACKGROUNDCOLOR;
            end
        end
 end
 gaborPatchVer=gaborPatchHor;

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

%Screen('SelectStereoDrawBuffer', screenPointer,GaborBuffer); %Buffer 0
Screen('FillRect', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR);
Screen('DrawTextures', screenPointer,  gaborTextureHorizontal ,[] , texture_rectangleB0, [], [],alphaBack); %0.
%Screen('DrawTextures', win, gabortex, srcRect, dstRects, [], [], ALPHA);
%win: Monitor pointer
%gabortex: Textures
%srcRect: part of the texture to be drawn []: draw all the texture
%dstRects: where do we draw the texture
%ALPHA: Transparency of the textures (set to 0.5)
%Screen('FrameOval', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR,TRback, Width_back);
Screen('FillOval', screenPointer, [50 50 50],TR2L, EXPCONSTANTS.DOT_FRAME_WIDTH);
 Screen('DrawLines',screenPointer,EXPCONSTANTS.FIX_POSITION-[xmax/2 xmax/2 xmax/2 xmax/2;0 0 0 0],EXPCONSTANTS.FIXCROSSWIDE,EXPCONSTANTS.FIXATION_COLOUR,EXPCONSTANTS.FIXATION_CENTRE_B0');
    Screen('FrameOval', screenPointer, EXPCONSTANTS.DOT_FRAME_COLOUR,TRL,EXPCONSTANTS.DOT_FRAME_WIDTH);
Screen('FrameOval', screenPointer, EXPCONSTANTS.DOT_FRAME_COLOUR, TR2bL,EXPCONSTANTS.FIXATION_CENTRE_FRAME_WIDTH)
[~, ~, ~] = DrawFormattedText(screenPointer, text, 'center', 150, EXPCONSTANTS.TEXTCOLOR, 70,[],[],[],[],[0 height width/2 0]);

%Screen('SelectStereoDrawBuffer', screenPointer, RadialBuffer);%Buffer 1
%Screen('FillRect', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR);
Screen('DrawTextures', screenPointer,  gaborTextureVertical ,[] , texture_rectangleB1, [], [],alphaBack); %0.
%Screen('FrameOval', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR,TRback, Width_back);
Screen('FillOval', screenPointer, [50 50 50],TR2R, EXPCONSTANTS.DOT_FRAME_WIDTH);
   Screen('DrawLines',screenPointer,EXPCONSTANTS.FIX_POSITION+[xmax/2 xmax/2 xmax/2 xmax/2;0 0 0 0],EXPCONSTANTS.FIXCROSSWIDE,EXPCONSTANTS.FIXATION_COLOUR,EXPCONSTANTS.FIXATION_CENTRE_B0');
    Screen('FrameOval', screenPointer, EXPCONSTANTS.DOT_FRAME_COLOUR,TRR, EXPCONSTANTS.DOT_FRAME_WIDTH);
Screen('FrameOval', screenPointer, EXPCONSTANTS.DOT_FRAME_COLOUR, TR2bR,EXPCONSTANTS.FIXATION_CENTRE_FRAME_WIDTH)
[~, ~, ~] = DrawFormattedText(screenPointer, text, 'center', 150, EXPCONSTANTS.TEXTCOLOR, 70,[],[],[],[],[width/2 height width 0]);

Screen('DrawingFinished',screenPointer);

Screen('Flip', screenPointer);

exit_loop=0;
while not(exit_loop)
    
    [~, secs, keyCode]=KbCheck;
    FlushEvents;
    
    exit_loop=keyCode(32); %'space' key
    
end

Screen('SelectStereoDrawBuffer', screenPointer,GaborBuffer); %Buffer 0
Screen('FillRect', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR);
Screen('SelectStereoDrawBuffer', screenPointer, RadialBuffer);%Buffer 1
Screen('FillRect', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR);
Screen('Flip', screenPointer);

    FlushEvents;
    WaitSecs(0.5);