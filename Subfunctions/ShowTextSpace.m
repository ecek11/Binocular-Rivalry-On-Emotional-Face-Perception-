function ShowTextSpace(screenPointer, text, wait,color)

% Use this this function to display a text in a window

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Inputs:
%       screenPointer: Integer (number that designates the window that you want to use)
%       text: String (the text that will appear in the window)
%       wait: Integer (0: no keyboard waiting, 1: there is a keyboard
%           waiting)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[width, height]=Screen('WindowSize', screenPointer);

keySpace=KbName('space');  
RestrictKeysForKbCheck(keySpace);
%Screen('SelectStereoDrawBuffer', screenPointer,0); %Buffer 0  
[~, ~, ~] = DrawFormattedText(screenPointer, text, 'center', 'center', color, 70,[],[],[],[],[0 height width/2 0]);
%Screen('SelectStereoDrawBuffer', screenPointer,1); %Buffer 0  
[~, ~, ~] = DrawFormattedText(screenPointer, text, 'center', 'center', color, 70,[],[],[],[],[width/2 height width 0]);
Screen('Flip',screenPointer);
keepwaiting=0;
if wait
    while not(keepwaiting)
        [~, ~, keyCode] = KbCheck;
        keepwaiting=keyCode(keySpace);
    end
end

end