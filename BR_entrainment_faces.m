 
%function [timeStart timeFinish] = ExpShutterTraining_ButtonMouth(EXPCONSTANTS,SUBJECTDATA)

% Main function
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Inputs:
%       EXPCONSTANTS: structure containing with at least following fields:
%            SCREENNUMBER: Integer (specifies a screen: 0 is the main screen
%            BACKGROUNDCOLOR: Integer scalar or 1x3 [r g b] (specify the colour
%                   of the window background)
%            REFRESHRATEHZ : Integer (expected refresh rate in Hz)
%            TOLERANCEHZ: Integer (specifies the tole
% rance with refresh
%            rate)dd
%            DRAWREGIONSIZE:Integer 1x2 (expected window size)  STEREOMODE: Integer type of stereo display algorithm to use:
%                 - 0: Monoscopic viewing
%                 - 1: Stereo output
%                 - 2: Left view compressed into top half, right view into
%                 bottom halfhsjahsjaadsdasdasdasd
%                 - 3: Left view compresse qd into bottom half, right view compressed into top half
%                 - 4: Left view is shown in left half, right view  shown in right half or the display
%                 - 5: does the opposite of 4 (cross-fusion)
%            RUNMODE: String (specifies the size of the window: EXPERIMENT: whole
%                       window, other wise: [0 0 1024 768]
%            SOUNDSAMPLERATE: Sample Rate of the sound, in Hz
%            NUM_BLOCKS: Integer (specifies number of blocks)
%            INSTRUCTIONS: String (Text that will appear in Instructions)
%            PAUSE: String (Text that will appear in Pause)
%            BYESCREEN: String (Text that will appear in Bye screen)
%
% Outputs:
%     EXPCONSTANTS:
%     BlockResults#:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars
% rmpath('C:\Users\CBCLaB_stimE\Documents\mtorralba_adrew\BR_oscillations\Subfunctions\');
% rmpath('C:\Users\CBCLaB_stimE\Documents\mtorralba_adrew\BR_oscillations\');
rmpath('/Users/ecekurnaz/Desktop/MonoBR_entrainmentLab/Subfunctions/');
rmpath('/Users/ecekurnaz/Desktop/MonoBR_entrainmentLab/Utilities/');
ioObj=0;
address=0;
disp('Entrainment experiment')

%In this path we can find all required functions to run the experiment
addpath([pwd '/Subfunctions/']);
%In this path we can find figures, drivers and all other non script
%required material for running the experiment
addpath([pwd '/Utilities/']);
addpath([pwd '/Diary/']);

timeStart = GetSecs();


fprintf('Experiment Ready...\n');
%fprintf('Press any key to continue...');
%pause;
WaitSecs(1);
%%%%%%%%%%
% InitializePP
%%%%%%%%%%
key_Proceed=KbName('space');
key_Calibration=KbName('c');
key_Training=KbName('t');
key_Experiment=KbName('e');
key_Proceed_outside=KbName('p');

%try
%% INITIAL CONFIGURATIONS
prompt={'IAF recording ID';'Number';'Age';'Recording day';'IAF position (Hz)'};
defaults={'P0000_XX_YYMMDDHHmm';'0';'10';datestr(now,'yymmddHHMM');'10'};
title='SUBJECT INFORMATION';
sj=inputdlg(prompt,title,1,defaults);


SUBJECTDATA.ID=sj{1};
SUBJECTDATA.Number=sscanf(sj{2},'%i');
SUBJECTDATA.Age=sscanf(sj{3},'%i');
SUBJECTDATA.Recording_date=sj{4};
SUBJECTDATA.IAF=sscanf(sj{5},'%f');


IAF=sscanf(sj{5},'%f');
try
    assert(IAF>0);
catch
    error('Please set a proper value for IAF!');
end
try
    assert(SUBJECTDATA.Age>0);
catch
    error('Please set the age of the participant!');
end

%prompt={'ENTER GREEN RGB VALUE (0 to 255)';'ENTER RED RGB VALUE (0 to 255)'};
%defaults={'255';'255'};
%title='ISOLUMINANCE';
%isolum=inputdlg(prompt,title,1,defaults);

%GL=sscanf(isolum{1},'%i');
%GR=sscanf(isolum{2},'%i');

%clear sj
sj=questdlg('Dominant HAND','Handeness','Left','Right','Right');
SUBJECTDATA.Dominant_Hand=lower(sj);

clear sj
sj=questdlg('Dominant EYE','Visual dominance','Left','Right','Right');
SUBJECTDATA.Dominant_Eye=lower(sj);

%mapping=questdlg('Select a response mapping','Response mapping','Up Red','Up Green','Up Red');

%SUBJECTDATA.Mapping=lower(mapping);


EXPCONSTANTS=CONSTANTS_EEG_FACES;
%Save subject info in CONSTANTS file
EXPCONSTANTS.SUBJECT_INFO=SUBJECTDATA;
%EXPCONSTANTS.Green_Level=GL;
%EXPCONSTANTS.Red_Level=GR;
EXPCONSTANTS.Entrain_mode=lower(EXPCONSTANTS.Entrain_mode);

Foi=cat(2,EXPCONSTANTS.Control,IAF+EXPCONSTANTS.Shift);%Order: Control (3Hz) IAF-2 IAF IAF+2
Amplitude=EXPCONSTANTS.Modulation;

Nreps=round(EXPCONSTANTS.NUM_BLOCKS/length(Foi));

%Foi=repmat(Foi,1,Nreps);
%Foi_order=repmat((1:length(Foi))',1,Nreps);
%idx=randperm(length(Foi));
%Foi=Foi(idx);
%Foi_order=Foi_order(idx);
Amplitude=repmat(Amplitude,1,EXPCONSTANTS.NUM_BLOCKS);
Foi_order=[];
NFoi=[];
for i=1:Nreps
    
    
    if i>1
        Last_idx=Foi_order(end)
        idx=randperm(length(Foi));
        while idx(1)==Last_idx
            idx=randperm(length(Foi));
        end
        Foi_order=cat(2,Foi_order,idx);
        NFoi=cat(2,NFoi,Foi(idx));
    else
        idx=(randperm(length(Foi)));
        Foi_order=cat(2,NFoi,idx);
        NFoi=cat(2,NFoi,Foi(idx));
    end
end

Foi=NFoi;

%clear GL GR

% %switch mapping
%     case 'Up Red'
%         EXPCONSTANTS.key_Gabor=EXPCONSTANTS.key_Up;
%         EXPCONSTANTS.key_Radial=EXPCONSTANTS.key_Down;
%         EXPCONSTANTS.INSTRUCTIONS1=EXPCONSTANTS.INSTRUCTIONS1_map1;
%         EXPCONSTANTS.INSTRUCTIONS2=EXPCONSTANTS.INSTRUCTIONS2_map1;
%         EXPCONSTANTS.AFTER_PAUSE=EXPCONSTANTS.AFTER_PAUSE_map1;
%         Triggers.Mapping=EXPCONSTANTS.Map_1;
%     case 'Up Green'
%         EXPCONSTANTS.key_Gabor=EXPCONSTANTS.key_Down;
%         EXPCONSTANTS.key_Radial=EXPCONSTANTS.key_Up;
%         EXPCONSTANTS.INSTRUCTIONS1=EXPCONSTANTS.INSTRUCTIONS1_map2;
%         EXPCONSTANTS.INSTRUCTIONS2=EXPCONSTANTS.INSTRUCTIONS2_map2;
%         EXPCONSTANTS.AFTER_PAUSE=EXPCONSTANTS.AFTER_PAUSE_map2;
%         Triggers.Mapping=EXPCONSTANTS.Map_2;
% end


%Create the diary
%     fileNameDiary=['Diary\ConstantsSub' SUBJECTDATA{1,1}];
%     diary (fileNameDiary)
%     diary on

%Save the CONSTANTS file
fileNameConstants=['Results\Constants_' SUBJECTDATA.ID '.mat'];
fileName2=['Results\Alternation_' SUBJECTDATA.ID '.mat'];

fprintf('\n Save CONSTANTS file.. \n')
save(fileNameConstants,'SUBJECTDATA','EXPCONSTANTS');
fprintf('\n Done! \n')

%% Parallel port initialization

% Let's initialize the parallel port and the addresses to write. In the
% offline paradigm we only talk with the first 8 bits.
%create an instance of the io64 object

%Comment here when you are upstairs
   ioObj = io64;

%initialize the interface to the inpoutx64 system driver
status = io64(ioObj);

if status==0
   disp('The parallel port is ready');
else
  clear io64
  ioObj = io64;
 status = io64(ioObj);

end

address = hex2dec('378');          %standard LPT1 output port address

%Comment up to here when you are upstairs

% We write decimal values to the parallel port!!!
%io64(ioObj,address,0);   %Clean parallel port, just in case there was something written in
%WaitSecs(0.01);

%%

ListenChar(2);

%INITIALIZE SCREEN
[EXPCONSTANTS.SCREENPOINTER, EXPCONSTANTS.SCREENRECT] = InitializeScreen(EXPCONSTANTS.SCREENNUMBER,EXPCONSTANTS.BACKGROUNDCOLOR,...
    EXPCONSTANTS.REFRESHRATEHZ,EXPCONSTANTS.TOLERANCEHZ,...
    EXPCONSTANTS.DRAWREGIONSIZE,...
    EXPCONSTANTS.FONT,EXPCONSTANTS.FONTSIZE,EXPCONSTANTS.STYLE,EXPCONSTANTS.STEREOMODE,EXPCONSTANTS.RUNMODE);
screenPointer= EXPCONSTANTS.SCREENPOINTER;

Calibration=true;
switch EXPCONSTANTS.Num_training_blocks
    case 0
        Training=false;
    otherwise
        Training=true;
end
%Alternate buffer presentation side
Nbuffer=ceil(EXPCONSTANTS.NUM_BLOCKS/2);
Randomized_buffer=repmat(randperm(2)-1,1,Nbuffer);
%try
    
    while Calibration
        %% CALIBRATE MIRRORS FUNCTION
        ShowTextSpace(screenPointer,EXPCONSTANTS.INSTRUCTIONS_CALIBRATION,true,EXPCONSTANTS.TEXTCOLOR);
        fprintf('Calibrate Mirrors function, press space bar to finish \n\n');
     [~ ,~, EXPCONSTANTS.ASPECT_RATIO, EXPCONSTANTS.MONDRIAN_TEXTURE_DIM]= CalibrateMirrors2(EXPCONSTANTS.SCREENPOINTER,EXPCONSTANTS);
%     WaitSecs(2)
        %[Training, Calibration, Experiment]=Experiment_options(key_Calibration, key_Training, key_Experiment);
        while Training
            show_mode='red';
            Instruction_with_picture(EXPCONSTANTS,0,1,show_mode);
            
            show_mode='green';
            Instruction_with_picture(EXPCONSTANTS,0,1,show_mode);
            for num_training=1:EXPCONSTANTS.Num_training_blocks
                ShowTextSpace(screenPointer,EXPCONSTANTS.INSTRUCTIONS_ALTERNATION,true,EXPCONSTANTS.TEXTCOLOR);
                %We do not mark the training triggers
                EXPCONSTANTS.Triggers=[0 0 0 0];
                
                disp(['This is training block ' num2str(num_training)]);
                %Here we do not control for half and half of presentations,
                %we just take random numbers for the buffers
                Buffer1=randi(2)-1;
                Buffer2=1-Buffer1;
                EXPCONSTANTS.Start_trigger=0;
                EXPCONSTANTS.End_trigger=0;
                EXPCONSTANTS.Entrain_trigger=0;
                %Alternation_EEG_2(EXPCONSTANTS,Buffer1,Buffer2,'training',ioObj,address);
                EXPCONSTANTS.Frequency=5+randi(5);
                EXPCONSTANTS.Amplitude=EXPCONSTANTS.Modulation;
                EXPCONSTANTS.Start_block=0;
                EXPCONSTANTS.End_block=0;
                Alternation_EEG_2_Entrain_2(EXPCONSTANTS,Buffer1,Buffer2,'training',ioObj,address);
                
            end
            %fprintf('Training, press "0" key to finish or "q" to quit \n\n');
            %Training=Repeat_training(key_Training,key_Proceed);
            %ShowTextSpace(screenPointer,EXPCONSTANTS.INSTRUCTIONS_CALIBRATION,true,EXPCONSTANTS.TEXTCOLOR);
            %if Training
            %ShowTextSpace(screenPointer,EXPCONSTANTS.AFTER_PAUSE,true);
            %fprintf('Calibrate Mirrors function, press space bar to finish \n\n');
            %[EXPCONSTANTS.FIXATION_CENTRE_B0 ,EXPCONSTANTS.FIXATION_CENTRE_B1, EXPCONSTANTS.ASPECT_RATIO, EXPCONSTANTS.MONDRIAN_TEXTURE_DIM]= CalibrateMirrors2(EXPCONSTANTS.SCREENPOINTER,EXPCONSTANTS);
            
            WaitSecs(2)
        end
        Calibration=Experiment_options(key_Calibration, key_Proceed_outside);
    end
    %Give a chance to repeat calibration before experiment
    %Calibration=Experiment_options(key_Calibration, key_Proceed_outside);
    
    %% FISRT ALTERNANCE FUNCTION
    %end
    
    %if Calibration
    %ShowTextSpace(screenPointer,EXPCONSTANTS.INSTRUCTIONS_CALIBRATION,true,EXPCONSTANTS.TEXTCOLOR);
    %fprintf('Calibrate Mirrors function, press space bar to finish \n\n');
    %[EXPCONSTANTS.FIXATION_CENTRE_B0 ,EXPCONSTANTS.FIXATION_CENTRE_B1, EXPCONSTANTS.ASPECT_RATIO, EXPCONSTANTS.MONDRIAN_TEXTURE_DIM]= CalibrateMirrors2(EXPCONSTANTS.SCREENPOINTER,EXPCONSTANTS);
    % WaitSecs(2)
    %end
    
    %Now we start the experimental block
    sim_block=0;
    % SimulatedData=[];
    main_counter=0;
    
    %Get the names of the images here
    F1N=imread(fullfile('Utilities', 'F1N.jpg'));
    F2N=imread(fullfile('Utilities', 'F2N.jpg'));
    F1F=imread(fullfile('Utilities', 'F1F.jpg'));
    F2F=imread(fullfile('Utilities', 'F2F.jpg'));
    M1N=imread(fullfile('Utilities', 'M1N.jpg'));
    M2N=imread(fullfile('Utilities', 'M2N.jpg'));
    M1F=imread(fullfile('Utilities', 'M1F.jpg'));
    M2F=imread(fullfile('Utilities', 'M2F.jpg'));
    
    obj1=imread(fullfile('Utilities', 'o1.jpg'));
    obj2=imread(fullfile('Utilities', 'o2.jpg'));
    obj3=imread(fullfile('Utilities', 'o3.jpg'));
    obj4=imread(fullfile('Utilities', 'o4.jpg'));
    entrainment_freq=6;
    entrainment_freq2=5;
    face_train= F1N;
    obj_train=obj3;
    
%     FIN_lum=F1N*1.25;
%     F2N_lum=F2N*1.25;
%     FIF_lum=F1F*1.25;
%     F2F_lum=F2F*1.25;
%     MIN_lum=M1N*1.25;
%     MIF_lum=M1F*1.25;
%     M2N_lum=M2N*1.25;
%     M2F_lum=M2F*1.25;
%     obj1_lum=obj1*1.25;
%     obj2_lum=obj2*1.25;
%     obj3_lum=obj3*1.25;
%     obj4_lum=obj4*1.25;
    
    % Define the image sets
face_images = {F1N, F2N, M1N, M2N, F1F, F2F, M1F, M2F};
code_face=[1 1 1 1 2 2 2 2]; %1 for natural, 2 for fearful
code_side=[0 1]; %0 for left, 1 for right;
object_images = {obj1, obj2, obj3, obj4,obj1, obj2, obj3, obj4};

% Create the pairs and assign triggers
pairs = cell(16,2);
triggers = zeros(1, length(face_images));

for i = 1:8
    pairs{i,1} = face_images{i};
    pairs{i,2} = object_images{i};
    pairs{i+8,1} = object_images{i};
    pairs{i+8,2} = face_images{i};
    
    pairs{i,3}=code_face(i)+code_side(1);
    pairs{i+8,3}=code_face(i)+2*code_side(2);
   
end

order_of_call=randperm(size(pairs,1));
%TRAINING BLOCK ADDED
ShowTextSpace(screenPointer,EXPCONSTANTS.INSTRUCTIONS_TRAINING,true,EXPCONSTANTS.TEXTCOLOR);
disp(['This is a training block' ]);

EXPCONSTANTS.Start_trigger=0;
EXPCONSTANTS.End_trigger=0;
%Set the rest of triggers to 0
Alternation_EEG_2_Entrain_2(EXPCONSTANTS,face_train, face_train*EXPCONSTANTS.Luminance,obj_train,obj_train*EXPCONSTANTS.Luminance, entrainment_freq, entrainment_freq2, 'nat', ioObj, address);
%TRAINING BLOCK DONE
    for i=1:EXPCONSTANTS.NUM_BLOCKS
        %Perform a BR block
        WaitSecs(0.2);
        FlushEvents;
        
        trial_index=order_of_call(i);
        if trial_index <= 8  
          entrainment_freq= 6;
           entrainment_freq2=5;
            
        else
          entrainment_freq= 5;
          entrainment_freq2=6;
           
        end
       
       

        % Get the face and object images for this pair
        face_image = pairs{trial_index,1};
        object_image = pairs{trial_index,2};
        triggers = pairs{trial_index,3};
        ShowTextSpace(screenPointer,EXPCONSTANTS.AFTER_PAUSE_map1,true,EXPCONSTANTS.TEXTCOLOR);
        main_counter=main_counter+1;
        disp(['This is experimental block' num2str(i)]);
        Buffer1=Randomized_buffer(i);
        Buffer2=1-Buffer1;
        disp([' Red will be placed in buffer ' num2str(Buffer1)]);
        %disp(['The entraining frequency is ' num2qqstr(Foi(i))]);
        %Triggers: Both Red Green None
     
        EXPCONSTANTS.Start_trigger= triggers; %Change to the appropiate one (1 to 225)
        EXPCONSTANTS.End_trigger=100; %Make sure is different from the
        Alternation_EEG_2_Entrain_2(EXPCONSTANTS,face_image, face_image*EXPCONSTANTS.Luminance,object_image,object_image*EXPCONSTANTS.Luminance, entrainment_freq, entrainment_freq2, 'nat', ioObj, address);

        %if i<EXPCONSTANTS.NUM_BLOCKS
        
        Calibration=Experiment_options(key_Calibration, key_Proceed_outside);
        %end
        
           if Calibration
            fprintf('Calibrate Mirrors function, press space bar to finish \n\n');
            ShowTextSpace(screenPointer,EXPCONSTANTS.INSTRUCTIONS_CALIBRATION,true,EXPCONSTANTS.TEXTCOLOR);
            [EXPCONSTANTS.FIXATION_CENTRE_B0 ,EXPCONSTANTS.FIXATION_CENTRE_B1, EXPCONSTANTS.ASPECT_RATIO, EXPCONSTANTS.MONDRIAN_TEXTURE_DIM]= CalibrateMirrors2(EXPCONSTANTS.SCREENPOINTER,EXPCONSTANTS);
            WaitSecs(2)
        end
        
        
        %clear key_press_stored T_alternation T0
        
        
    save([SUBJECTDATA.ID '_LOG.mat'],"order_of_call", "EXPCONSTANTS","SUBJECTDATA")   
        
    end
    
    
    
    
    clear key_press_stored T_alternation switch_time absolute_time relative_key_switching_time switch_key EXPCONSTANTS.TRAINING_TIME finalDomTime finalSupTime
    
    
    %% END OF BLOCKS
    
    
    
    
    ShowTextSpace(screenPointer,EXPCONSTANTS.BYESCREEN,true,EXPCONSTANTS.TEXTCOLOR);
    timeFinish = GetSecs();
    fprintf('\n\n Experiment total duration (in secs): \n')
    disp(timeFinish-timeStart)
    
    % Close Screen and PortAudio
    Screen('CloseAll');
    diary off
    %Comment here when you are upstairs
    clear io64;
    %Comment up to here
% catch err
%     
%     fprintf(2,'ERROR!!!! Experiment has finished uncorrectly!!!!!\n');
%     diary off
%     Screen('CloseAll');
%     ListenChar(1);
%     %    rethrow(err);
%     clear io64;
% end

ListenChar(1);

fprintf('\n\n\n Experiment has finished...\n');

fprintf('Done!');





%end