clear
%% %Preprocessing
addpath('/Users/ecekurnaz/Desktop/fieldtrip-20220707');
addpath('/Users/ecekurnaz/Desktop/Behavioral Data/trainClassifier.m');
ft_defaults


load('dataFFL_KS.mat')
load('dataFFR_KS.mat')
load('dataFNL_KS.mat')
load('dataFNR_KS.mat')


% %Load the data you will use for the classifier
% %Append FFL data
% dataFFL = ft_appenddata([], dataFFL, dataFFL_SMA);
% 
% %Append FFR data
% dataFFR = ft_appenddata([], dataFFR, dataFFR_SMA);
% 
% %Append FNL data
% dataFNL = ft_appenddata([], dataFNL, dataFNL_SMA);
%  
% %Append FNR data
% dataFNR = ft_appenddata([], dataFNR, dataFNR_SMA);

data0=ft_appenddata([],dataFFL,dataFFR,dataFNL,dataFNR);

clear dataF*

Fs=data0.fsample;
%Select the size of the time window for classification
Twin=0.02; %In seconds /changable 
%Select electrodes used in the classification
ROI='all'; %Other options: 'all';
%Number of cycles for performing STFT, changed this 
N=20;
%Dcreasing temporal resolution (too large datasets)
step=5;


cfg=[];
cfg.reref='yes';
cfg.refchannel=ft_channelselection({'M*'},data0.label);%Use Mastoids for the reference
cfg.dftfilter   = 'yes';                            % application of a line noise filter
cfg.dftfreq     = 50;                  % frequency which get excluded as line noise
cfg.detrend     = 'yes';                             % removing of linear trends
cfg.demean      = 'yes';                             % setting of the baseline correction
cfg.hpfilter    = 'yes';                            % High-Pass-Filter On
cfg.hpfiltdir   ='twopass';                         % Forward filtering.
cfg.hpfreq      = 0.1;                              % High-Pass Frequency
cfg.hpfilttype  = 'but';                            % Filter Type Butterworth (IIR)
cfg.hpfiltord   = 2;                               % Filter Order, watch out for Instability!
cfg.lpfilter    = 'yes';                            % Low-Pass Filter On
cfg.lpfiltdir   ='twopass';                         % Forward filtering.
cfg.lpfreq      = 40;  % Low-Pass Frequency
cfg.lpfilttype  = 'but';'fir';                            % Filter Type
cfg.lpfiltord     = 8;
data=ft_preprocessing(cfg,data0);

data=rmfield(data,'cfg');


cfg=[];
switch ROI
    case 'all'
        cfg.channel=ft_channelselection({'all','-M*','-H*','-V*'},data.label);
    case 'PO'
        cfg.channel=ft_channelselection({'O*','PO*'},data.label);
end
data=ft_selectdata(cfg,data);

% switch ROI
%     case 'all'
%         cfg.channel = ft_channelselection({'all','-M*','-H*','-V*'}, data.label);
%     case 'PO'
%         cfg.channel = ft_channelselection({'P7', 'P9', 'PO7', 'PO9', 'PO11', ...
%             'P8', 'P10', 'PO8', 'PO10', 'PO12'}, data.label);
%     case 'OT'
%         cfg.channel = ft_channelselection({'P5', 'P6', 'P7', 'P8', 'P03', 'P10', ...
%             'PO5', 'POz', 'Pz', 'PO7', 'PO7', 'PO8', 'PO4', 'PO6', ...
%             'Fz', 'FCz', 'Cz', 'CPz', 'O1', 'O2', ...
%             'POI1', 'POI2', 'I1', 'I2', 'POz', 'POOz', 'Oz', 'Oz'}, ...
%             data.label);
% end

data = ft_selectdata(cfg, data);

%% Artifact Rejection 

cfg = [];
cfg.viewmode = 'vertical';
artf = ft_databrowser(cfg, data);

artf.reject='none';
data=ft_rejectartifact(artf,data);
disp(data);

% Save the cleaned data to a file
save('cleaned_data_SM.mat', 'data');
disp('Artifact-cleaned data saved.');

%% 
% Load the cleaned data
% load('cleaned_data_SM.mat');  % Load the first data structure
% data_SM = data;  % Rename the variable to data_SM1
load('cleaned_data_KS.mat'); 
data_KS = data; 
data=ft_appenddata([],data_KS);

%% Get the triggers for keypress response
cfg=[];
fname=fullfile('/Users/ecekurnaz/Desktop/Behavioral Data','pilot005_KS_202306131510');
cfg.datafile=[fname '.eeg'];
cfg.eventfile=[fname '.vmrk'];
cfg.headerfile=[fname '.vhdr'];
cfg.trialdef.eventtype='Stimulus';
cfg.trialdef.eventvalue={'S100' 'S101' 'S102' 'S103'};
cfg.trialfun='ft_trialfun_BRFaces';
cfg=ft_definetrial(cfg);
trl_mat=cfg.trl;

%%

%Obtain time resolved power (elliminate first 5 and last 5 seconds for the
%analysis to avoid including the effect of timepoints where no entrainment is
%happening).
cfg=[];
cfg.method='mtmconvol';
cfg.foi=2:1:30;
cfg.t_ftimwin=N./cfg.foi;
%cfg.t_ftimwin = ones(size(cfg.foi)) * 1; % Set window length to 1 second for all frequencies
%cfg.tapsmofrq = 0.5; % Set 50% overlap (smoothness) for the windows
cfg.toi=5:step/Fs:95;
cfg.keeptrials='yes';
cfg.taper='hanning';
cfg.output='fourier';
fr=ft_freqanalysis(cfg,data);

fr=rmfield(fr,'cfg');

%% 
%Now we will get the part of the data that is aligned to the entrainment
%signal
input_5=wrapTo2Pi(2*pi*5*fr.time);
input_6=wrapTo2Pi(2*pi*6*fr.time);


[~,idx5]=min(abs(fr.freq-5));
[~,idx6]=min(abs(fr.freq-6));

fr0=fr;
for trl=1:size(fr.fourierspctrm,1)
    for lb=1:size(fr.fourierspctrm,2)
        %Align 5 and 6 Hz with entraining signal
        phase_diff_5=wrapTo2Pi(angle(squeeze(fr0.fourierspctrm(trl,lb,1,:)))-input_5');
        phase_diff_6=wrapTo2Pi(angle(squeeze(fr0.fourierspctrm(trl,lb,1,:)))-input_6');
        fr.powspctrm(trl,lb,1,:)=squeeze(abs(fr0.fourierspctrm(trl,lb,1,:))).*cos(phase_diff_5);
        fr.powspctrm(trl,lb,2,:)=squeeze(abs(fr0.fourierspctrm(trl,lb,1,:))).*cos(phase_diff_6);
        %Also get wideband spectrum to compare values at 5 and 6 with
        %overall power values
        fr.powspctrm(trl,lb,3,:)=squeeze(mean(abs(fr0.fourierspctrm(trl,lb,[1:idx5-1 idx6+1:end],:))));
    end
end

clear fr0;

%% 
%Average power longer time windows to increase SNR of power estimations
Ntwins=floor((95-5)/Twin);
Nsamples=round(Twin*Fs/2);
clear P T
%Obtain averaged power
for n=1:Ntwins-1
    T0=(n-1)*Twin;
    Tf=T0+Twin;
    [~,idx]=min(abs(fr.time-T0));
    [~,idx2]=min(abs(fr.time-Tf));
    P(n,:,:,:)=squeeze(mean(fr.powspctrm(:,:,:,idx:idx2),4));
    T(n)=fr.time(1)+T0+0.5*Twin;
end

clear fr
%% % Concanate in the case with no-report
Power_matrix_tmp=[];
Label=nan(size(P,1),size(P,2));


for t=1:size(P,1)
    for trl=1:size(P,2)
        tmp=squeeze(P(t,trl,:,:));
        Power_matrix_tmp=cat(2,tmp(:,1)',tmp(:,2)',tmp(:,3)');
        Label(t,trl)= predict(trainedModel.ClassificationDiscriminant,Power_matrix_tmp);
    end
end

%% 
plot(T,Label(:,7))
ylim([100 103])
%% 
% Assuming your MATLAB matrix is named "data"
filename = 'output_label4.csv';  % Specify the desired filename

% Write the matrix to a CSV file
writematrix(transposed_Percept, filename);

%% 
%Get the percept that was dominant during the window of interest
for trl=1:size(P,2)
    T0=data.sampleinfo(trl,1);
    Tf=data.sampleinfo(trl,2);
    selected=trl_mat((trl_mat(:,1)>T0 & trl_mat(:,2)<Tf),[1 2 4]);
    selected(:,1:2)=selected(:,1:2)-T0;
    percept=nan(length(data.time{trl}),1);
    for t=1:length(selected)
        percept(selected(t,1):selected(t,2))=selected(t,3);
    end
    
    for t=1:size(P,1)
        [~,idx]=min(abs(T(t)-0.5*Twin-data.time{trl}));
        [~,idx2]=min(abs(T(t)+0.5*Twin-data.time{trl}));
        
        tmp=percept(idx:idx2);
        Percept(trl,t)=mode(tmp);
    end
    
end
%% 

transposed_Percept = Percept.';

%% 
plot(T,Percept(7,:))
ylim([101 102])


%% %Now create the matrix containing the features (power x channel x freq
%band) and the vector containing the labels
Power_matrix=[];
Percept_vector=[];


for t=1:size(P,1)
    for trl=1:size(P,2)
        tmp=squeeze(P(t,trl,:,:));
        Power_matrix=cat(1,Power_matrix,cat(2,tmp(:,1)',tmp(:,2)',tmp(:,3)'));
        Percept_vector=cat(1,Percept_vector,squeeze(Percept(trl,t)));
    end
end


%Get rid of epochs where there was not a clear decision on the percept or
%that have nan values (edges or artifacts, when marked).
idx=~isnan(Percept_vector) | ~isnan(Power_matrix(:,1));
Percept_vector=Percept_vector(idx);
Power_matrix=Power_matrix(idx,:);

%Elliminate mixed and no percept from the classification
idx=Percept_vector>100 & Percept_vector<103;
Percept_vector=Percept_vector(idx);
Power_matrix=Power_matrix(idx,:);



%% % Calculate the number of samples for each class
num_class_101 = sum(Percept_vector == 101);
num_class_102 = sum(Percept_vector == 102);

% Determine the number of samples to use from each class
ntrain_per_class = min(num_class_101, num_class_102);
%ntrain_per_class = round(ntrain_per_class * 0.75); % 75% of the minimum class count

% Get indices of samples for each class
idx_class_101 = find(Percept_vector == 101);
idx_class_102 = find(Percept_vector == 102);

% Randomly select samples from each class based on the determined count
idx_train_101 = randsample(idx_class_101, ntrain_per_class);
idx_train_102 = randsample(idx_class_102, ntrain_per_class);

% Combine the indices for both classes
idx_train = [idx_train_101; idx_train_102];

% Use the selected samples for training
Percept_vector1 = Percept_vector(idx_train);
Power_matrix1 = Power_matrix(idx_train, :);

rng('default'); % Reset the random number generator
perm = randperm(length(Percept_vector1));
Percept_vector1 = Percept_vector1(perm);
Power_matrix1 = Power_matrix1(perm, :);

ntrain=round(size(Percept_vector1,1)*0.75);

TrainL=Percept_vector1(1:ntrain);
TrainV=Power_matrix1(1:ntrain,:);

%The rest of trials will be used for evaluating the classification
EvalL=Percept_vector1(ntrain+1:end);
EvalV=Power_matrix1(ntrain+1:end,:);


%%
%Prepare classification, use 75% of the trials to train the classifier
%The classification will be between perceiving or not perceiving face
ntrain=round(size(Percept_vector,1)*0.75);

TrainL=Percept_vector(1:ntrain);
TrainV=Power_matrix(1:ntrain,:);

%The rest of trials will be used for evaluating the classification
EvalL=Percept_vector(ntrain+1:end);
EvalV=Power_matrix(ntrain+1:end,:);

%% fname
classificationLearner

%% 

%Open Classification Learner: this has a graphical interface. Train all models (unless you have an idea
%of the better classifier for your data). The one working better for me was
%the Quadratic discriminant.
%Save the classification model giving better results to workspace

%Evaluate the result
%Here you should open APPS--> ClassificationLearner
%Use TrainV as data, TrainL as predictor
%Train all models (the one working best for me was Discriminant)
%Export the model with better accuracy to the workspace and use it for
%prediciton. Following line of code works for a model exported as
%trainedModel with a discriminant classifier. 
%More help here: https://uk.mathworks.com/help/stats/classificationlearner-app.html
%% Behavioral-Training
label = predict(trainedModel.ClassificationDiscriminant,EvalV);

Accuracy=100*sum(EvalL==label)/length(EvalL);

idx=find(EvalL==101);
TPR_face=100*sum(label(idx)==101)/length(idx);
%% Preciton Passive
label = predict(trainedModel.ClassificationDiscriminant,Power_matrix);


%%
%If the result works fine, you can now use the classifier for the trials
%without keypress response. Steps to do:
%1. Load data.
%2. Preprocessing.
%3. Time resolved power calculation
%4. Average in selected time windows
%5. Use the selected classifier.

%% %% % Perform cross-validation
[trainedClassifier, validationAccuracy] = trainClassifier(TrainV, TrainL)
partitionedModel = crossval(trainedClassifier.ClassificationDiscriminant, 'KFold', 5);

% Compute validation predictions
[validationPredictions, validationScores] = kfoldPredict(partitionedModel);

% Compute validation accuracy
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');

learner=partitionedModel.Trained{1, 1}
labels=predict(learner, EvalV)
Accuracy=100*sum(EvalL==labels)/length(EvalL);

idx=find(EvalL==101);
TPR_face=100*sum(labels(idx)==101)/length(idx);

%% 
num_trials = size(data.sampleinfo, 1);
counts_101 = zeros(num_trials, 1);
counts_102 = zeros(num_trials, 1);

for trial = 1:num_trials
    start_time = data.sampleinfo(trial, 1);
    end_time = data.sampleinfo(trial, 2);

    % Find the indices of trl_mat that fall within the current trial's time interval
    trial_indices = find(trl_mat(:, 1) >= start_time & trl_mat(:, 2) <= end_time);

    % Count the occurrences of labels 101 and 102 within the specified time interval
    counts_101(trial) = sum(trl_mat(trial_indices, 4) == 101);
    counts_102(trial) = sum(trl_mat(trial_indices, 4) == 102);
end

% Display the counts for each trial
disp('Trial Counts:');
disp([counts_101 counts_102]);


%% % Assuming you have the following variables:
% trl_mat: Matrix containing trial information (start_time, end_time, label)
% data.trialInfo: Column vector containing trigger information for each trial

% Assuming you have the following variables:
% counts_101: Array containing the counts of label 101 for each trial
% data.trialinfo: Column vector containing trigger information for each trial

% Define the triggers of interest
trigger_1 = 1;
trigger_2 = 2;
trigger_3 = 3;
trigger_4 = 4;

% Combine triggers 1 and 3
count_101_trigger_1_3 = sum(counts_101(data.trialinfo == trigger_1 | data.trialinfo == trigger_3));

% Combine triggers 2 and 4
count_101_trigger_2_4 = sum(counts_101(data.trialinfo == trigger_2 | data.trialinfo == trigger_4));

% Display the counts
disp('Counts of label 101 for different trigger combinations:');
disp(['Triggers 1 and 3: ' num2str(count_101_trigger_1_3)]);
disp(['Triggers 2 and 4: ' num2str(count_101_trigger_2_4)]);

