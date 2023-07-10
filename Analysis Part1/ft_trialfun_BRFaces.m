function trl=ft_trialfun_BRFaces(cfg)


hdr=ft_read_header(cfg.headerfile);
event=ft_read_event(cfg.eventfile);

trl=[];
for ev=1:length(event)-1
   if strcmp(event(ev).type,cfg.trialdef.eventtype)
       if any(strcmp(event(ev).value,cfg.trialdef.eventvalue))
       
          trial_type=100+find(strcmp(event(ev).value,cfg.trialdef.eventvalue))-1;
          if any(find(strcmp(event(ev+1).value,cfg.trialdef.eventvalue)))
               new_trl=[event(ev).sample event(ev+1).sample-1 0 trial_type]; 
               trl=cat(1,trl,new_trl);
       end
   end
   end     
end    
end