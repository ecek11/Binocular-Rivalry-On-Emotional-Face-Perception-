function [Training]=Repeat_training(key_Training, key_proceed)

 RestrictKeysForKbCheck([key_Training key_proceed]);
     fprintf(['Press ' KbName(key_Training) ' for repeating both calibration and training \n']);
     fprintf(['Press ' KbName(key_proceed) ' for ending training \n']);
     FlushEvents;
     WaitSecs(0.25);
     [~,code]=KbWait;
     code=find(code);
     Training=isequal(code,key_Training);
     
end