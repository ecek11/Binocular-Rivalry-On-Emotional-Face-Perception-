function Alternation_EEG_2_Entrain_2(EXPCONSTANTS,image,image_lum,object,object_lum,freq1,freq2,mode,ioObj,address)
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

%windowRect, wPtr

%GENERAL CONFIGURATION
AssertOpenGL;

%G-PATCHES CONSTANTS
T0=0;
T_alternation=0;
textures=12;
key_press_stored=0;
wPtr = EXPCONSTANTS.SCREENPOINTER;
screenPointer=wPtr;
refresh_rate=Screen('GetFlipInterval',screenPointer);
%In order not to have too many flips (too hard for the computer);


%KEY CONSTANTS
%SkipKey=EXPCONSTANTS.SkipKey;




[width, height]=Screen('WindowSize', wPtr);
increaseforConstantGabor=20;
texture_rectangle=[-EXPCONSTANTS.RADIUS_DOT-increaseforConstantGabor; -EXPCONSTANTS.RADIUS_DOT-increaseforConstantGabor; ...
    EXPCONSTANTS.RADIUS_DOT+increaseforConstantGabor; EXPCONSTANTS.RADIUS_DOT+increaseforConstantGabor];
texture_rectangle=texture_rectangle+0.5*[width; height; width; height];
texture_rectangleB0=texture_rectangle-0.25*[width;0;width;0];
texture_rectangleB1=texture_rectangle+0.25*[width;0;width;0];
% texture_rectangleB1=texture_rectangle;

% FIXATION CROSS CONSTANTS , I think we are using this, but is it present
% in the screen couldn't see it.

EXPCONSTANTS.FIX_POSITION=[-EXPCONSTANTS.FIXCROSSLONG,EXPCONSTANTS.FIXCROSSLONG,0,0; ...
    0,0,-EXPCONSTANTS.FIXCROSSLONG,EXPCONSTANTS.FIXCROSSLONG];
EXPCONSTANTS.FIX_POSITION=EXPCONSTANTS.FIX_POSITION+0.5*[width width width width; height height height height];

% Show cleared start screen:


% Set up alpha-blending for smooth (anti-aliased) drawing of dots:
Screen('BlendFunction', wPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');


%Dominant Stimuli Constants
blurop = CreateGLOperator(wPtr);

switch lower(mode)
    case 'training'
        EXPCONSTANTS.ALTERNATION_MAXTIME=EXPCONSTANTS.TRAINING_MAXTIME;imgTexture 
       
end
% ??????????????????????????????????????
% % Now prepare the textures
% switch EXPCONSTANTS.Entrain_mode
%     case 'pulse'
%         delta_contrast=get_contrasts(EXPCONSTANTS);% ??? what does this do?
%         N_textures=length(delta_contrast);
%         %Fill the rest of textures with zeros
%         Num_points=round((1/EXPCONSTANTS.Frequency)/refresh_rate);
%         
%     case 'sinus'
%         Num_points=round((1/EXPCONSTANTS.Frequency)/refresh_rate);
%         delta_contrast=EXPCONSTANTS.Amplitude*sin(2*pi*EXPCONSTANTS.Frequency*(0:Num_points-1)*refresh_rate);
%         N_textures=Num_points;
% end

%You replaced values that are defined in the constants file by other values
%that override the folder ones, this is a bad practice. All the things that
%may change need to be changed outside
refresh_rate= EXPCONSTANTS.REFRESHRATEHZ;
experiment_duration =EXPCONSTANTS.ALTERNATION_MAXTIME;
%texture_list2 = {'F1N.JPG', 'F2N.JPG', 'F1F.JPG', 'F2F.JPG', 'M1N.JPG', 'M2N.JPG', 'M1F.JPG', 'M2F.JPG', 'o1.jpg', 'o2.jpg', 'o3.jpg', 'o4.jpg'};
%texture_list = {'F1N.JPG', 'o1.jpg','F2N.JPG','o2.JPG', 'F1F.JPG','o3.JPG', 'F2F.JPG','o4.JPG' ,'M1N.JPG', 'o1.JPG','M2N.JPG','o2.JPG' ,'M1F.JPG','o3.JPG' ,'M2F.JPG','o4.JPG'};
%num_textures = length(texture_list);
num_frames = round(experiment_duration * refresh_rate);
Entrain_T=nan;

image1=image;
image2=image_lum;
obj1=object;
obj2=object_lum;

a= round(refresh_rate/freq1);
b= round(refresh_rate/freq2);

TR(1)=Screen('MakeTexture', wPtr, image1);

TR(2)=Screen('MakeTexture', wPtr, image2);

TL(1)=Screen('MakeTexture', wPtr, obj1);

TL(2)=Screen('MakeTexture', wPtr, obj2);

%You have to create two vectors with ones and 2 duration: framerate x block
%duration. All 1 and 2 indicates brighter image
%TvecL=[1 1 1 1 1 1 2 1 1 1 1 1 1 2 1 1 1 1 1 1 2 1 1 1 1 1 1 2 1 1 1 1 1 1 2 1 1 1 1 1 1 2 1 1 1 1 1 1 2 1 1 1 1 1 1 2];
%TvecR=[1 1 1 1 2 1 1 1 1 2 1 1 1 1 2 1 1 1 1 2 1 1 1 1 2 1 1 1 2 1 1 1 2 1 1 1 1 2 1 1 1 1 2 1 1 1 2 1 1 1 2 1 1 2 1 1];
%num_textures=length(TvecL);

%for nc = 1:2:num_textures-1
%     imgTexture = Screen('MakeTexture', wPtr, imread(fullfile('Utilities', texture_list{nc})));
%     imgTexture2 = Screen('MakeTexture', wPtr, imread(fullfile('Utilities', texture_list{nc+1})));
%     
    
%Draw the images to show
%Screen('FillRect', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR);
%FlushEvents;
TvecL = ones(1, num_frames);
TvecR = ones(1, num_frames);

for i = 1:num_frames
    if mod(i-1, a) == a-1
        TvecL(i) = 2;
    end
    if mod(i-1, b) == b-1
        TvecR(i) = 2;
    end
end


% Actual_frequency=1/(Num_points*refresh_rate);
% disp(['Desired entraining frequency is ' num2str(EXPCONSTANTS.Frequency)]);
% disp(['Actual entraining frequency is ' num2str(Actual_frequency)]);

Screen('FillRect', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR);
Screen('Flip', wPtr);
%Comment here when you are upstairs
io64(ioObj,address,EXPCONSTANTS.Start_trigger);
WaitSecs(0.01);
io64(ioObj,address,0);
%Comment up to here

% Draw the images to show
for nc = 1:num_frames
    Screen('FillRect', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR);
    %Draw the images to show
    Screen('FillRect', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR);
    FlushEvents;
Screen('DrawTexture', wPtr, TR(TvecL(nc)), [], texture_rectangleB0, 0);

Screen('DrawTexture', wPtr, TL(TvecR(nc)), [], texture_rectangleB1, 0);

Screen('DrawLines',screenPointer,EXPCONSTANTS.FIX_POSITION,EXPCONSTANTS.FIXCROSSWIDE,EXPCONSTANTS.FIXATION_COLOUR,EXPCONSTANTS.FIXATION_CENTRE_B0');

%For the other side is
Screen('DrawLines',screenPointer,EXPCONSTANTS.FIX_POSITION,EXPCONSTANTS.FIXCROSSWIDE,EXPCONSTANTS.FIXATION_COLOUR,EXPCONSTANTS.FIXATION_CENTRE_B1'); 


Screen('DrawingFinished',screenPointer);
EEG_anchor=Screen('Flip',screenPointer);





end

 %After the loop ends, you have to close the textures
for nc=1:2
    Screen('Close', TL(nc));
    Screen('Close',TR(nc));
end







 %This is for testing purposes, should be removed during experiment
% save(['raw_data_' datestr(now,'YYMMDDHHmm') '.mat'],'Key_pressed','Tvec');

%Show empty screen
Screen('FillRect', screenPointer, EXPCONSTANTS.BACKGROUNDCOLOR);
Screen('Flip', wPtr);

%Comment here when you are upstairs
io64(ioObj,address,EXPCONSTANTS.End_trigger);
WaitSecs(0.01);
io64(ioObj,address,0);
%Comment up to here


% Wait for two seconds
%WaitSecs(0.5);