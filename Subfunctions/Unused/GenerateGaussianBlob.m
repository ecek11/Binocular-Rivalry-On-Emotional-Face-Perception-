function noised_patch = GenerateGaussianBlob(Gabor,contrast,orientation)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%--- Description 
% February 2013 Modified to present any background color
%
% Generate Gaussian-windowed sinusoidal grating or simply Gabor patch with
% gaussian noise 
%
% --- Implementation
% 09.07.08, Arman: adopted from Colin's original code
% 28.07.08, Arman: added [0 255] to imagesc command to have proper colour scaling
% 01.07.14, Torralba: added the option of blurring the patch with gaussian,
%                     noise, fix the colour scaling in order to be able to
%                     create gabor patches on different background scales

% --- Input arguments
%Gabor structure
%   spFrequency: spatial frequency - in cycles per pixel
%   Sigma: sigma value - standard deviation of the Gaussian window in pixels 
%   Size: TotalGsize - image size, N x N
%   Phase: phase - in cycles, from 0 to 1
%   Background: RGB background color
%   NoiseLevel:  In dB
%   blob:  true: apply gaussian blog, 0: do not apply gaussian blob
%   display:  1: plot the patch, 0: do not plot
%   contrast: float ranging from 0 to 1
%   orientation: float, tilting of the patch in degrees
%
% --- Output argument
%noised_patch: 2Nx2N matrix of Gabor patch (containing values scaled from 0 to 255) 
%
% --- Let's start
% If some of the input arguments are not specified, default values are assigned
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

background=Gabor.Background;
phase=Gabor.Phase;
TotalGsize=Gabor.Size;
sigma=Gabor.Sigma;
spatialFrequency=Gabor.spFrequency;
blob=Gabor.blob;


%scale contrast to values allowed by background


gsize=0.5*TotalGsize;

% Initialise output argument
gaborPatch = zeros(2*gsize+1);
% Vector, from 0 to size, to calculate 1D Gaussian mask
index = 0:(2*gsize);
% Calculate 1D Gaussian mask 
gaussianDistribution = exp(-0.5*(index - gsize).^2 / sigma^2);
%plot(index, gaussianDistribution, '-r');

% Calculate sinusoidal grating in 2D
for indexX = 0:(2*gsize)
    for indexY = 0:(2*gsize)
        gaborPatch(indexX+1, indexY+1) = cos(2*pi*(cos(2*pi*orientation./360)*spatialFrequency*(indexX-gsize)+sin(2*pi*orientation./360)*spatialFrequency*(indexY-gsize)+phase));
    end
end

% Calculate 2D Gaussian blob
gaborPatch= round(background*(gaborPatch'.*contrast+1));


%% Add the noise

Gaussian_noise=wgn(size(gaborPatch,1),size(gaborPatch,2),Gabor.NoiseLevel);
Gaussian_noise=Gaussian_noise*Gabor.Background;
%Add noise but keep within limits
noised_patch=min(255,max(gaborPatch+Gaussian_noise,0))/255;




%gaborPatch=gaborPatch+Gaussian_noise;

% Multiply sinusoidal grating by 2D Gaussian blob
 if blob
 gaussianBlob = gaussianDistribution' * gaussianDistribution;
% %gaborPatch = gaborPatch.*gaussianBlob;
% noised_patch=noised_patch.*gaussianBlob;
noised_patch=(1-gaussianBlob)*Gabor.Background/255+gaussianBlob.*noised_patch;
 end

 noised_patch=round(noised_patch*255);
%noised_patch= round(background*(noised_patch'.*contrast+1));

% Scale output between 0 & 255 and apply contrast
%gaborPatch = round(gaborPatch'.*(127*contrast)+128);

%gaborPatch = round(gaborPatch'.*(step_max*contrast)+background);
%Scale output between background-stepmax and background+stepmax




% if (display)
%     imagesc(noised_patch, [0 255]);
%     axis off; axis image; colormap gray(256); % no axis, X & Y axis equal, 256 grayscale colormap
%     set(gca, 'pos', [0 0 1 1]); % no borders on display window
%     set(gcf, 'menu', 'none', 'Color', [0.5 0.5 0.5]); 
% end


return;








