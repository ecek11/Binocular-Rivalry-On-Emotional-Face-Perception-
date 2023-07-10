function delta_contrast=get_contrasts(EXPCONSTANTS)
%Gaussian modulation of contrast

%Duration: 7 timepoints (60 ms=15 Hz cycle minus 1 point)

tois=-3:1:3;
sigma=EXPCONSTANTS.Contrast_std;
delta_contrast=EXPCONSTANTS.Amplitude*exp(-(tois/(2*sigma)).^2);
if size(delta_contrast,2)>size(delta_contrast,1)
    delta_contrast=delta_contrast';
end

delta_contrast=cat(1,delta_contrast,0);

