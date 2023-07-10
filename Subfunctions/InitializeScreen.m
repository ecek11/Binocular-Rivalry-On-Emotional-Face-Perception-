function [screenPointer, screenRect] = InitializeScreen(scrnNum,backgroundColor,expectedRefreshRateHz,refreshToleranceHz,~,font,fontSize,fontStyle,stereoMode,runMode)

% Use this function to open a window following Stereomode configuration and using some specific
% parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Inputs:
%       scrnNum: Integer (specifies a screen: 0 is the main screen)       
%       backgroundColor: Integer scalar or 1x3 [r g b] (specify the colour
%       of the window background)
%       expectedRefreshRateHz: Integer (expected refresh rate in Hz)
%       refreshToleranceHz: Integer (specifies the tolerance with refresh rate)
%       expectedSize: Integer 1x2 (expected window size)             
%       font: String (specify font name) 
%       fontSize: Integer (size of the font)
%       fontStyle: String (specifies font style: 0=normal,1=bold,2=italic,4=underline,8=outline,32=condense,64=extend)
%       stereoMode: Integer (specifies the type of stereo display algorithm
%       to use)
%       runMode: String (specifies the size of the window: EXPERIMENT: whole
%       window, otherwise: [0 0 1024 768]
%
% Outputs:
%       screenPointer: Integer (number that designates the window you just created)
%       screenRect: Interger 1x2 (size of new window)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Define some parameters to optimize stimulus presentation
Screen('Preference', 'ConserveVRAM', 4096);
Screen('Preference', 'SkipSyncTests', 0);
Screen('Preference', 'VisualDebuglevel', 3);
Screen('Preference', 'Verbosity', 0);


% INITIALIZE SCREEN FOR STEREOMODE
 AssertOpenGL;
 try
PsychImaging('PrepareConfiguration');
 catch
     0;
 end


% PsychImaging('AddTask', 'AllViews', 'RestrictProcessing', CenterRect([0 0 ROI ROI], Screen('Rect', scrnNum)));
%  [screenPointer, screenRect] = PsychImaging('OpenWindow', scrnNum, backgroundColor, [], [], [], stereoMode);
switch runMode
    case 'EXPERIMENT'
        try
    [screenPointer, screenRect] = PsychImaging('OpenWindow', scrnNum, backgroundColor, [], [], [], stereoMode);
        catch      
    [screenPointer, screenRect] = Screen('OpenWindow', scrnNum, backgroundColor, [], [], [], stereoMode);
        end
    otherwise
        try
           % [screenPointer, screenRect] = PsychImaging('OpenWindow', scrnNum, backgroundColor, [0 0 1024 768]*0.75, [], [], stereoMode);
                 [screenPointer, screenRect] = PsychImaging('OpenWindow', scrnNum, backgroundColor, [0 0 1024 768], [], [], stereoMode);
       
        catch
        %[screenPointer, screenRect] = Screen('OpenWindow', scrnNum, backgroundColor, [0 0 1024 768]*0.75, [], [], stereoMode); 
            [screenPointer, screenRect] = Screen('OpenWindow', scrnNum, backgroundColor, [0 0 1024 768], [], [], stereoMode);   
       end
        
end

%Maximum priority to experiment screen
Priority(MaxPriority(screenPointer));

refresh=Screen('GetFlipInterval',screenPointer);
disp(['Frame duration is ' num2str(refresh) ' seconds']);

refreshHz = 1/refresh;
disp(['Refresh rate is ' num2str(refreshHz) ' Hz']);


upTol = expectedRefreshRateHz+refreshToleranceHz;
lowTol = expectedRefreshRateHz-refreshToleranceHz;

if ~(lowTol<refreshHz&&refreshHz<upTol)
    error('InitalizeScreen:IncorrectRefreshRate','Refresh rate is %d Hz. Expected rate %d Hz with a tolerance of %d.',refreshHz,expectedRefreshRateHz,refreshToleranceHz);
end



Screen('TextFont',screenPointer, font);
Screen('TextSize',screenPointer, fontSize);
Screen('TextStyle', screenPointer, fontStyle);

HideCursor;



end