function [T0, T_alternation,key_press_stored,Actual_frequency,Entrain_T]=Alternation_EEG_2_Entrain_2(EXPCONSTANTS,GaborBuffer,RadialBuffer,mode,ioObj,address)
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
refresh_rate=Screen('GetFlipInterval',screenPointer);
%In order not to have too many flips (too hard for the computer);



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
% Aspect_ratio= EXPCONSTANTS.ASPECT_RATIO;
text_r=[xmax ymax];

TR=[(text_r(1,1)-1*Size) (text_r(1,2)-Size) (text_r(1,1)+1*Size) (text_r(1,2)+Size)];
TR2=[text_r(1,1)-1*Size2 text_r(1,2)-Size2 text_r(1,1)+1*Size2 text_r(1,2)+Size2];
TR2b=[TR2(1,1)-EXPCONSTANTS.FIXATION_CENTRE_FRAME_WIDTH TR2(1,2)-EXPCONSTANTS.FIXATION_CENTRE_FRAME_WIDTH TR2(1,3)+EXPCONSTANTS.FIXATION_CENTRE_FRAME_WIDTH TR2(1,4)+EXPCONSTANTS.FIXATION_CENTRE_FRAME_WIDTH];
%TRback=[xmax-2*xmax ymax-2*xmax xmax+2*xmax ymax+2*xmax];
% Width_back=round(2*xmax-Size+22);%+2*EXPCONSTANTS.DOT_FRAME_WIDTH);


[width, height]=Screen('WindowSize', wPtr);
increaseforConstantGabor=20;
texture_rectangle=[-EXPCONSTANTS.RADIUS_DOT-increaseforConstantGabor; -EXPCONSTANTS.RADIUS_DOT-increaseforConstantGabor; ...
    EXPCONSTANTS.RADIUS_DOT+increaseforConstantGabor; EXPCONSTANTS.RADIUS_DOT+increaseforConstantGabor];
texture_rectangle=texture_rectangle+0.5*[width; height; width; height];
texture_rectangleB0=texture_rectangle-0.25*[width;0;width;0];
texture_rectangleB1=texture_rectangle+0.25*[width;0;width;0];
% texture_rectangleB1=texture_rectangle;

TRL=TR-0.25*[width 0 width 0];
TRR=TR+0.25*[width 0 width 0];
TR2L=TR2-0.25*[width 0 width 0];
TR2R=TR2+0.25*[width 0 width 0];
TR2bL=TR2b-0.25*[width 0 width 0];
TR2bR=TR2b+0.25*[width 0 width 0];
% TRbackL=TRback-0.25*[width 0 width 0];
% TRbackR=TRback+0.25*[width 0 width 0];
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

% gaborTextureHorizontal=Screen('MakeTexture',wPtr,gaborPatchHor);
% gaborTextureVertical=Screen('MakeTexture',wPtr,gaborPatchVer);

% Initially fill left- and right-eye image buffer with specified background color:
% Screen('SelectStereoDrawBuffer', wPtr, 0);
% Screen('FillRect', wPtr, EXPCONSTANTS.BACKGROUNDCOLOR);
% Screen('SelectStereoDrawBuffer', wPtr, 1);
 Screen('FillRect', wPtr, EXPCONSTANTS.BACKGROUNDCOLOR);

% Show cleared start screen:
Screen('Flip', wPtr);

% Set up alpha-blending for smooth (anti-aliased) drawing of dots:
Screen('BlendFunction', wPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');


%Now normalize: 1 is original color and -1 is origninal color minus
%2Amplitude of modulation

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

switch lower(mode)
    case 'training'
        EXPCONSTANTS.ALTERNATION_MAXTIME=EXPCONSTANTS.TRAINING_MAXTIME;
       
end

% Now prepare the textures
switch EXPCONSTANTS.Entrain_mode
    case 'pulse'
        delta_contrast=get_contrasts(EXPCONSTANTS);
        N_textures=length(delta_contrast);
        %Fill the rest of textures with zeros
        Num_points=round((1/EXPCONSTANTS.Frequency)/refresh_rate);
        
    case 'sinus'
        Num_points=round((1/EXPCONSTANTS.Frequency)/refresh_rate);
        delta_contrast=EXPCONSTANTS.Amplitude*sin(2*pi*EXPCONSTANTS.Frequency*(0:Num_points-1)*refresh_rate);
        N_textures=Num_points;
end

for nc=1:N_textures
    ncontrast=contrast+delta_contrast(nc);
    tgaborPatchHor = GenerateGaborPatch(spatialFrequency,orientation_horizontal, ncontrast, sigma, TotalGsize, phase, display,background,blob);
    tgaborPatchVer = GenerateGaborPatch(spatialFrequency,orientation_vertical, ncontrast, sigma, TotalGsize, phase, display,background,blob);
    gaborPatchHor(:,:,1)=tgaborPatchHor*EXPCONSTANTS.Red_Level/255;
    gaborPatchHor(:,:,2:3)=0;
    gaborPatchVer(:,:,2)=tgaborPatchVer*EXPCONSTANTS.Green_Level/255;
    gaborPatchVer(:,:,[1 3])=0;
    
    for x=1:size(gaborPatchVer,1)
        for y=1:size(gaborPatchVer,2)
            lx=x-TotalGsize/2-0.5;
            ly=y-TotalGsize/2-0.5;
            r=sqrt(lx^2+ly^2);
            if r>=Size-20
                gaborPatchVer(x,y,1:3)=EXPCONSTANTS.BACKGROUNDCOLOR;
                gaborPatchHor(x,y,1:3)=EXPCONSTANTS.BACKGROUNDCOLOR;
                %             else
                %                 if r<=Size2+2*EXPCONSTANTS.DOT_FRAME_WIDTH
                %                     gaborPatchVer(x,y,1:3)=EXPCONSTANTS.DOT_FRAME_COLOUR;
                %                     gaborPatchHor(x,y,1:3)=EXPCONSTANTS.DOT_FRAME_COLOUR;
                %                 end
            end
        end
    end
    
%     if nc==1
%         
%         gaborPatchHor(:,:,:)=255;
%         gaborPatchVer(:,:,:)=255;
%         
%     else
%         gaborPatchHor(:,:,:)=0;
%         gaborPatchVer(:,:,:)=0;
%     end
    
    
    Text(nc,1+GaborBuffer).gaborTexture=Screen('MakeTexture',wPtr,gaborPatchHor);
    Text(nc,1+RadialBuffer).gaborTexture=Screen('MakeTexture',wPtr,gaborPatchVer);
end

%Draw the images to show
Screen('FillRect', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR);
FlushEvents;
%Initialize time
%Now wait until the participant presses any key
% n=0;


%Texture_num=1:N_textures;
%Texture_num(1:N_textures)=1:N_textures;


Actual_frequency=1/(Num_points*refresh_rate);
disp(['Desired entraining frequency is ' num2str(EXPCONSTANTS.Frequency)]);
disp(['Actual entraining frequency is ' num2str(Actual_frequency)]);

%duplicateWin = Screen('OpenOffscreenWindow', screenPointer);
Num_white=Num_points-N_textures;

start_time=(randi(max(Num_white,1))-0.5)*refresh_rate;







FlushEvents;
Tvec=nan(30000,1);
Key_pressed=nan(30000,1);
Entrain_T=nan(3000,1);

% [pressed, secs, keyCode]=KbCheck;
% key_prev= 3-2*(keyCode(key_Gabor))-(keyCode(key_Radial));
%
% T_alternation(1)=secs;
% key_press_stored(1)=key_prev;
exit_loop=0;
%Start stimulation always with no flickering (for a random amount of time,
%always less than the duration of the no flickering

Screen('FillRect', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR);
Screen('DrawTextures', screenPointer,  Text(N_textures,1).gaborTexture ,[] , texture_rectangleB0, [], [],alphaBack); %0.
%Screen('DrawTextures', win, gabortex, srcRect, dstRects, [], [], ALPHA);
%win: Monitor pointer
%gabortex: Textures
%srcRect: part of the texture to be drawn []: draw all the texture
%dstRects: where do we draw the texture
%ALPHA: Transparency of the textures (set to 0.5)
%   Screen('FrameOval', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR,TRbackL, Width_back);
Screen('FillOval', screenPointer, [50 50 50],TR2L, EXPCONSTANTS.DOT_FRAME_WIDTH);
Screen('DrawLines',screenPointer,EXPCONSTANTS.FIX_POSITION-[xmax/2 xmax/2 xmax/2 xmax/2;0 0 0 0],EXPCONSTANTS.FIXCROSSWIDE,EXPCONSTANTS.FIXATION_COLOUR,EXPCONSTANTS.FIXATION_CENTRE_B0');
Screen('FrameOval', screenPointer, EXPCONSTANTS.DOT_FRAME_COLOUR,TRL,EXPCONSTANTS.DOT_FRAME_WIDTH);
Screen('FrameOval', screenPointer, EXPCONSTANTS.DOT_FRAME_COLOUR, TR2bL,EXPCONSTANTS.FIXATION_CENTRE_FRAME_WIDTH)

% Screen('SelectStereoDrawBuffer', screenPointer, RadialBuffer);%Buffer 1
% Screen('FillRect', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR);
Screen('DrawTextures', screenPointer,  Text(N_textures,2).gaborTexture ,[] , texture_rectangleB1, [], [],alphaBack); %0.
%Screen('FrameOval', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR,TRbackR, Width_back);
Screen('FillOval', screenPointer, [50 50 50],TR2R, EXPCONSTANTS.DOT_FRAME_WIDTH);
Screen('DrawLines',screenPointer,EXPCONSTANTS.FIX_POSITION+[xmax/2 xmax/2 xmax/2 xmax/2;0 0 0 0],EXPCONSTANTS.FIXCROSSWIDE,EXPCONSTANTS.FIXATION_COLOUR,EXPCONSTANTS.FIXATION_CENTRE_B1');
Screen('FrameOval', screenPointer, EXPCONSTANTS.DOT_FRAME_COLOUR,TRR, EXPCONSTANTS.DOT_FRAME_WIDTH);
Screen('FrameOval', screenPointer, EXPCONSTANTS.DOT_FRAME_COLOUR, TR2bR,EXPCONSTANTS.FIXATION_CENTRE_FRAME_WIDTH)

Screen('DrawingFinished',screenPointer);
EEG_anchor=Screen('Flip',screenPointer);

%This is the anchor point
T0=WaitSecs('UntilTime',EEG_anchor+start_time);
%Flip_T=Screen('Flip', screenPointer);
io64(ioObj,address,EXPCONSTANTS.Start_trigger);
WaitSecs(0.01);
io64(ioObj,address,0);
n=1;
Flip_T0=GetSecs;
ent=0;
while not(exit_loop)
    
    %     alternation=1;
    %     finTime=0;
    %     iniTime=GetSecs();
    %     T_alternation=0;
    %     key_press_stored=0;
    %     key_prev=Inf;
   
    iniTime=GetSecs;
    finTime=GetSecs-iniTime;
    while (finTime<EXPCONSTANTS.ALTERNATION_MAXTIME)
        
        
        [~, secs, keyCode]=KbCheck;
        key_press= 3-2*(keyCode(key_Gabor))-(keyCode(key_Radial));
        %       FlushEvents;
        %       exit_loop=keyCode(SkipKey);
        quit = keyCode(keyQuit);
        Tvec(n)=secs;
        Key_pressed(n)=key_press;
        finTime=secs-iniTime;
        %         if key_press~=key_prev
        %             %EEG_code=(key_press+EXPCONSTANTS.Trigger);
        %             %0 both, 1 red, 2 green, 3 none
        %             EEG_code=EXPCONSTANTS.Triggers(key_press+1);
        %             %disp(num2str(EEG_code));
        %             io64(ioObj,address,EEG_code);
        %             %Clear the parallel port
        %            % WaitSecs(0.01);
        %            % io64(ioObj,address,0);
        %             key_prev=key_press;
        %             T_alternation(alternation)=secs;
        %             key_press_stored(alternation)=key_press;
        %             alternation=alternation+1;
        %             %Make sure we always end after an alternation
        %             finTime=secs-iniTime;
        %         end
        
        % y= 3-2left-right :
        % y= 3-2*1-1=0 both
        % y= 3-2*1-0=1 red
        % y= 3-2*0-1=2 green
        % y= 3-2*0-0=3 none
        for j=1:N_textures
            % Nc=Texture_num(mod(start_point+n,Num_points)+1);
            
            % Screen('SelectStereoDrawBuffer', screenPointer,GaborBuffer); %Buffer 0
            Screen('FillRect', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR);
            Screen('DrawTextures', screenPointer,  Text(j,1).gaborTexture ,[] , texture_rectangleB0, [], [],alphaBack); %0.
            %Screen('DrawTextures', win, gabortex, srcRect, dstRects, [], [], ALPHA);
            %win: Monitor pointer
            %gabortex: Textures
            %srcRect: part of the texture to be drawn []: draw all the texture
            %dstRects: where do we draw the texture
            %ALPHA: Transparency of the textures (set to 0.5)
            %   Screen('FrameOval', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR,TRbackL, Width_back);
            Screen('FillOval', screenPointer, [50 50 50],TR2L, EXPCONSTANTS.DOT_FRAME_WIDTH);
            Screen('DrawLines',screenPointer,EXPCONSTANTS.FIX_POSITION-[xmax/2 xmax/2 xmax/2 xmax/2;0 0 0 0],EXPCONSTANTS.FIXCROSSWIDE,EXPCONSTANTS.FIXATION_COLOUR,EXPCONSTANTS.FIXATION_CENTRE_B0');
            Screen('FrameOval', screenPointer, EXPCONSTANTS.DOT_FRAME_COLOUR,TRL,EXPCONSTANTS.DOT_FRAME_WIDTH);
            Screen('FrameOval', screenPointer, EXPCONSTANTS.DOT_FRAME_COLOUR, TR2bL,EXPCONSTANTS.FIXATION_CENTRE_FRAME_WIDTH)
            
            % Screen('SelectStereoDrawBuffer', screenPointer, RadialBuffer);%Buffer 1
            % Screen('FillRect', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR);
            Screen('DrawTextures', screenPointer,  Text(j,2).gaborTexture ,[] , texture_rectangleB1, [], [],alphaBack); %0.
            %Screen('FrameOval', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR,TRbackR, Width_back);
            Screen('FillOval', screenPointer, [50 50 50],TR2R, EXPCONSTANTS.DOT_FRAME_WIDTH);
            Screen('DrawLines',screenPointer,EXPCONSTANTS.FIX_POSITION+[xmax/2 xmax/2 xmax/2 xmax/2;0 0 0 0],EXPCONSTANTS.FIXCROSSWIDE,EXPCONSTANTS.FIXATION_COLOUR,EXPCONSTANTS.FIXATION_CENTRE_B1');
            Screen('FrameOval', screenPointer, EXPCONSTANTS.DOT_FRAME_COLOUR,TRR, EXPCONSTANTS.DOT_FRAME_WIDTH);
            Screen('FrameOval', screenPointer, EXPCONSTANTS.DOT_FRAME_COLOUR, TR2bR,EXPCONSTANTS.FIXATION_CENTRE_FRAME_WIDTH)
            
            Screen('DrawingFinished',screenPointer);
            %io64(ioObj,address,0);
            %WaitSecs('UntilTime',Flip_T0+0.5*refresh_rate);
            %Flip_T=Screen('Flip', screenPointer,Flip_T+2*refresh_rate);
            %             j
            %             GetSecs-Flip_T0
            Flip_T0=Screen('Flip',screenPointer);
            
            n=n+1;
            [~, secs, keyCode]=KbCheck;
            Tvec(n)=secs;
            key_press= 3-2*(keyCode(key_Gabor))-(keyCode(key_Radial));
            Key_pressed(n)=key_press;
        end
        ent=ent+1;
        %io64(ioObj,address,EXPCONSTANTS.Entrain_trigger);
        Entrain_T(ent)=GetSecs;
        %Now we enter the loop where nothing changes
        for k=1:Num_white
            n=n+1;
            %k
            [~, secs, keyCode]=KbCheck;
            key_press= 3-2*(keyCode(key_Gabor))-(keyCode(key_Radial));
            Tvec(n)=secs;
            Key_pressed(n)=key_press;
            %Flip_T0=WaitSecs('UntilTime',Flip_T0+refresh_rate);
            %Flip without refreshing screen
            Flip_T0=WaitSecs('UntilTime',Flip_T0+refresh_rate);
            %Flip_T0=Screen('Flip',screenPointer,[],1);
        end
        n=n+1;
        [~, secs, keyCode]=KbCheck;
        key_press= 3-2*(keyCode(key_Gabor))-(keyCode(key_Radial));
        Tvec(n)=secs;
        Key_pressed(n)=key_press;
        %Flip_T0=WaitSecs('UntilTime',Flip_T0+refresh_rate);
        %Flip without refreshing screen
        Flip_T0=WaitSecs('UntilTime',Flip_T0+0.5*refresh_rate);
        %Each end of a train of entrainers we send a marker
       

        
        %WaitSecs('UntilTime',Flip_T0+1/Actual_Frequency-0.5*refresh_rate);
        
        % io64(ioObj,address,0);
        if quit
            Screen('CloseAll');
            ListenChar(1);
            error ('Experiment stopped by user pressing "quit key"');
            
        end
        %         if exit_loop
        %             save(['tmp_alt' datestr(now,'YYMMDDHHmm') '.mat'],'T_alternation','key_press_stored','T0');
        %             break;
        %         end
        
        
        
        
    end
    
    exit_loop=1;
    
end
Entrain_T=Entrain_T(1:ent);
 io64(ioObj,address,0);
 WaitSecs(0.01);
io64(ioObj,address,EXPCONSTANTS.End_trigger);
io64(ioObj,address,0);
 WaitSecs(0.01);

for nc=1:length(Text)
    Screen('Close', Text(nc,1).gaborTexture);
    Screen('Close',Text(nc,2).gaborTexture);
end

% Last Flip:
Screen('SelectStereoDrawBuffer', screenPointer,GaborBuffer); %Buffer 0
Screen('FillRect', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR);
Screen('SelectStereoDrawBuffer', screenPointer, RadialBuffer);%Buffer 1
Screen('FillRect', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR);
%

%Now select only the alternation times (this is made to be analyzed as
%previous experiment)
Key_pressed=Key_pressed(1:n);
Tvec=Tvec(1:n);


key_prev=Key_pressed(1);
key_press_stored(1)=Key_pressed(1);
T_alternation(1)=Tvec(1);
alternation=2;

for k=2:length(Tvec)
key_press=Key_pressed(k);
 if key_press~=key_prev
            %EEG_code=(key_press+EXPCONSTANTS.Trigger);
            %0 both, 1 red, 2 green, 3 none
            %Clear the parallel port
           % WaitSecs(0.01);
           % io64(ioObj,address,0);
            key_prev=key_press;
            T_alternation(alternation)=Tvec(k);
            key_press_stored(alternation)=key_press;
            alternation=alternation+1;
        end
end

 %This is for testing purposes, should be removed during experiment
% save(['raw_data_' datestr(now,'YYMMDDHHmm') '.mat'],'Key_pressed','Tvec');
Screen('Flip', wPtr);
WaitSecs(0.05);

end