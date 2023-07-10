function Calibration=Experiment_options(key_Calibration, key_Experiment)

 RestrictKeysForKbCheck([key_Calibration key_Experiment]);
     fprintf(['Press ' KbName(key_Calibration) ' for repeating calibration \n']);
     fprintf(['Press ' KbName(key_Experiment) ' to continue \n']);
     FlushEvents;
     WaitSecs(0.25);
     [~,code]=KbWait;
     code=find(code);
     Calibration=isequal(code,key_Calibration);
     FlushEvents;
     
 end