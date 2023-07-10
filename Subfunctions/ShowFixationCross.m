function [onsetTime] = ShowFixationCross(windowPtr,BUFFER_MD,BUFFER_LD,EXPCONSTANTS)

% Use this function to display a Fixation Cross on two different buffers
% using stereoMode configuration

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Inputs:
%       windowPtr: Integer (number that designates the window that you want to use)
%       BUFFER_MD: Integer (number that designates one of the buffers)
%       BUFFER_LD: Integer (number that designates one of the buffers)
%       EXPCONSTANTS: structure containing with at least following fields:
%               FIXATION_COLOUR: Integer (fixation cross colour in grey scale) 
%                                    or Integer 1x3 (fixation cross colour with RGB indexes)   
%               FIXCROSSLONG: Integer (how long is the fixation cross, in pixels)
%               BACKGROUNDCOLOR: Integer (window background colour in grey scale) 
%                                    or Integer 1x3 (window background colour with RGB indexes)  
%               FIXCROSSWIDE: Integer (how wide is the fixation cross, in pixels)                  
%               FIXATION_CENTRE_B0: Integer 2x1 (left buffer center)
%               FIXATION_CENTRE_B1: Integer 1x2 (right buffer center)
%
% Outputs:
%       onsetTime: Float (estimate of Stimulus-onset time)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



    
    %EXPCONSTANTS.FIXATION_COLOUR= [0 255 0];
    [width, height]=Screen('WindowSize', windowPtr);
    EXPCONSTANTS.FIX_POSITION=[-EXPCONSTANTS.FIXCROSSLONG,EXPCONSTANTS.FIXCROSSLONG,0,0;0,0,-EXPCONSTANTS.FIXCROSSLONG,EXPCONSTANTS.FIXCROSSLONG];
    EXPCONSTANTS.FIX_POSITION=EXPCONSTANTS.FIX_POSITION+0.5*[width width width width; height height height height];

    %Draw in Dense Buffer
    Screen('SelectStereoDrawBuffer', windowPtr, BUFFER_MD); %Buffer Dense
    Screen('FillRect', windowPtr, EXPCONSTANTS.BACKGROUNDCOLOR);
    Screen('DrawLines',windowPtr,EXPCONSTANTS.FIX_POSITION,EXPCONSTANTS.FIXCROSSWIDE,EXPCONSTANTS.FIXATION_COLOUR,EXPCONSTANTS.FIXATION_CENTRE_B0');
 
    %Draw in LessDense Buffer
    Screen('SelectStereoDrawBuffer', windowPtr, BUFFER_LD);%Buffer Less Dense
    Screen('FillRect', windowPtr,EXPCONSTANTS.BACKGROUNDCOLOR);
    Screen('DrawLines',windowPtr,EXPCONSTANTS.FIX_POSITION,EXPCONSTANTS.FIXCROSSWIDE,EXPCONSTANTS.FIXATION_COLOUR,EXPCONSTANTS.FIXATION_CENTRE_B1');
      
    onsetTime = Screen('Flip', windowPtr);


end