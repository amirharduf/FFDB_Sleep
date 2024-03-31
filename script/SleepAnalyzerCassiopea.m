% This code reads the raw data of mean pixels intensity of the Cassiopea and analyze sleep precent
clear;clc;close all;

%% Path
expName = "Behav_LD_20230118";
pathMain = 'C:\Users\User\dataFolder\';

%% Parameters

% General Parameters
saveData = 0;

% Analysis Parameters
samplingRate = 20; % fps
pulseMinQ_Th = 37; % pulses per minute for relaxed state
time_Th = 3; % time under pulsation threshold

% Plot Control
plotSingle = 0; % option to plot all single animal data for the first video
plotAll = 1; % option to plot all data 

%% loadData - load raw data from file path
% File names
pathMain = strcat(pathMain,expName,'\');
peakParametersName = strcat(expName,'_peakParameters');
videoNames = strcat(expName,'_Names');
nameOutAnimals = strcat(expName,'_nOut');
% Load 
[~,~,exp] = xlsread(strcat(pathMain,"\",expName,"_expParameters",'.xlsx'));
nAnimal = exp{2,1}; % number of animals in the video
nVideos = [exp{2,2}:exp{2,3}]; % videos number (1:2... 3:4...)

dirList = dir(strcat(pathMain,'meanIntensity\'));
dirList = dirList(3:end);
intensityData = cell(1,length(dirList));
for d = nVideos
    intensityData{1,d} = load(fullfile(pathMain,'meanIntensity\', dirList(d).name)).meanIntensity;
end
[~,~,peakParameters] = xlsread(strcat(pathMain,peakParametersName,'.xlsx'));
[~,~,nOut] = xlsread(strcat(pathMain,nameOutAnimals,'.xlsx'));


%% Initializing
binSize = 60; % In sec
tails = 50; % samples to remove from the gaussian filter edges
peakCount = cell(length(nVideos)+1,nAnimal); % initializing space
sleepMat = cell(length(nVideos)+1,nAnimal); % initializing space
for n = 1:nAnimal
    peakCount(1,n) = {['Animal = ',num2str(n)]};
    sleepMat(1,n) = {['Animal = ',num2str(n)]};
end
normPeakCount = peakCount; % initializing space

%% loop over video activity data
for v = nVideos 
    %% Analysis
    for n = 1:nAnimal
        if ~any(cell2mat(nOut(v+1,2:end)) == n)
            
            % Normalization, alignment of raw & filter, cut relavent timing
            gWin = gausswin(tails-1)./sum(gausswin(tails-1)); % gaussian window
            rawFilt = filter(gWin,1,intensityData{1,v}(:,n)); % gaussian filter
            rawFilt = rawFilt(tails:end); % gaussian filter cut edge
            nRawIntensity = intensityData{1,v}((tails/2):end-(tails/2),n); % raw data of animal
            normalizedIntensity = (nRawIntensity-rawFilt)*-1; % normalized data of animal
            
            % Find peaks
            threshold(n) = mean(normalizedIntensity)+std(normalizedIntensity)*peakParameters{v+1,n*2}; % threshold for a peak based on the parameters in the .xlsx and the data
            meanPeakDistance = peakParameters{v+1,n*2+1}; % threshold for a peak based on the parameters in the .xlsx 
            [peak,locs] = findpeaks(normalizedIntensity,'MinPeakDistance',meanPeakDistance,'MinPeakHeight',threshold(n)); % find pulses
            locsPlot = locs + (tails/2); % find pulses locations (to plot)
            peakCount{v+1,n} = length(peak)./(length(normalizedIntensity)/(samplingRate*60)); % pulse per minute
            pulseTrain = zeros(length(normalizedIntensity),1); % initializing space
            pulseTrain(locs,1) = 1; % define pulse locations
            lengthFreq = length(pulseTrain)-mod(length(pulseTrain),binSize*samplingRate); % for calculating the frequency
            freq = sum(reshape(pulseTrain(1:lengthFreq),binSize*samplingRate,lengthFreq./(binSize*samplingRate)))'.*(60/binSize); % calculating the frequency
            relax = [0;freq<=pulseMinQ_Th;0]; % sleep frequency under threshold
            relaxDiff = diff(relax); % sleep for under frequency threshold for more than time threshold
            relaxStartEnd = [find(relaxDiff == -1)-find(relaxDiff == 1)]; % sleep for under frequency threshold for more than time threshold
            relaxOverTimeTh = relaxStartEnd(relaxStartEnd >= time_Th); % sleep for under frequency threshold for more than time threshold
            sleepPrecent = (sum(relaxOverTimeTh)./(length(relaxDiff)-1))*100; % calculate sleep precent
            if isempty(sleepPrecent)
                sleepPrecent = 0;
            end
            sleepMat{v+1,n} = sleepPrecent;
            
            %% Plot
            time = ([1:length(normalizedIntensity)]+(tails/2))./samplingRate;
            if plotSingle == 1
                if nVideos(1) == v
                    figure('units','normalized','outerposition',[0 0 1 1])
                    %raw
                    subplot(2,1,1)
                    plot(time,nRawIntensity,'color',[0.5,0.5,0.5])
                    hold on
                    plot(time,rawFilt,'color','k','linewidth',1)
                    xlim([time(1) time(end)]);
                    legend('Raw intensity','Smooth intensity','location','southeast')
                    ylabel('Mean pixel intensity (a.u)');xlabel('Time (min)');title(strcat('Raw & smooth intensity in animal:',num2str(n)));
                    %norm
                    subplot(2,1,2)
                    plot(time,normalizedIntensity,'color',[0.5,0.5,0.5],'linewidth',1);hold on
                    line([time(1) time(end)],[threshold(n) threshold(n)],'color','r')
                    plot(locsPlot/samplingRate,peak,'o','color','r')
                    xlim([time(1) time(end)]);
                    ylabel('Normalized intensity (a.u)');xlabel('Time (min)');title(strcat('Normalized intensity in animal:',num2str(n)));
                    legend('Normalized intensity','Peak threshold','Peaks','location','southeast')
                end
            end
        end
    end
end
peakCount(cellfun('isempty',peakCount)) = {NaN};
sleepMat(cellfun('isempty',sleepMat)) = {NaN};
normMinMaxPeakCount = cell2mat(peakCount(2:end,:))-min(cell2mat(peakCount(2:end,:)));
normMinMaxPeakCount = normMinMaxPeakCount./max(normMinMaxPeakCount);
normMinMaxPeakCount = [peakCount(1,:);num2cell(normMinMaxPeakCount)];

%% Plot all data
if plotAll == 1
    figure
    plot(mean(cell2mat(normMinMaxPeakCount(2:end,:)),2,'omitnan'),'k','LineWidth',2)
    hold on
    plot(cell2mat(normMinMaxPeakCount(2:end,:)));title('pulsation (normalized)')
    legend({'Mean'})
    ylabel('Normalized intensity (a.u)');xlabel('Time (h)');
    hold off
    
    figure
    plot(mean(cell2mat(sleepMat(2:end,:)),2,'omitnan'),'k','LineWidth',2)
    hold on
    plot(cell2mat(sleepMat(2:end,:)));title('sleep')
    legend({'Mean'})
    ylabel('Sleep precent (%)');xlabel('Time (h)');
    hold off    
end

%% Save
if saveData == 1
    xlswrite(strcat(pathMain,expName,'_peakCount.xlsx'),peakCount)
    xlswrite(strcat(pathMain,expName,'_normMinMaxPeakCount.xlsx'),normMinMaxPeakCount)
    xlswrite(strcat(pathMain,expName,'_sleep.xlsx'),sleepMat)
end
