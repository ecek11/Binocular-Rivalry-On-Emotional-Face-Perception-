function EXPCONSTANTS=CONSTANTS_EEG_FACES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXPERIMENT CONSTANTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

  
%if not(exist('SUBJECTDATA','var'))
%%%%%%%%%%
% Training Function constants
%%%%%%%%%%
%Training block duration
EXPCONSTANTS.TRAINING_MAXTIME=10; %60;%120; %2min
EXPCONSTANTS.Luminance=2.75;

%Number of training blocks
EXPCONSTANTS.Num_training_blocks=0;%2;%Set to 0 to avoid training
%%%%%%%%%%
% Alternance Functions Constants
%%%%%%%%%%
EXPCONSTANTS.ALTERNATION_MAXTIME=100; %60;%120; %2min
%Experimental block duration
%Number of experimental blocks
EXPCONSTANTS.NUM_BLOCKS=9; %2
EXPCONSTANTS.Modulation=0.5; %In percentage of actual contrast

% These parameters are fixed
EXPCONSTANTS.Entrain_mode='pulse';%'pulse' or 'sinus'
EXPCONSTANTS.Shift=2;%[-2 0 2];  %Plus minus iAF In Hz %Notice that 0 implies no modulation at all!!! Amplitude will be set to 0
EXPCONSTANTS.Control=3; %In Hz
EXPCONSTANTS.Contrast_std=1.25; %The lower the value, the sharper the contrast change

% %%
% %SIMULATING REPLAY
% EXPCONSTANTS.Simulated_color_mix=0.77;%Between 0 and 1 (the lower the value, the more mixed will be red and green in the replay)
% EXPCONSTANTS.Transition_duration=0.087;%In seconds, we simulate a fast transition from red to green. Please notice that the minimum duration of the transition is 16 ms (replay Screen Rate is 60 Hz)
% EXPCONSTANTS.Min_simulated_length=0.2; %0.2 %In seconds, any simulated segment shorter than this value will be automatically set to this length
% EXPCONSTANTS.Num_blocks_per_replay=1;
% EXPCONSTANTS.Replay_after_blocks=[2 4 6 8]; %1 %Place the simulated blocks after 3 first and 3 last blocks
% EXPCONSTANTS.Filter_fake_mixed=0.15;%In order to rule out the events corresponding to switching from one finger to the other when calculating mixed distribution
% %Next parameters are used for shaping transparent area for
% %mixed/transition. Please do not modify unless you know what you are
% %doing!!!
% EXPCONSTANTS.MAX_MIXED_PATCH=4; %Maximum size of the starting gaussian blob in the mixed/transition condition
% EXPCONSTANTS.A0=1; %This is for generating a truncated gaussian for transparency in images.
% EXPCONSTANTS.delta_A=1;%The amplitude of the truncated gaussian will vary between A0 and A0+delta_A

%% STIMULUS CONSTANTS

%%%%
% Common constants
%%%%
%PLAY HERE WITH THE SIZE OF THE IMAGE
EXPCONSTANTS.RADIUS_CIRCLE=150; %80;   %40 %50;%100%150;%200; images becomes smaller
EXPCONSTANTS.RADIUS_DOT=80;%15jo; %30;%Was 5
EXPCONSTANTS.DOT_FRAME_COLOUR=0;
EXPCONSTANTS.DOT_FRAME_WIDTH=10;
%Here you select flash duration:
EXPCONSTANTS.GABOR_FLASH_DURATION=0.01; %adapted to obtain a flash duration of 34 ms


%% 
%%% EEG TRIGGERS
EXPCONSTANTS.Start_block=4;
EXPCONSTANTS.End_block=8;
EXPCONSTANTS.Entrain=16;
EXPCONSTANTS.Map_1=0; %Up red
EXPCONSTANTS.Map_2=1;%Up green
EXPCONSTANTS.Buffer_0=0; %Red Left
EXPCONSTANTS.Buffer_1=2;%Green Left
EXPCONSTANTS.FOI_trigger=[0 50 100 150];
%%
%KEY CONSTANTS
EXPCONSTANTS.SkipKey=KbName('w'); %code is 87,
EXPCONSTANTS.key_Up=KbName('d'); %code is 68,
EXPCONSTANTS.key_Down=KbName('x'); %code is 88, Key Left Gabor
EXPCONSTANTS.keyQuit = KbName('q'); %code is 81, Key Right Gabor
EXPCONSTANTS.spacekey=KbName('space');%code is 32
%RestrictKeysForKbCheck([32 81 87 88 90 ]);

%% Triggers
%Experiment 10 Fusion, 11 Right eye, 12 Left eye, 13 Nothing
%Training  100 Fusion, 101 Right eye, 102 Left eye, 103 Nothing

%Buffers
%1=right
%0=left
%IMAGE TYPE
%    - ImageType values are [0,1]
%    0: Gabor tilted left
%    1: Gabor tileted right
        EXPCONSTANTS.IMAGE_TYPE=0; 
        EXPCONSTANTS.BUFFER_GABOR=1;
        EXPCONSTANTS.BUFFER_RADIAL=0;
% 
%%%%%
% Screen & Sound Init
%%%%%
EXPCONSTANTS.RUNMODE='EXPERIMENT';%'TEST'; %Switch between 'TEST' and 'EXPERIMENT' to try code in different screens
EXPCONSTANTS.STEREOMODE=0;%4; %stereoMode=4; % left at left
%stereoMode=5; % left  at right
%stereoMode=2; % left top /right bottom
%stereoMode=3; % right top
EXPCONSTANTS.SCREENNUMBER =max(Screen('Screens'));%Número de pantalla donde se pasará el experimento, ver documentación psychtoolbox Screen('Open'...)
EXPCONSTANTS.BACKGROUNDCOLOR = 75;%200;%192; %Color de fondo de pantalla para el experimento ver documentación psychtoolbox Screen('Open'...)

EXPCONSTANTS.DRAWREGIONSIZE =[1920 1080]; %Tamaño de la zona de dibujo esperada 1280x1024
switch EXPCONSTANTS.RUNMODE
    case 'EXPERIMENT'
        EXPCONSTANTS.REFRESHRATEHZ =120;%120; %Refresh rate needed
        EXPCONSTANTS.TOLERANCEHZ =1; % Tolerance error in refresh rate
    otherwise
        EXPCONSTANTS.REFRESHRATEHZ =60;
        EXPCONSTANTS.TOLERANCEHZ =70; % Tolerance error in refresh rate

end
EXPCONSTANTS.FONT ='courier'; %Fuente de texto que se utilizará al presentar el experimento.
EXPCONSTANTS.FONTSIZE=10; %Text Size
EXPCONSTANTS.STYLE=1; % Text Style
%%%
% Subject Info
%%%
EXPCONSTANTS.SUBINFO{1,1}='Name';
EXPCONSTANTS.SUBINFO{2,1}='Handness';
EXPCONSTANTS.SUBINFO{3,1}='Dominant Eye';
EXPCONSTANTS.SUBINFO{4,1}='Age';
EXPCONSTANTS.SUBINFO{5,1}='Date';
EXPCONSTANTS.SUBINFO{6,1}='Version';



%%%%%
% Calibrate Mirrors Functions Constants
%%%%%
EXPCONSTANTS.CALIBRATE_FRAME_WIDTH=20; %Frame width for Stereomatching
EXPCONSTANTS.CALIBRATE_FRAME_COLOUR=0; % Frame colour
EXPCONSTANTS.CALIBRATE_IMAGE='fig_multiple.JPG'; %display empty rectangle
EXPCONSTANTS.CALIBRATE_SIZE=100; % Size of the stereomatching images
EXPCONSTANTS.CALIBRATE_BACK_COLOUR=EXPCONSTANTS.BACKGROUNDCOLOR;%192;
EXPCONSTANTS.CALIBRATE_IMAGE_LEFT_COLOUR=[150 0 0];
EXPCONSTANTS.CALIBRATE_IMAGE_RIGHT_COLOUR=[0 100 0];
EXPCONSTANTS.CALIBRATE_MAXTIME=0.2;
EXPCONSTANTS.AR_correction=0.65; %Correct aspect ratio (to get circles instead of ovals)

%%%%
EXPCONSTANTS.ALTERNANCE_FRAME_COLOUR=0;
EXPCONSTANTS.ALTERNANCE_FRAME_WIDTH=5;
EXPCONSTANTS.ALTERNANCE_BACK_COLOUR=EXPCONSTANTS.CALIBRATE_BACK_COLOUR;

%Alternance1/Alternance2 raw results name titles
EXPCONSTANTS.alternanceName{1,1}= 'Time';
EXPCONSTANTS.alternanceName{1,2}= 'Key Press';
EXPCONSTANTS.alternanceName{1,5}= 'Result';

%Alternance1/Alternance2 results titles
EXPCONSTANTS.alternanceName2{1,1}= 'Raw Time';
EXPCONSTANTS.alternanceName2{1,2}= 'Absolute Time';
EXPCONSTANTS.alternanceName2{1,3}= 'Relative switching Time';
EXPCONSTANTS.alternanceName2{1,4}= 'Key Press';
EXPCONSTANTS.alternanceName2{1,5}= 'Result';

EXPCONSTANTS.alternanceName2{1,7}= 'Gabor Dominant Modus';
EXPCONSTANTS.alternanceName2{1,8}= 'Radial Dominant Modus';

%%%%%
% Fixation Cross Constants
%%%%%

EXPCONSTANTS.FIXCROSSLONG = 7; %Fixation cross longitude
EXPCONSTANTS.FIXCROSSWIDE = 3; %Fixation cross wide

if EXPCONSTANTS.STEREOMODE>3
    EXPCONSTANTS.FIXATION_CENTRE= [256 384]; %StereoMode=4
else
    EXPCONSTANTS.FIXATION_CENTRE= [512 384]; %StereoMode=2
end

EXPCONSTANTS.FIXATION_COLOUR= [0 0 0]; %Fixation Colour
EXPCONSTANTS.FIX_POSITION= [-EXPCONSTANTS.FIXCROSSLONG,EXPCONSTANTS.FIXCROSSLONG,0,0;0,0,-EXPCONSTANTS.FIXCROSSLONG,EXPCONSTANTS.FIXCROSSLONG]; %.%
EXPCONSTANTS.FIXATION_CENTRE_B0=[-480;0]; %Fixation center for buffer 0
EXPCONSTANTS.FIXATION_CENTRE_B1=[480;0]; %Fixation center for buffer 1

EXPCONSTANTS.FIXATION_CENTRE_FRAME_WIDTH=30; %Fixation center frame widht

%%%%


%%%%
% Gabor Constants
%%%%
EXPCONSTANTS.GABOR_SPTFREQUENCY= 0.04; %0.005; %0.01%spatial frequency 0.1 spatial frequency is better easier to disambiguate %in cycles/pixel
EXPCONSTANTS.GABOR_CONTRAST= 0.1; %0.20; % 0.35;  jo     %0.45;    %0.25; %0.45;
EXPCONSTANTS.GABOR_SIGMA=200; %20;  %30 jo ;%40 smaller number smoother gabor %standard deviation in pixels
EXPCONSTANTS.GABOR_TOTALSIZE=(EXPCONSTANTS.RADIUS_DOT*2)-1; %100 %150 % 200 %image size NxN &gabor size /smaller number makes the Gabors bigger
EXPCONSTANTS.GABOR_BACKGROUND=EXPCONSTANTS.BACKGROUNDCOLOR;
EXPCONSTANTS.GABOR_BLOB=true;
EXPCONSTANTS.GABOR_PHASE=0;
% EXPCONSTANTS.GABOR_ORIENTATION=90;
EXPCONSTANTS.GABOR_ORIENTATION_HORIZONTAL=-45;%90; 
EXPCONSTANTS.GABOR_ORIENTATION_VERTICAL=45;%180;
EXPCONSTANTS.GABOR_TEXTURE_BACK_ALPHA=[]; %Transparency of gabor background texture
EXPCONSTANTS.GABOR_TEXTURE_FLASH_ALPHA=[]; %Transparency of flash gabor texture%%%
% Radial Constants
%%%
EXPCONSTANTS.DOMSTIM_WEDGES=16;
EXPCONSTANTS.DOMSTIM_RINGS=6;
EXPCONSTANTS.DOMSTIM_DARKER_COLOUR= EXPCONSTANTS.BACKGROUNDCOLOR;
% Background Colour = 75
EXPCONSTANTS.DOMSTIM_LIGHTER_COLOUR=85;
% First contrast between darker(background) and lighter colour is ~10% 

%Blurring radial constants:
EXPCONSTANTS.RADIAL_BLUR_SIGMA=0.75;
EXPCONSTANTS.RADIAL_BLUR_HSIZE=13;

%CONTRAST INCREMENT STAIRCASE constants
%Here you select contrast increment for FLASH:
EXPCONSTANTS.GABOR_HIGH_CONTRAST=EXPCONSTANTS.GABOR_CONTRAST+0.03;
EXPCONSTANTS.GABOR_HIGH_CONTRAST_DOM=EXPCONSTANTS.GABOR_HIGH_CONTRAST;
EXPCONSTANTS.GABOR_HIGH_CONTRAST_SUP=EXPCONSTANTS.GABOR_HIGH_CONTRAST;
EXPCONSTANTS.GABOR_HIGH_CONTRAST_SIGMA=200;%150;%120;  %HERE WE SELECT standard deviation FOR FLASH!


%%%%

%% TEXT INSTRUCTIONS
EXPCONSTANTS.TEXTCOLOR=100;
EXPCONSTANTS.INSTRUCTIONS_CALIBRATION =['Welcome to our experiment!\n\n'...
    'Please match perfectly \n\n'... They have to overlap!\n\n'];
    'the following images! \n\n'...
    'They have to overlap!\n\n'];



EXPCONSTANTS.INSTRUCTIONS_ALTERNATION= ['It is important that the participant doesnt focus on  \n\n' ...
    'specific parts of the face or the house \n\n'...
    'Try to view the stimuli as a whole \n\n'...
    'and avoid focusing on individual features \n\n'...
    ' This will help minimize the impact of eye movements \n\n'...
    ' Keep fixation at the cross at all moments \n\n'];

EXPCONSTANTS.INSTRUCTIONS_TRAINING =['This is a training block'];


EXPCONSTANTS.INSTRUCTIONS1_map1=['Press Up \n\n'...
    'if you see this image \n\n']; %Experiment Instructions Left
EXPCONSTANTS.INSTRUCTIONS2_map1=['Press Down ...\n\n'...
    'if you see this image \n\n'];%Experiment Instructions Right
EXPCONSTANTS.INSTRUCTIONS1_map2=['Press Down ...\n\n'...
    'if you see this image \n\n'];%Experiment Instructions Right
EXPCONSTANTS.INSTRUCTIONS2_map2=['Press Up \n\n'...
    'if you see this image \n\n']; %Experiment Instructions Left

EXPCONSTANTS.AFTER_PAUSE_map1 =['Your task is to concentrate  \n\n' ...
    'on the screen \n\n'...
    'and attend the images \n\n'...
    'Please dont move your eyes \n\n'...
    'It is really IMPORTANT!!\n\n'];

EXPCONSTANTS.AFTER_PAUSE_map2 = ['Your task is to concentrate  \n\n' ...
    'on the screen \n\n'...
    'and attend the images \n\n'...
    'Please dont move your eyes \n\n'...
    'It is really IMPORTANT!!\n\n'];

EXPCONSTANTS.BREAK=['You are in the middle of the experiment, \n\n' ...
    'take a break! After, press space to continue.'];

EXPCONSTANTS.BYESCREEN=['The experiment has finished! \n\n'...
    'Thank you for \n\n'...
    'your participation! \n\n'...
    'Press space to quit!\n\n']; %Bye Text

